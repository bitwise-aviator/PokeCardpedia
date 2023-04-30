//
//  Core.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/15/23.
//

import Foundation

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
    @Published var viewMode: ViewMode?
    @Published var activeSet: SetFromJson?
    @Published var activeDex: Int?
    @Published private(set) var sets: [SetFromJson]?
    @Published private(set) var setImages: [String: Data] = [:]
    /* To avoid encountered errors with save requests for persistent storage
     and to keep the main thread free, saves will be done on the main thread
     only when this queue is vacated. */
    /// Stores sets in the loading queue.
    private var loadingSets = Set<String>()
    /// Stores sets that have been successfully loaded.
    private var loadedSets = Set<String>()
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
        let owned: Int = Array(activeData.values).reduce(0) { $0 + Int($1.collection?.amount ?? 0) }
        let unique: Int = Array(activeData.values).reduce(0) { $0 + min(Int($1.collection?.amount ?? 0), 1)}
        (activeOwned, activeUniqueOwned) = (owned, unique)
    }
    func getCardsBySet(set: String) async {
        if !loadedSets.contains(set) && !loadingSets.contains(set) {
            loadingSets.insert(set) // Moving this line here to avoid unnecessary duplicate requests.
            // 1) Get JSON response from API (include image URLs, not image data).
            // Simultaneously, fire a FetchRequest for cards in the same set.
            print("Added set \(set) to loading queue. Queue length: \(loadingSets.count)")
            enum DataResult {
                case cardData([Data]?)
                case collectionData([String: CollectionTracker]?)
            }
            let result = await withTaskGroup(of: DataResult.self) { group -> (
                cardData: [Data]?, collectionData: [String: CollectionTracker]?) in
                group.addTask {
                    return await .cardData(ApiClient.client.getBySetId(id: set, recursive: true))
                }
                group.addTask {
                    let fetched = PersistenceController.shared.fetchCards([.bySet(id: set)])
                    return .collectionData(fetched?.toDict())
                }
                var cardData: [Data]?
                var collectionData: [String: CollectionTracker]?
                for await value in group {
                    switch value {
                    case .cardData(let value):
                        cardData = value
                    case .collectionData(let value):
                        collectionData = value
                    }
                }
                return (cardData: cardData, collectionData: collectionData)
            }
            // 2) Check if data was received and is OK.
            guard let data = result.cardData, let parsedCards = parseCardsFromJson(data: data) else {
                loadingSets.remove(set) // Remove the lock on duplicate requests if fails.
                print("Fetching set \(set) failed: removing from loading queue. Queue length: \(loadingSets.count)")
                if loadingSets.isEmpty {
                    print("Queue has been vacated")
                    // TODO: Fire a save request here.
                }
                return
            }
            // 3) Check if data is already loaded. If not, merge into.
            parsedCards.forEach { elem in
                // Skip/complete loaded data.
                guard loadedData[elem.sortId] == nil else {
                    loadedData[elem.sortId]?.merge(from: elem.toCardObject())
                    return
                }
                // Skip bad data
                // guard let cardObject = elem.toCardObject() else {return}
                let cardObject = elem.toCardObject()
                loadedData[elem.sortId] = cardObject
                if let collectionRecord = result.collectionData?[elem.id] {
                    loadedData[elem.sortId]!.collection = collectionRecord.toNativeForm
                } else {
                    loadedData[elem.sortId]!.collection = PersistenceController.shared
                        .newCardCollectionDefaults(loadedData[elem.sortId]!)?.toNativeForm
                }
            }
            loadedSets.insert(set)
            loadingSets.remove(set)
            print("Set \(set) loaded OK, transferred to loadedSets. Loading queue length: \(loadingSets.count)")
            if loadingSets.isEmpty {
                print("Queue has been vacated")
                // TODO: Fire a save request here.
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
        if !loadedDexs.contains(dex) {
            // 1) Get JSON response from API (include image URLs, not image data).
            // Simultaneously, fire a FetchRequest for cards in the same set.
            enum DataResult {
                case cardData(Data?)
                case collectionData([String: CollectionTracker]?)
            }
            let result = await withTaskGroup(of: DataResult.self) { group -> (
                cardData: Data?, collectionData: [String: CollectionTracker]?) in
                group.addTask {
                    return await .cardData(ApiClient.client.getByPokedex(id: dex))
                }
                group.addTask {
                    let fetched = PersistenceController.shared.fetchCards([])
                    return .collectionData(fetched?.toDict())
                }
                var cardData: Data?
                var collectionData: [String: CollectionTracker]?
                for await value in group {
                    switch value {
                    case .cardData(let value): cardData = value
                    case .collectionData(let value): collectionData = value
                    }
                }
                return (cardData: cardData, collectionData: collectionData)
            }
            // 2) Check if data is already loaded. If not, merge into.
            if let data = result.cardData {
                if let parsedCards = parseCardsFromJson(data: data) {
                    parsedCards.forEach { elem in
                        // Skip loaded data
                        guard loadedData[elem.sortId] == nil else {
                            loadedData[elem.sortId]?.merge(from: elem.toCardObject())
                            return
                        }
                        // Skip bad data
                        // guard let cardObject = elem.toCardObject() else {return}
                        let cardObject = elem.toCardObject()
                        loadedData[elem.sortId] = cardObject
                        if let collectionRecord = result.collectionData?[elem.id] {
                            loadedData[elem.sortId]!.collection = collectionRecord.toNativeForm
                        } else {
                            loadedData[elem.sortId]!.collection = PersistenceController.shared
                                .newCardCollectionDefaults(loadedData[elem.sortId]!)?.toNativeForm
                        }
                    }
                }
            }
        }
        // 3) Refine active view accordingly.
        loadedDexs.insert(dex)
        DispatchQueue.main.async {
            self.activeData = self.loadedData.filter({
                return $0.value.isOfPokedex(dex)
            })
            self.updateActiveCounters()
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
                for key in Array(fetched.keys) {
                    if let item = fetched[key], let newCard = Card(from: item), loadedData[newCard.sortId] == nil {
                        loadedData[newCard.sortId] = newCard
                        /*Task(priority: .userInitiated) {
                            await newCard.completeData()
                        }*/
                     }
                }
            }
            DispatchQueue.main.async {
                let newActiveData: [String: Card]? = {
                    switch view {
                    case .owned: return self.loadedData.filter({($0.value.collection?.amount ?? 0) > 0})
                    case .favorite: return self.loadedData.filter({($0.value.collection?.favorite ?? false)})
                    case .want: return self.loadedData.filter({($0.value.collection?.wantIt ?? false)})
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
