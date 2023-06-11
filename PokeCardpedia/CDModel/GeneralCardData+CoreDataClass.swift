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
        self.dataVersion = DataModelVersion.current
        self.id = card.id
        self.set = card.setCode
        self.setNumber = card.setNumber
        self.name = card.name
        self.legalName = card.legalName
        self.rarity = card.rarity
        self.supertype = card.superCardType?.typeToString
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
