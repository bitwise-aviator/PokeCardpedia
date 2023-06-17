//
//  User+CoreDataProperties.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/11/23.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var ident: UUID
    @NSManaged public var name: String?
    @NSManaged public var sprite: String?
    @NSManaged public var trackers: NSSet?

}

// MARK: Generated accessors for trackers
extension UserInfo {

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: CollectionTracker)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: CollectionTracker)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)

}

extension UserInfo : Identifiable {

}
