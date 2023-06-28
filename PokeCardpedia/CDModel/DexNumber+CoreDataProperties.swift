//
//  DexNumber+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData


extension DexNumber {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DexNumber> {
        return NSFetchRequest<DexNumber>(entityName: "DexNumber")
    }

    @NSManaged public var id: Int64
    @NSManaged public var pokemon: NSSet?

}

// MARK: Generated accessors for pokemon
extension DexNumber {

    @objc(addPokemonObject:)
    @NSManaged public func addToPokemon(_ value: PokemonData)

    @objc(removePokemonObject:)
    @NSManaged public func removeFromPokemon(_ value: PokemonData)

    @objc(addPokemon:)
    @NSManaged public func addToPokemon(_ values: NSSet)

    @objc(removePokemon:)
    @NSManaged public func removeFromPokemon(_ values: NSSet)

}

extension DexNumber : Identifiable {

}
