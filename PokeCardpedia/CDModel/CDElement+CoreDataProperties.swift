//
//  CDElement+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData


extension CDElement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDElement> {
        return NSFetchRequest<CDElement>(entityName: "CDElement")
    }

    @NSManaged public var id: String?
    @NSManaged public var pokemon: NSSet?

}

// MARK: Generated accessors for pokemon
extension CDElement {

    @objc(addPokemonObject:)
    @NSManaged public func addToPokemon(_ value: PokemonData)

    @objc(removePokemonObject:)
    @NSManaged public func removeFromPokemon(_ value: PokemonData)

    @objc(addPokemon:)
    @NSManaged public func addToPokemon(_ values: NSSet)

    @objc(removePokemon:)
    @NSManaged public func removeFromPokemon(_ values: NSSet)

}

extension CDElement : Identifiable {

}
