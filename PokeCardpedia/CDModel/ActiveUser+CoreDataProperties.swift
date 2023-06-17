//
//  ActiveUser+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/11/23.
//
//

import Foundation
import CoreData


extension ActiveUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActiveUser> {
        return NSFetchRequest<ActiveUser>(entityName: "ActiveUser")
    }

    @NSManaged public var active: UserInfo?

}

extension ActiveUser : Identifiable {

}
