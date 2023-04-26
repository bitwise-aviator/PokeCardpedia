//
//  Card.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation
import pokemon_tcg_sdk_swift

enum SuperCardType {
    // these types probably should be core data entities though...
    // use struct for outlining.
    case pokemon(data: PokemonCardData)
    case trainer(data: TrainerCardData)
    case energy(data: EnergyCardData)
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
    let name: String?
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
    /// Tracks card ownership & wishlisting.
    @Published var collection: CardCollectionData?
    /// Creates a Card instance from a JSON API response.
    /// - Parameter source: Pokémon TCG API card JSON, in struct format
    init(from source: CardFromJson) {
        id = source.id
        setCode = source.set.id
        setNumber = source.number
        imagePaths = CardImageUrl(pathObject: source.images)
        name = source.name
        collection = nil
        switch source.supertype {
        case "Pokémon": superCardType = .pokemon(data: PokemonCardData(from: source))
        case "Trainer": superCardType = .trainer(data: TrainerCardData())
        case "Energy": superCardType = .energy(data: EnergyCardData())
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
        name = nil
        collection = source.toNativeForm
        superCardType = nil
    }
    /// Adds/remove card to favorites list
    /// - Parameter target: add to (true) or remove from (false) favorites list.
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
    func setNumberOwned(_ target: Int16) {
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
    func addOne() {
        if self.collection != nil {
            let newCount = self.collection!.amount + 1
            // ~= is contains
            guard 0...999 ~= newCount else {return}
            self.setNumberOwned(newCount)
        }
    }
    /// Checks if this card features the Pokémon with the specified National Pokédex number.
    /// - Parameter dex: the Pokédex number.
    /// - Returns: true if a Pokémon card and includes the specified Pokémon.
    func isOfPokedex(_ dex: Int) -> Bool {
        switch self.superCardType {
        case .pokemon(data: let data): return data.dex?.contains(dex) ?? false
        default: return false
        }
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
