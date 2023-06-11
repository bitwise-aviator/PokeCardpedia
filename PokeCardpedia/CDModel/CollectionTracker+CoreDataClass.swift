//
//  CollectionTracker+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 5/13/23.
//
//

import Foundation
import CoreData

@objc(CollectionTracker)
public class CollectionTracker: NSManagedObject {
    @MainActor func modify(amount: Int16? = nil, favorite: Bool? = nil, wantIt: Bool? = nil, fromUI: Bool = true) {
        if let amount { self.amount = amount }
        if let favorite { self.favorite = favorite }
        if let wantIt { self.wantIt = wantIt }
        
        if self.managedObjectContext?.hasChanges == true {
            do {
                try self.managedObjectContext!.save()
            } catch {
                print(error)
            }
        }
        if fromUI {
            Core.core.updateActiveCounters()
        }
    }
}
