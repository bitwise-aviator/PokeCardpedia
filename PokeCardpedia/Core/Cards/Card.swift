//
//  Card.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation
import pokemon_tcg_sdk_swift
import CoreData

enum DataSource {
    case tracker
    case json
    case hybrid
    case storage
}

enum SuperCardType {
    // these types probably should be core data entities though...
    // use struct for outlining.
    case pokemon(data: PokemonCardData)
    case trainer(data: TrainerCardData)
    case energy(data: EnergyCardData)
}

extension SuperCardType {
    var typeToString: String {
        switch self {
        case .pokemon: return "pokemon"
        case .trainer: return "trainer"
        case .energy: return "energy"
        }
    }
}

/// Core object for a Pokémon TCG card.
class Card: ObservableObject {
    /// RegEx used to extract sorting components from card ID.
    static let sortRegex = /(?<prefix>[A-Z]*)(?<number>[0-9]+)(?<suffix>[A-Z]*)/
    /// RegEx used to extract the set number from the card ID.
    static let setNumberFromIdRegex = /[a-zA-Z0-9]+-(?<number>[a-zA-Z0-9]+)/
    /// Card ID as returned from the Pokémon TCG API.
    let id: String
    /// Pokémon TCG API code for the card's set.
    let setCode: String
    /// Card number within its set.
    let setNumber: String
    /// Card name.
    @Published var name: String?
    /// Card name, for deck-building purposes.
    var legalName: String? {
        guard let name = name else { return nil }
        // Pokémon TCG rules say that levels (LV.X, LV.20, etc.) are not part of the
        // card's name. For non-LV.X instances, the API already omits the level.
        // This handles LV.X cases.
        if name.hasSuffix("LV.X") {
            guard let match = try? /(?<name>.+) LV.X/.firstMatch(in: name) else {
                return name
            }
            return String(match.output.name)
        } else {
            return name
        }
    }
    /// Card rarity.
    @Published var rarity: String?
    /// URLs to image paths.
    let imagePaths: CardImageUrl
    /// Holds card type and type-specific data. Will become `let` constant on full implementation.
    var superCardType: SuperCardType?
    /// Blob data for card's small image. Unused, might be deprecated.
    lazy var imageDataSmall: Data? = {
        nil
    }()
    /// Blob data for card's large image. Unused, might be deprecated.
    lazy var imageDataLarge: Data? = {
        nil
    }()
    /// Modified version of the API's returned ID to facilitate sorting.
    var sortId: String {
        let match = setNumber.firstMatch(of: Card.sortRegex)
        guard let match else {return "\(setCode)-\(setNumber)"}
        let formattedNumber = String(format: "%03d", Int(match.output.number)!)
        return String("\(setCode)-\(match.output.prefix)\(formattedNumber)\(match.output.suffix)")
    }
    /// URL for the card's set icon. Premade from `Card.setCode`
    var setIconUrl: URL? {
        return URL(string: "https://images.pokemontcg.io/\(setCode)/symbol.png")
    }
    /// Reference to core.
    let core = Core.core
    /// Tracks card ownership & wishlisting.
    // @Published var collection: CardCollectionData?
    var collectionId: NSManagedObjectID?
    var persistentId: NSManagedObjectID?
    var origin: DataSource
    var dataVersion: String?
    /// Creates a Card instance from a JSON API response.
    /// - Parameter source: Pokémon TCG API card JSON, in struct format
    init(from source: CardFromJson) {
        origin = .json
        id = source.id
        setCode = source.set.id
        setNumber = source.number
        imagePaths = CardImageUrl(pathObject: source.images)
        name = source.name
        rarity = source.rarity
        switch source.supertype {
        case "Pokémon":
            superCardType = .pokemon(data: PokemonCardData(from: source))
        case "Trainer": superCardType = .trainer(data: TrainerCardData(from: source))
        case "Energy": superCardType = .energy(data: EnergyCardData(from: source))
        default:
            print("No supertype found for string \(source.supertype)")
            superCardType = nil
        }
    }
    /// Creates a Card instance from a stored Core Data CollectionTracker record.
    /// Note: this method will fail if the provided record contains null `id` or `set` properties and/or
    /// a set number cannot be extracted from the `id` property (i.e. does not match with `Card.setNumberFromIdRegex`)
    /// - Parameter source: a CollectionTracker Core Data record.
    init?(from source: CollectionTracker) {
        // init? is a failable initializer, where nil can be returned if initalization cannot be completed,
        // such as a guard statement triggering.
        guard let newId = source.id, let newSet = source.set else {
            print("Failed unwrapping... id: \(String(describing: source.id)), set: \(String(describing: source.set)) ")
            return nil
        }
        origin = .tracker
        id = newId
        setCode = newSet
        guard let match = id.firstMatch(of: Card.setNumberFromIdRegex) else {
            print("Failed unwrapping... id: \(id) did not produce a regex match")
            return nil
        }
        setNumber = String(match.output.number)
        let smallUrl = URL(string: "https://images.pokemontcg.io/\(setCode)/\(setNumber).png")
        let largeUrl = URL(string: "https://images.pokemontcg.io/\(setCode)/\(setNumber)_hires.png")
        imagePaths = CardImageUrl(small: smallUrl, large: largeUrl)
        //collection = source.toNativeForm
        collectionId = source.objectID
        superCardType = nil
    }
    
    init(from source: GeneralCardData) {
        origin = .storage
        dataVersion = source.dataVersion
        id = source.id
        setCode = source.set!
        setNumber = source.setNumber!
        let smallUrl = URL(string: "https://images.pokemontcg.io/\(setCode)/\(setNumber).png")
        let largeUrl = URL(string: "https://images.pokemontcg.io/\(setCode)/\(setNumber)_hires.png")
        imagePaths = CardImageUrl(small: smallUrl, large: largeUrl)
        name = source.name
        rarity = source.rarity
        print(rarity)
        collectionId = (source.collection?.allObjects as? [CollectionTracker])?.first?.objectID
    }
    
    /*func isComplete() -> Bool {
        return name != nil && rarity != nil && superCardType != nil
    }*/
    
    /// Retrieves remaining data from server to complete its Core Data record.
    /// Always run this after creating cards from Core Data records, then persist the data into Core Data.
    /// If data is not persisted, it will trigger a lot of unnecessary API calls and possibly cause server rejection.
    func completeData() async {
        // Add more parameters as complexity expands.
        guard name == nil || rarity == nil else { return }
        print("Requesting additional data for id: \(id)")
        guard let cardResponse = await ApiClient.client.getById(id: id) else {
            print("Did not receive a API response for id: \(id)")
            return
        }
        guard let completingData = parseCardsFromJson(data: cardResponse),
              completingData.count == 1 else {
            print("Could not parse a unique record for id: \(id)")
            return
        }
        if let tempCard = completingData.first?.toCardObject() {
            merge(from: tempCard)
            let success = true // await PersistenceController.shared.completeCard(self)
            if success {
                print("Merged data for id: \(self.id)")
            } /*else {
                print("Could not merge data for id: \(self.id)")
            }*/
        }
    }
    
    func getCardObject(context: NSManagedObjectContext = PersistenceController.context) -> GeneralCardData? {
        guard let persistentId else { return nil }
        return context.object(with: persistentId) as? GeneralCardData
    }
    
    func getCollectionObject(context: NSManagedObjectContext = PersistenceController.context) -> CollectionTracker? {
        guard let collectionId else { return nil }
        return context.object(with: collectionId) as? CollectionTracker
    }
    
    /// Adds/remove card to favorites list
    /// - Parameter target: add to (true) or remove from (false) favorites list.
    /*
    func setFavorite(_ target: Bool) {
        if var newCollection = collection {
            newCollection.favorite = target
            let success = PersistenceController.shared.patchCard(self, with: newCollection)
            if success {
                collection = newCollection
            }
        }
    }
    /// Adds/remove card to wishlist
    /// - Parameter target: add to (true) or remove from (false) wishlist.
    func setWantIt(_ target: Bool) {
        if var newCollection = collection {
            newCollection.wantIt = target
            let success = PersistenceController.shared.patchCard(self, with: newCollection)
            if success {
                collection = newCollection
            }
            print(target, success)
        }
    }
    /// Alters card count in user's collection.
    /// - Parameter target: new number of cards owned. Must be non-negative.
    @MainActor func setNumberOwned(_ target: Int16) {
        if var newCollection = collection, target >= 0 {
            newCollection.amount = target
            let success = PersistenceController.shared.patchCard(self, with: newCollection)
            if success {
                collection = newCollection
                Core.core.updateActiveCounters()
            }
            print(target, success)
        }
    }
    /// Shorthand method to add one copy of card to collection. Currently unused, might be deprecated.
    @MainActor func addOne() {
        if self.collection != nil {
            let newCount = self.collection!.amount + 1
            // ~= is contains
            guard 0...999 ~= newCount else {return}
            self.setNumberOwned(newCount)
        }
    }
     */
    /// Checks if this card features the Pokémon with the specified National Pokédex number.
    /// - Parameter dex: the Pokédex number.
    /// - Returns: true if a Pokémon card and includes the specified Pokémon.
    func isOfPokedex(_ dex: Int) -> Bool {
        switch self.superCardType {
        case .pokemon(data: let data): return data.dex?.contains(dex) ?? false
        default: return false
        }
    }
    func merge(from source: Card) {
        self.name = self.name ?? source.name
        self.rarity = self.rarity ?? source.rarity
        self.superCardType = self.superCardType ?? source.superCardType
    }
    
    @discardableResult func makeUnsafeCardRecord(into context: NSManagedObjectContext) throws -> GeneralCardData {
        return context.performAndWait {
            let buildFor = DataModelVersion.current
            let newCardRecord = GeneralCardData(context: context)
            newCardRecord.dataVersion = DataModelVersion.current
            newCardRecord.id = id
            newCardRecord.set = setCode
            newCardRecord.setNumber = setNumber
            newCardRecord.name = name
            newCardRecord.legalName = legalName
            newCardRecord.rarity = rarity
            newCardRecord.supertype = superCardType?.typeToString
            newCardRecord.addUnboundTrackers(context: context)
            print("Card \(newCardRecord.id) has \(newCardRecord.collection?.count) trackers.")
            // Initialize tracker if none exist.
            if newCardRecord.collection?.count == 0 {
                newCardRecord.addToCollection(PersistenceController.newCollectionTracker(set: setCode, id: id))
            }
            return newCardRecord
        }
        
    }
    
    @discardableResult func makeSafeCardRecord(into context: NSManagedObjectContext, autoApply: Bool = true) throws -> NSManagedObjectID {
        // Check before creating
        let fetch = GeneralCardData.fetchRequest()
        fetch.predicate = NSPredicate(format: "id = %@", id)
        let existingCard = try? context.fetch(fetch)
        guard let existingCard else {
            throw IOError.fetch
        }
        guard existingCard.count > 1 else {
            throw IOError.dupe
        }
        guard existingCard.count == 1 else {
            if autoApply {
                persistentId = existingCard[0].objectID
            }
            return existingCard[0].objectID
        }
        
        context.performAndWait {
            let buildFor = DataModelVersion.current
            let newCardRecord = GeneralCardData(context: context)
            newCardRecord.dataVersion = DataModelVersion.current
            newCardRecord.id = id
            newCardRecord.set = setCode
            newCardRecord.setNumber = setNumber
            newCardRecord.name = name
            newCardRecord.legalName = legalName
            newCardRecord.rarity = rarity
            newCardRecord.supertype = superCardType?.typeToString
            newCardRecord.addUnboundTrackers(context: context)
            print("Card \(newCardRecord.id) has \(newCardRecord.collection?.count) trackers.")
            // Initialize tracker if none exist.
            if newCardRecord.collection?.count == 0 {
                newCardRecord.addToCollection(PersistenceController.newCollectionTracker(set: setCode, id: id))
            }
        }
        context.saveIfChanged()
        let refetch = GeneralCardData.fetchRequest()
        refetch.predicate = NSPredicate(format: "id = %@", id)
        let persistedCard = try? context.fetch(refetch)
        guard let persistedCard, persistedCard.count == 1 else {
            if persistedCard == nil {
                print("Fetch failed")
            } else if persistedCard!.count == 0 {
                print("No records were located")
            } else if persistedCard!.count >= 2 {
                print("Duplicated records were found")
            }
            throw IOError.fetch
        }
        if autoApply {
            persistentId = persistedCard[0].objectID
            collectionId = (persistedCard[0].collection?.allObjects as? [CollectionTracker])?.first?.objectID
        }
        return persistedCard[0].objectID
    }
}

/// Tracks collection status for `Card` objects in memory. Mirrors Core Data CollectionTracker entity.
struct CardCollectionData {
    /// Whether card is in favorites list.
    var favorite: Bool = false
    /// Whether card is in wishlist.
    var wantIt: Bool = false
    /// Number of copies of card owned.
    var amount: Int16 = 0
}
