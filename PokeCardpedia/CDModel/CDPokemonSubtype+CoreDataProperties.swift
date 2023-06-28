//
//  CDPokemonSubtype+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData


extension CDPokemonSubtype {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPokemonSubtype> {
        return NSFetchRequest<CDPokemonSubtype>(entityName: "CDPokemonSubtype")
    }

    @NSManaged public var id: String?
    @NSManaged public var pokemon: NSSet?

}

// MARK: Generated accessors for pokemon
extension CDPokemonSubtype {

    @objc(addPokemonObject:)
    @NSManaged public func addToPokemon(_ value: PokemonData)

    @objc(removePokemonObject:)
    @NSManaged public func removeFromPokemon(_ value: PokemonData)

    @objc(addPokemon:)
    @NSManaged public func addToPokemon(_ values: NSSet)

    @objc(removePokemon:)
    @NSManaged public func removeFromPokemon(_ values: NSSet)

}

extension CDPokemonSubtype : Identifiable {

}
