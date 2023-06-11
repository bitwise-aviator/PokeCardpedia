//
//  Core.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/15/23.
//

import Foundation
import CoreData

enum ViewMode: String {
    case set
    case owned
    case favorite
    case want
    case dex
    case none
}

@MainActor class Core: ObservableObject {
    static let core = Core() // singleton
    static let loadQueue = DispatchQueue(label: "com.pokecard.cdload", qos: .userInteractive)
    @Published var viewMode: ViewMode?
    @Published var activeSet: SetFromJson?
    @Published var activeDex: Int?
    @Published private(set) var sets: [SetFromJson]?
    @Published private(set) var setImages: [String: Data] = [:]
    /* To avoid encountered errors with save requests for persistent storage
     and to keep the main thread free, saves will be done on the main thread
     only when this queue is vacated. */
    /// Stores sets in the loading queue.
    private var queryQueue = Set<String>()
    /// Stores sets that have been successfully loaded.
    private var queried = Set<String>()
    private var loadedDexs = Set<Int>()
    private var loadedData: [String: Card] = [:]
    @Published private(set) var activeData: [String: Card] = [:]
    @Published private(set) var activeOwned: Int = 0
    @Published private(set) var activeUniqueOwned: Int = 0
    func setActiveSet(set: SetFromJson) {
        viewMode = .set
        activeSet = set
        activeDex = nil
        Task {
            await getCardsBySet(set: set.id)
        }
    }
    func setActiveDex(dex: Int) {
        viewMode = .dex
        activeDex = dex
        activeSet = nil
        Task {
            await getCardsByPokedex(dex: dex)
        }
    }
    func setNonSetViewModeAsActive(target: ViewMode?) {
        (viewMode, activeSet, activeDex) = (target, nil, nil)
        guard let viewMode else { return }
        getCardsByViewMode(viewMode)
    }
    func updateActiveCounters() {
        let owned: Int = Array(activeData.values).reduce(0) { $0 +
            Int($1.getCollectionObject()?.amount ?? 0) }
        let unique: Int = Array(activeData.values).reduce(0) { $0 + min(Int($1.getCollectionObject()?.amount ?? 0), 1)}
        (activeOwned, activeUniqueOwned) = (owned, unique)
    }
    
    func matchCardData(of input: [CardFromJson], by query: [SearchType], context: NSManagedObjectContext) throws {
        guard let fetched = (context.fetchCards(query) as [GeneralCardData]?)?.toDict() else { throw IOError.fetch }
        
        var newRecords = [String: String]()
        input.forEach { elem in
            // Merge if loaded.
            guard loadedData[elem.sortId] == nil else {
                loadedData[elem.sortId]!.merge(from: elem.toCardObject())
                // If no CD record found, create.
                let record = fetched[elem.id]
                if record == nil {
                    do {
                        // print("Card \(elem.id) is not persisted.")
                        try loadedData[elem.sortId]!.makeUnsafeCardRecord(into: context)
                        newRecords[elem.sortId] = elem.id
                    } catch {
                        print(error)
                    }
                } else if !record!.isCurrent {
                    print("Need to update - merging")
                    let oid = fetched[elem.id]!.objectID
                    do {
                        try (PersistenceController.context.object(with: oid) as! GeneralCardData).updateFromCard(card: loadedData[elem.sortId]!)
                    } catch {
                        print(error)
                    }
                    // print("Card \(elem.id) was already persisted for version \(fetched[elem.id]!.dataVersion) with \(fetched[elem.id]!.collection?.count) trackers.")
                }
                return
            }
            // Create if it doesn't.
            loadedData[elem.sortId] = elem.toCardObject()
            let record = fetched[elem.id]
            if fetched[elem.id] == nil {
                do {
                    // print("Card \(elem.id) is not persisted.")
                    try loadedData[elem.sortId]!.makeUnsafeCardRecord(into: context)
                    newRecords[elem.sortId] = elem.id
                } catch {
                    print(error)
                }
            } else if !record!.isCurrent {
                print("Need to update - unmerged")
                let oid = fetched[elem.id]!.objectID
                do {
                    try (PersistenceController.context.object(with: oid) as! GeneralCardData).updateFromCard(card: loadedData[elem.sortId]!)
                } catch {
                    print(error)
                }
                // print("Card \(elem.id) was already persisted for version \(fetched[elem.id]!.dataVersion) with \(fetched[elem.id]!.collection?.count) trackers.")
            }
        }
        print(PersistenceController.context.hasChanges)
        PersistenceController.context.saveIfChanged(recursive: true)
        guard let reFetched = (context.fetchCards(query) as [GeneralCardData]?)?.toDict() else { throw IOError.fetch }
        for (key, value) in newRecords {
            guard let card = loadedData[key] else { continue }
            if reFetched[value] != nil {
                card.persistentId = reFetched[value]!.objectID
                card.collectionId = (reFetched[value]!.collection?.allObjects.first as? CollectionTracker)?.objectID
                card.dataVersion = reFetched[value]?.dataVersion
            }
        }
    }
    
    func getCardsBySet(set: String) async {
        let loadId = "set:\(set)"
        if !queried.contains(loadId) && !queryQueue.contains(loadId) {
            queryQueue.insert(loadId) // Moving this line here to avoid unnecessary duplicate requests.
            // 1) Get JSON response from API (include image URLs, not image data).
            // Simultaneously, fire a FetchRequest for cards in the same set.
            print("Added set \(set) to loading queue. Queue length: \(queryQueue.count)")

            guard let cardResponse = await ApiClient.client.getBySetId(id: set, recursive: true),
                  let parsedCards = parseCardsFromJson(data: cardResponse) else {
                queryQueue.remove(loadId)
                print("Fetching set \(set) failed: removed from loading queue. Queue length: \(queryQueue.count)")
                if queryQueue.isEmpty {
                    print("Queue has been vacated")
                    PersistenceController.context.saveIfChanged(recursive: true)
                }
                return
            }
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                try self.matchCardData(of: parsedCards, by: [.bySet(id: set)], context: PersistenceController.context)
            } catch {
                print(error)
                queryQueue.remove(loadId)
                print("Matching set \(set) failed: removed from loading queue. Queue length: \(queryQueue.count)")
                if queryQueue.isEmpty {
                    print("Queue has been vacated")
                    PersistenceController.context.saveIfChanged(recursive: true)
                }
            }
            let diff = CFAbsoluteTimeGetCurrent() - startTime
            print("Runtime: \(diff)s")
            
            queried.insert(loadId)
            queryQueue.remove(loadId)
            print("Set \(set) loaded OK. Loading queue length: \(queryQueue.count)")
            if queryQueue.isEmpty {
                print("Queue has been vacated")
                PersistenceController.context.saveIfChanged(recursive: true)
            }
        }
        // 4) Refine active view accordingly - but ONLY if same set is still active.
        /* This prevents behavior where we're only trying to load sets in the background
        or where multiple sets have been requested in a short period of time and the UI refresh
        has not been able to follow up fast enough. */
        if activeSet?.id == set {
            DispatchQueue.main.async {
                self.activeData = self.loadedData.filter({$0.value.setCode == set})
                self.updateActiveCounters()
            }
        }
    }
    func getCardsByPokedex(dex: Int) async {
        let loadId = "dex:\(String(dex))"
        if !queried.contains(loadId) && !queryQueue.contains(loadId) {
            queryQueue.insert(loadId) // Moving this line here to avoid unnecessary duplicate requests.
            // 1) Get JSON response from API (include image URLs, not image data).
            // Simultaneously, fire a FetchRequest for cards in the same set.
            print("Added Pokédex #\(String(dex)) to loading queue. Queue length: \(queryQueue.count)")

            guard let cardResponse = await ApiClient.client.getByPokedex(id: dex),
                  let parsedCards = parseCardsFromJson(data: cardResponse) else {
                queryQueue.remove(loadId)
                print("Fetching Pokédex #\(String(dex)) failed: removed from loading queue. Queue length: \(queryQueue.count)")
                if queryQueue.isEmpty {
                    print("Queue has been vacated")
                    PersistenceController.context.saveIfChanged(recursive: true)
                }
                return
            }
            let startTime = CFAbsoluteTimeGetCurrent()
            do {
                try self.matchCardData(of: parsedCards, by: [], context: PersistenceController.context)
            } catch {
                print(error)
                queryQueue.remove(loadId)
                print("Matching Pokédex #\(String(dex)) failed: removed from loading queue. Queue length: \(queryQueue.count)")
                if queryQueue.isEmpty {
                    print("Queue has been vacated")
                    PersistenceController.context.saveIfChanged(recursive: true)
                }
            }
            let diff = CFAbsoluteTimeGetCurrent() - startTime
            print("Runtime: \(diff)s")
            
            queried.insert(loadId)
            queryQueue.remove(loadId)
            print("Pokédex #\(String(dex)) loaded OK. Loading queue length: \(queryQueue.count)")
            if queryQueue.isEmpty {
                print("Queue has been vacated")
                PersistenceController.context.saveIfChanged(recursive: true)
            }
        }
        // 3) Refine active view accordingly.
        if activeDex == dex {
            DispatchQueue.main.async {
                self.activeData = self.loadedData.filter({
                    return $0.value.isOfPokedex(dex)
                })
                self.updateActiveCounters()
            }
        }
    }
    func fetchCards(by selector: ViewMode) -> [String: CollectionTracker]? {
        switch selector {
        case .owned: return PersistenceController.shared.fetchCards([.owned(true)])?.toDict()
        case .favorite: return PersistenceController.shared.fetchCards([.favorite(true)])?.toDict()
        case .want: return PersistenceController.shared.fetchCards([.wantIt(true)])?.toDict()
        default: return nil
        }
    }
    func getCardsByViewMode(_ view: ViewMode) {
        Task {
            let fetched = fetchCards(by: view)
            // let fetched = PersistenceController.shared.fetchCards([.owned(true)])?.toDict()
            if let fetched {
                var created: Int = 0
                var notCreated: Int = 0
                for key in Array(fetched.keys) {
                    if let item = fetched[key] {
                        var newCard: Card?
                        // Check if card data is good and updated.
                        if let cardInfo = item.cardDetails, cardInfo.isCurrent {
                            newCard = Card(from: cardInfo)
                            print("Created card from persist for \(item.id)")
                            newCard!.persistentId = cardInfo.objectID
                            newCard!.collectionId = item.objectID
                            created += 1
                        } else {
                            newCard = Card(from: item)
                            print("Did not create for \(item.id)")
                            notCreated += 1
                        }
                        if let newCard, loadedData[newCard.sortId] == nil {
                            loadedData[newCard.sortId] = newCard
                        }
                    }
                }
                print(created, "/", notCreated)
            }
            DispatchQueue.main.async {
                let newActiveData: [String: Card]? = {
                    switch view {
                    case .owned: return self.loadedData.filter({($0.value.getCollectionObject()?.amount ?? 0) > 0})
                    case .favorite: return self.loadedData.filter({($0.value.getCollectionObject()?.favorite ?? false)})
                    case .want: return self.loadedData.filter({($0.value.getCollectionObject()?.wantIt ?? false)})
                    default: return nil
                    }
                }()
                (self.activeSet, self.activeData) = (nil, newActiveData ?? [:])
                self.updateActiveCounters()
            }
        }
    }
    func getAllSets() async {
        let setData = await parseSetsFromJson(data: ApiClient.client.getSetById())
        DispatchQueue.main.async {
            self.sets = setData?.sorted { $0.releaseDate < $1.releaseDate }
        }
    }
    func getSetImages() async {
        if let setData = sets {
            var cache: [String: Data] = [:]
            for elem in setData where setImages[elem.id] == nil {
                guard let url = URL(string: elem.images.symbol) else {continue}
                if let imgData = try? await URLSession.shared.data(from: url) {
                    cache[elem.id] = imgData.0
                }
            }
            DispatchQueue.main.async {
            }
        }
    }
    private init() {
        Task {
            _ = PokemonNameset.common // trigger lazy initialization of Pokemon names object.
        }
        Task {
            print("Getting card data")
            setNonSetViewModeAsActive(target: .owned)
            print("Got card data")
        }
        Task {
            print("Getting set data")
            await getAllSets()
            print("Got set data")
        }
    }
}
