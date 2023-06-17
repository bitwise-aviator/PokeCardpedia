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

extension String {
    func separateCollectionTrackerKey() -> (user: String, card: String)? {
        let pattern = /(?<user>[A-F0-9-]+)@(?<card>[A-Za-z0-9-]+)/
        guard let match = self.firstMatch(of: pattern) else { return nil }
        return (user: String(match.output.user), card: String(match.output.card))
    }
}

extension [CollectionTracker] {
    func toDict() -> [String: CollectionTracker] {
        var dict: [String: CollectionTracker] = [:]
        self.forEach {elem in
            let compoundKey = "\(elem.owner?.ident.uuidString ?? "nil")@\(elem.id!)"
            dict[compoundKey] = elem
        }
        return dict
    }
}

extension [GeneralCardData] {
    func toDict() -> [String: GeneralCardData] {
        var dict: [String: GeneralCardData] = [:]
        self.forEach {elem in
            dict[elem.id] = elem
        }
        return dict
    }
}

extension CollectionTracker {
    var toNativeForm: CardCollectionData {
        return CardCollectionData(favorite: self.favorite, wantIt: self.wantIt, amount: self.amount)
    }
    /*
    func mergeWithCard(_ card: some Card) {
        guard card.id == self.id, card.setCode == self.set else {
            return
        }
        card.collection = self.toNativeForm
    } */
}

extension NSManagedObjectContext {
    @discardableResult func saveIfChanged(recursive: Bool = false) -> Bool {
        guard self.hasChanges else { return true }
        do {
            try self.save()
            if recursive && self.parent != nil {
                return self.parent!.saveIfChanged(recursive: true)
            } else {
                return true
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func addSearchParameters<T>(_ searchParameters: [SearchType], to request: NSFetchRequest<T>) {
        var predicates = [NSPredicate]()
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
        if predicates.isEmpty {
            return
        } else if predicates.count == 1 {
            request.predicate = predicates[0]
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
    
    func fetchCards(_ searchParameters: [SearchType] = []) -> [GeneralCardData]? {
        let fetchRequest = GeneralCardData.fetchRequest()
        addSearchParameters(searchParameters, to: fetchRequest)
        do {
            return try PersistenceController.context.fetch(fetchRequest)
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchCards(_ searchParameters: [SearchType] = []) -> [CollectionTracker]? {
        // Note: records retrieved will satisfy ALL criteria parameters passed.
        // Passing mutually exclusive parameters, such as owned and not owned, will return nothing.
        let fetchRequest = CollectionTracker.fetchRequest()
        addSearchParameters(searchParameters, to: fetchRequest)
        do {
            return try PersistenceController.context.fetch(fetchRequest)
        } catch {
            print(error)
            return nil
        }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    static let context = shared.container.viewContext
    /* static let backgroundContext: NSManagedObjectContext = {
        let bgContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bgContext.parent = context
        return bgContext
    }() */
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
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the
                   device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    static func newCollectionTracker(_ card: Card, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> NSManagedObjectID {
        // return the object ID if possible to facilitate thread safety.
        return context.performAndWait {
            print("Creating tracker for id: \(card.id)")
            let newTracker = CollectionTracker(context: context)
            newTracker.id = card.id
            newTracker.set = card.setCode
            newTracker.amount = 0
            newTracker.favorite = false
            newTracker.wantIt = false
            print("Tracker successfully created w/ id: \(newTracker.objectID)")
            return newTracker.objectID
        }
    }

    static func newCollectionTracker(set: String, id: String, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> NSManagedObjectID {
        // return the object ID if possible to facilitate thread safety.
        return context.performAndWait {
            print("Creating tracker for id: \(id)")
            let newTracker = CollectionTracker(context: context)
            newTracker.id = id
            newTracker.set = set
            newTracker.amount = 0
            newTracker.favorite = false
            newTracker.wantIt = false
            print("Tracker successfully created w/ id: \(newTracker.objectID)")
            return newTracker.objectID
        }
    }
    
    static func newCollectionTracker(set: String, id: String, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> CollectionTracker {
        // less safe: returns the object itself but for short-term use.
        return context.performAndWait {
            print("Creating tracker for id: \(id)")
            let newTracker = CollectionTracker(context: context)
            newTracker.id = id
            newTracker.set = set
            newTracker.amount = 0
            newTracker.favorite = false
            newTracker.wantIt = false
            print("Tracker successfully created w/ id: \(newTracker.objectID)")
            return newTracker
        }
    }
    
    static func addCardToTracker(_ card: Card, to tracker: CollectionTracker) {
        
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
    /*
    func completeCard(_ card: Card, isConcurrent: Bool = true) async -> Bool {
        PersistenceController.backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let cardCollectionItem = CollectionTracker(context: PersistenceController.backgroundContext)
        cardCollectionItem.id = card.id
        cardCollectionItem.set = card.setCode
        cardCollectionItem.amount = card.collection?.amount ?? 0
        cardCollectionItem.favorite = card.collection?.favorite ?? false
        cardCollectionItem.wantIt = card.collection?.wantIt ?? false
        print(cardCollectionItem)
        return await PersistenceController.backgroundContext.perform {
            do {
                try PersistenceController.backgroundContext.save()
                return true
            } catch {
                print(error)
                return false
            }
        }
    } */
    
    func patchCard(_ card: Card, with newData: CardCollectionData) -> Bool {
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
    // TODO: Migrate.
    func fetchCards(_ searchParameters: [SearchType] = []) -> [CollectionTracker]? {
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
