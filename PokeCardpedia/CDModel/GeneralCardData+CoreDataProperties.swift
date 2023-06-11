//
//  GeneralCardData+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/10/23.
//
//

import Foundation
import CoreData


extension GeneralCardData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneralCardData> {
        return NSFetchRequest<GeneralCardData>(entityName: "GeneralCardData")
    }

    @NSManaged public var dataVersion: String?
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var rarity: String?
    @NSManaged public var set: String?
    @NSManaged public var setNumber: String?
    @NSManaged public var supertype: String?
    @NSManaged public var legalName: String?
    @NSManaged public var collection: NSSet?
    @NSManaged public var energyData: EnergyData?
    @NSManaged public var pokemonData: PokemonData?
    @NSManaged public var trainerData: TrainerData?

}

// MARK: Generated accessors for collection
extension GeneralCardData {

    @objc(addCollectionObject:)
    @NSManaged public func addToCollection(_ value: CollectionTracker)

    @objc(removeCollectionObject:)
    @NSManaged public func removeFromCollection(_ value: CollectionTracker)

    @objc(addCollection:)
    @NSManaged public func addToCollection(_ values: NSSet)

    @objc(removeCollection:)
    @NSManaged public func removeFromCollection(_ values: NSSet)

}

extension GeneralCardData : Identifiable {

}
