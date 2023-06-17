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
    @NSManaged public var owner: UserInfo?
    
    convenience init(context: NSManagedObjectContext, card: Card, amount: Int16 = 0, favorite: Bool = false, wantIt: Bool = false, user: UserInfo) {
        self.init(context: context)
        self.amount = amount
        self.favorite = favorite
        self.wantIt = wantIt
        id = card.id
        set = card.setCode
        if let cardId = card.persistentId {
            cardDetails = context.object(with: cardId) as? GeneralCardData
        }
        owner = user
    }

}

extension CollectionTracker : Identifiable {

}
