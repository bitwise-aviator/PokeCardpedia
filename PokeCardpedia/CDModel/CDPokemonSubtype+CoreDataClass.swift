//
//  CDPokemonSubtype+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/26/23.
//
//

import Foundation
import CoreData

@objc(CDPokemonSubtype)
public class CDPokemonSubtype: NSManagedObject {
    static func getOfSubtype(_ subtype: PokemonSubtype, in context: NSManagedObjectContext, createIfNotFound: Bool = true) -> CDPokemonSubtype? {
        let fetchRequest = CDPokemonSubtype.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", subtype.rawValue)
        guard let fetched = try? context.fetch(fetchRequest) else { return nil }
        if fetched.count == 1 {
            return fetched[0]
        } else if fetched.count > 1 {
            return nil
        } else {
            guard createIfNotFound else {
                return nil
            }
            let newElement = CDPokemonSubtype(context: context)
            newElement.id = subtype.rawValue
            if context.saveIfChanged() {
                return newElement
            } else {
                return nil
            }
        }
    }
}
