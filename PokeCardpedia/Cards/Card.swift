//
//  Card.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation
import pokemon_tcg_sdk_swift

class Card: ObservableObject {
    static let sortRegex = /(?<prefix>[A-Z]*)(?<number>[0-9]+)(?<suffix>[A-Z]*)/
    static let setNumberFromIdRegex = /[a-zA-Z0-9]+-(?<number>[a-zA-Z0-9]+)/
    let id: String
    let setCode: String
    let setNumber: String
    let imagePaths: CardImageUrl
    var dex: [Int]?
    lazy var imageDataSmall: Data? = {
        nil
    }()
    lazy var imageDataLarge: Data? = {
        nil
    }()
    var sortId: String {
        let match = setNumber.firstMatch(of: Card.sortRegex)
        guard let match else {return "\(setCode)-\(setNumber)"}
        let formattedNumber = String(format: "%03d", Int(match.output.number)!)
        return String("\(setCode)-\(match.output.prefix)\(formattedNumber)\(match.output.suffix)")
    }
    var setIconUrl: URL? {
        return URL(string: "https://images.pokemontcg.io/\(setCode)/symbol.png")
    }
    @Published var collection: CardCollectionData?
    init(from source: CardFromJson) {
        id = source.id
        setCode = source.set.id
        setNumber = source.number
        imagePaths = CardImageUrl(pathObject: source.images)
        collection = nil
        dex = source.nationalPokedexNumbers
    }
    // init? is a failable initializer, where nil can be returned if initalization cannot be completed,
    // such as a guard statement triggering.
    init?(from source: CollectionTracker) {
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
        collection = source.toNativeForm
        dex = nil
    }
    func setFavorite(_ target: Bool) {
        if var newCollection = collection {
            newCollection.favorite = target
            let success = PersistenceController.shared.patchCard(self, with: newCollection)
            if success {
                collection = newCollection
            }
        }
    }
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
    func addOne() {
        if self.collection != nil {
            let newCount = self.collection!.amount + 1
            // ~= is contains
            guard 0...999 ~= newCount else {return}
            self.setNumberOwned(newCount)
        }
    }
}

/*
protocol Card: ObservableObject {
    // Objective-C Interface: list properties and functions only.
    var id: String {get}
    var setCode: String {get}
    var setNumber: String {get}
    // Image
    var imagePaths: CardImageUrl {get}
    var imageDataSmall: Data? {get set}
    var imageDataLarge: Data? {get set}
    var collection: CardCollectionData? {get set}
}

extension Card {
    // Objective-C Implementation: if providing default property values or function bodies, do so here.
    func setFavorite(_ target: Bool) {
        if var newCollection = collection {
            newCollection.favorite = target
            let success = PersistenceController.shared.patchCard(self)
            if success {
                collection = newCollection
            }
        }
    }
    
    func setWantIt(_ target: Bool) {
        if var newCollection = collection {
            newCollection.wantIt = target
            let success = PersistenceController.shared.patchCard(self)
            if success {
                collection = newCollection
            }
            print(target, success)
        }
    }
    
    func setNumberOwned(_ target: Int16) {
        if var newCollection = collection, target >= 0 {
            newCollection.amount = target
            let success = PersistenceController.shared.patchCard(self)
            if success {
                collection = newCollection
            }
        }
    }
}
*/

struct CardCollectionData {
    var favorite: Bool = false
    var wantIt: Bool = false
    var amount: Int16 = 0
}
