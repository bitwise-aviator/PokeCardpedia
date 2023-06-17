//
//  User+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/11/23.
//
//

import Foundation
import CoreData

enum UserDataError: Error {
    case ioError
    case saveError
}

@objc(UserInfo)
public class UserInfo: NSManagedObject {
    static var allUsers: [UserInfo]?
    // Keep all UserInfo handling in the view context.
    static let context = PersistenceController.context
    
    @discardableResult static func getAllUsers() -> Bool {
        do {
            UserInfo.allUsers = try UserInfo.context.fetch(UserInfo.fetchRequest())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func makeUser(_ name: String?, icon: String?, activate: Bool = true) throws -> NSManagedObjectID {
        let uuid = UUID()
        UserInfo.context.performAndWait {
            let newUser = UserInfo(context: UserInfo.context)
            newUser.ident = uuid
            newUser.name = name
            newUser.sprite = icon
        }
        
        print(context.hasChanges)
        guard context.saveIfChanged() else {
            throw UserDataError.saveError
        }
        guard UserInfo.getAllUsers() else {
            throw UserDataError.ioError
        }
        guard let persistedNewUser = UserInfo.allUsers?.first(where: { $0.ident == uuid}) else {
            throw UserDataError.ioError
        }
        if activate {
            if ActiveUser.makeUserActive(user: persistedNewUser) {
                print("Set new user with id \(persistedNewUser.ident) as active")
            } else {
                print("Could not change active user")
            }
        }
        return persistedNewUser.objectID
    }
    
    static func makeFirstUser(_ name: String?, icon: String?) throws -> NSManagedObjectID {
        guard UserInfo.getAllUsers(), let users = UserInfo.allUsers, users.isEmpty else {
            throw UserDataError.ioError
        }
        guard let firstUser = try? makeUser(name, icon: icon) else {
            print("Failed to make first user...")
            throw UserDataError.ioError
        }
        // After new user built correctly, if trackers exist that are not bound to anyone,
        // they are defaulted to that user.
        UserInfo.context.performAndWait {
            let fetchRequest = CollectionTracker.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "owner == nil")
            guard let unownedTrackers = try? UserInfo.context.fetch(fetchRequest), let firstUserObject = try? UserInfo.context.existingObject(with: firstUser) as? UserInfo else {
                return
            }
            firstUserObject.addToTrackers(NSSet(array: unownedTrackers))
            print(UserInfo.context.hasChanges)
            UserInfo.context.saveIfChanged()
        }
        return firstUser
    }
}
