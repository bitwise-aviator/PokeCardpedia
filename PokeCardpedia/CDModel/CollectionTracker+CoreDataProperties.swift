//
//  CollectionTracker+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 5/13/23.
//
//

import Foundation
import CoreData


extension CollectionTracker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CollectionTracker> {
        return NSFetchRequest<CollectionTracker>(entityName: "CollectionTracker")
    }

    @NSManaged public var amount: Int16
    @NSManaged public var favorite: Bool
    @NSManaged public var id: String?
    @NSManaged public var set: String?
    @NSManaged public var wantIt: Bool
    @NSManaged public var cardDetails: GeneralCardData?

}

extension CollectionTracker : Identifiable {

}
