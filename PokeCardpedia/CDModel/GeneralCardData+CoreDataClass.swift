//
//  GeneralCardData+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/10/23.
//
//

import Foundation
import CoreData

@objc(GeneralCardData)
public class GeneralCardData: NSManagedObject {
    
    func updateFromCard(card: Card) {
        let context = PersistenceController.context
        // Hold on to previous data version if needing to roll back.
        let previousDataVersion = self.dataVersion
        self.dataVersion = DataModelVersion.current
        self.id = card.id
        self.set = card.setCode
        self.setNumber = card.setNumber
        self.name = card.name
        self.legalName = card.legalName
        self.rarity = card.rarity
        self.supertype = card.superCardType?.typeToString
        switch card.superCardType {
        case .pokemon(data: let data):
            if self.pokemonData == nil {
                self.pokemonData = PokemonData(context: context)
            }
            self.pokemonData?.hitPoints = Int64(data.hitPoints ?? 0)
            let dexArray = (data.dex ?? []).compactMap({ number in
                DexNumber.getByNumber(number, in: context)
            })
            self.pokemonData?.safelyAddToDex(dexArray)
            let typeArray = (data.types ?? []).compactMap({ pokemonType in
                CDElement.getOfElement(pokemonType, in: context)
            })
            if typeArray.count < (data.types?.count ?? 0) {
                print("Failed to convert all Pókemon types correctly for \(card.id).")
                print("This likely means an enum entry is missing. Model compliance rolled back to v\(previousDataVersion).")
                self.dataVersion = previousDataVersion
            }
            self.pokemonData?.safelyAddToTypes(typeArray)
            
            let subtypeArray = (data.subtypes ?? []).compactMap({ pokemonSubtype in
                CDPokemonSubtype.getOfSubtype(pokemonSubtype, in: context)
            })
            if subtypeArray.count < (data.subtypes?.count ?? 0) {
                print("Failed to convert all Pókemon subtypes correctly for \(card.id).")
                print("This likely means an enum entry is missing. Model compliance rolled back to v\(previousDataVersion).")
                self.dataVersion = previousDataVersion
            }
            self.pokemonData?.safelyAddToSubtypes(subtypeArray)
        default: ()
        }
    }
    
    var isCurrent: Bool {
        DataModelVersion.validateCurrentVersion(self)
    }
    
    func addUnboundTrackers(context: NSManagedObjectContext, autoAdd: Bool = true) {
        // Only for dataset migration, i.e. when generating a new GeneralCardData; do not run on new builds.
        let query = CollectionTracker.fetchRequest()
        query.predicate = NSPredicate(format: "id = %@", self.id)
        let results: [CollectionTracker]
        do {
            results = try context.fetch(query)
            guard !results.isEmpty else {
                print("Found no trackers for id: \(self.id)")
                return
            }
        } catch {
            print(error)
            return
        }
        if autoAdd {
            for tracker in results {
                guard !tracker.objectID.isTemporaryID else { continue }
                self.addToCollection(tracker)
            }
        }
    }
}
