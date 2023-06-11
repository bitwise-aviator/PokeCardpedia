//
//  CardIO.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 5/26/23.
//

import Foundation
import CoreData

enum IOError: Error {
    case fetch
    case badTracker
    case dupe
}

/// Use to track which CoreData records need to be updated.
struct DataModelVersion {
    /* Current version: 000.1
    (Versions with 00X.X correspond to beta/intermediate releases.
     Must have:
     - Completed GeneralCardData attributes
     -- dataVersion == 000.1
     -- id, name, rarity, supertype not nil
     - Completed CollectionTracker attributes
     -- amount, favorite, id, set, wantIt not nil
     - GeneralCardData collection relationship populated.
    */
    static let current: String = "000.1"
    static func validateCurrentVersion(_ input: GeneralCardData) -> Bool {
        // Check GeneralCardData completion.
        guard input.id != nil,
              input.set != nil,
              input.setNumber != nil,
                input.name != nil,
                input.rarity != nil,
              input.supertype != nil else {
            print("Card \(input.id) does not match current version - empty parameters")
            print(input.id)
            print(input.set)
            print(input.setNumber)
            print(input.name)
            print(input.rarity)
            print(input.supertype)
            return false
        }
        // Check existence of a bound collection tracker.
        guard let collection = input.collection?.allObjects as! [CollectionTracker]? else {
            print("Card \(input.id) does not match current version - collection tracker mismatch")
            return false
        }
        do {
            try collection.forEach { tracker in
                guard tracker.id != nil,
                      tracker.set != nil,
                      tracker.id! == input.id,
                      tracker.set! == input.set
                else {
                    print(tracker.id, input.id)
                    print(tracker.set, input.set)
                    throw IOError.badTracker
                }
            }
        } catch {
            print("Card \(input.id) does not match current version - trackers mismatched")
            return false
        }
        return true
    }
    //
}

/*
func matchCardData(of input: [CardFromJson], by query: [SearchType], into target: [String: Card], context: NSManagedObjectContext) throws {
    guard let fetched = context.fetchCards(query) else { throw IOError.fetch
    }
    
}*/
