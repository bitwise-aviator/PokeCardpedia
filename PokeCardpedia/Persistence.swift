//
//  Persistence.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/11/23.
//

import CoreData

enum SearchType {
    case owned(Bool)
    case favorite(Bool)
    case wantIt(Bool)
    case bySet(id: String)
}

extension [CollectionTracker] {
    func toDict() -> [String: CollectionTracker] {
        var dict: [String: CollectionTracker] = [:]
        self.forEach {elem in
            dict[elem.id!] = elem
        }
        return dict
    }
}

extension CollectionTracker {
    var toNativeForm: CardCollectionData {
        return CardCollectionData(favorite: self.favorite, wantIt: self.wantIt, amount: self.amount)
    }
    func mergeWithCard(_ card: some Card) {
        guard card.id == self.id, card.setCode == self.set else {
            return
        }
        card.collection = self.toNativeForm
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    static let context = shared.container.viewContext

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application,
            // although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PokeCardpedia")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    func newCardCollectionDefaults(_ card: some Card) -> CollectionTracker? {
        PersistenceController.shared.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        let cardCollectionItem = CollectionTracker(context: PersistenceController.context)
        cardCollectionItem.id = card.id
        cardCollectionItem.set = card.setCode
        cardCollectionItem.amount = 0
        cardCollectionItem.favorite = false
        cardCollectionItem.wantIt = false
        do {
            try PersistenceController.context.save()
            return cardCollectionItem
        } catch {
            print(error)
            return nil
        }
    }
    /*
    func newCardCollection(_ cards: [CardCollectionData]) {
        PersistenceController.shared.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        cards.forEach({elem in
            let cardCollectionItem = CollectionTracker(context: PersistenceController.context)
            cardCollectionItem.id = elem.id
            cardCollectionItem.set = elem.set
            cardCollectionItem.amount = elem.amount
            cardCollectionItem.favorite = elem.favorite
            cardCollectionItem.wantIt = elem.wantIt
            
            do {
                try PersistenceController.context.save()
            } catch {
                print(error)
            }
        })
    }
     */
    func patchCard(_ card: some Card, with newData: CardCollectionData) -> Bool {
        PersistenceController.shared.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let cardCollectionItem = CollectionTracker(context: PersistenceController.shared.container.viewContext)
        cardCollectionItem.id = card.id
        cardCollectionItem.set = card.setCode
        cardCollectionItem.amount = newData.amount
        cardCollectionItem.favorite = newData.favorite
        cardCollectionItem.wantIt = newData.wantIt
        do {
            try PersistenceController.shared.container.viewContext.save()
            return true
        } catch {
            print(error)
            return false
        }
    }
    func fetchCards(_ searchParameters: [SearchType] = []) -> [CollectionTracker]? {
        // TODO: Make async.
        // Note: records retrieved will satisfy ALL criteria parameters passed.
        // Passing mutually exclusive parameters, such as owned and not owned, will return nothing.
        let fetchRequest = CollectionTracker.fetchRequest()
        var predicates: [NSPredicate] = []
        searchParameters.forEach({ parameter in
            switch parameter {
            case .owned(true): predicates.append(NSPredicate(format: "amount > 0"))
            case .owned(false): predicates.append(NSPredicate(format: "amount = 0"))
            case .favorite(let flag): predicates.append(NSPredicate(format: "favorite = %d", flag))
            case .wantIt(let flag): predicates.append(NSPredicate(format: "wantIt = %d", flag))
            case .bySet(id: let id):
                predicates.append(NSPredicate(format: "set = %@", id))
            }
        })
        if predicates.count > 0 {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        do {
            return try PersistenceController.context.fetch(fetchRequest)
        } catch {
            print(error)
            return nil
        }
    }
}
