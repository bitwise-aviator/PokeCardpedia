//
//  PokemonData+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData


extension PokemonData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonData> {
        return NSFetchRequest<PokemonData>(entityName: "PokemonData")
    }

    @NSManaged public var hitPoints: Int64
    @NSManaged public var dex: NSSet?
    @NSManaged public var root: GeneralCardData?
    @NSManaged public var subtypes: NSSet?
    @NSManaged public var types: NSSet?

}

// MARK: Generated accessors for dex
extension PokemonData {

    @objc(addDexObject:)
    @NSManaged public func addToDex(_ value: DexNumber)

    @objc(removeDexObject:)
    @NSManaged public func removeFromDex(_ value: DexNumber)

    @objc(addDex:)
    @NSManaged public func addToDex(_ values: NSSet)

    @objc(removeDex:)
    @NSManaged public func removeFromDex(_ values: NSSet)
    
    public func safelyAddToDex(_ values: [DexNumber]) {
        addToDex(NSSet(array: values))
    }
    
    public func safelyRemoveFromDex(_ values: [DexNumber]) {
        removeFromDex(NSSet(array: values))
    }

}

// MARK: Generated accessors for subtypes
extension PokemonData {

    @objc(addSubtypesObject:)
    @NSManaged public func addToSubtypes(_ value: CDPokemonSubtype)

    @objc(removeSubtypesObject:)
    @NSManaged public func removeFromSubtypes(_ value: CDPokemonSubtype)

    @objc(addSubtypes:)
    @NSManaged public func addToSubtypes(_ values: NSSet)

    @objc(removeSubtypes:)
    @NSManaged public func removeFromSubtypes(_ values: NSSet)
    
    public func safelyAddToSubtypes(_ values: [CDPokemonSubtype]) {
        addToSubtypes(NSSet(array: values))
    }
    
    public func safelyRemoveFromSubtypes(_ values: [CDPokemonSubtype]) {
        removeFromSubtypes(NSSet(array: values))
    }
}

// MARK: Generated accessors for types
extension PokemonData {

    @objc(addTypesObject:)
    @NSManaged public func addToTypes(_ value: CDElement)

    @objc(removeTypesObject:)
    @NSManaged public func removeFromTypes(_ value: CDElement)

    @objc(addTypes:)
    @NSManaged public func addToTypes(_ values: NSSet)

    @objc(removeTypes:)
    @NSManaged public func removeFromTypes(_ values: NSSet)
    
    public func safelyAddToTypes(_ values: [CDElement]) {
        addToTypes(NSSet(array: values))
    }
    
    public func safelyRemoveFromTypes(_ values: [CDElement]) {
        removeFromTypes(NSSet(array: values))
    }

}

extension PokemonData : Identifiable {

}
