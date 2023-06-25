//
//  ActiveUser+CoreDataClass.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/11/23.
//
//

import Foundation
import CoreData

class ActiveUserTracker: ObservableObject {
    static let shared = ActiveUserTracker()
    @Published var activeUserId: NSManagedObjectID?
    @Published var activeUserUUID: UUID?
    //
    func getActiveUser() -> Bool {
        guard let activeId = try? ActiveUser.validateAndPurge(),
              let activeUserObject = ActiveUser.context.object(with: activeId) as? ActiveUser,
              let userId = activeUserObject.active?.objectID,
              let userInfo = ActiveUser.context.object(with: userId) as? UserInfo
        else {
            (activeUserId, activeUserUUID) = (nil, nil)
            return false
        }
        (activeUserId, activeUserUUID) = (userId, userInfo.ident)
        print("\(userInfo.name) is the active user...")
        return true
    }
    //
    init() {
        if !getActiveUser() {
            print("Failed to retrieve active user.")
        }
    }
}

@objc(ActiveUser)
public class ActiveUser: NSManagedObject {
    static let context = PersistenceController.context
    //
    static func validateAndPurge(recursive: Int = 1) throws -> NSManagedObjectID {
        var instances: [ActiveUser] = []
        do {
            instances = try context.fetch(ActiveUser.fetchRequest())
        } catch {
            throw error
        }
        if instances.count == 1 {
            print("Found one instance - returning safely")
            return instances.first!.objectID
        } else if instances.count > 1 {
            print("Multiple active user instances found - purging")
            for idx in (1..<(instances.count)) {
                ActiveUser.context.delete(instances[idx])
            }
        } else {
            print("No active user instances found - creating")
            _ = ActiveUser(context: ActiveUser.context)
        }
        print(ActiveUser.context.hasChanges)
        ActiveUser.context.saveIfChanged()
        if recursive == 0 {
            throw UserDataError.ioError
        } else {
            do {
                return try ActiveUser.validateAndPurge(recursive: recursive - 1)
            } catch {
                throw error
            }
        }
    }
    //
    static func makeUserActive(userInfoId: NSManagedObjectID) -> Bool {
        guard let activeUserObjectId = try? validateAndPurge() else {
            return false
        }
        return ActiveUser.context.performAndWait {
            guard let activeUserObject = try? ActiveUser.context.existingObject(with: activeUserObjectId) as? ActiveUser,
                    let newActiveUser = try? ActiveUser.context.existingObject(with: userInfoId) as? UserInfo
            else { return false }
            activeUserObject.active = newActiveUser
            return ActiveUser.context.saveIfChanged()
        }
    }
    
    static func makeUserActive(user: UserInfo) -> Bool {
        return ActiveUser.makeUserActive(userInfoId: user.objectID)
    }
    
    static func renameActiveUser(target: String) -> Bool {
        guard 1...30 ~= target.count else {
            return false
        }
        guard let activeUserObjectId = try? validateAndPurge(),
              let activeUserObject = try? ActiveUser.context.object(with: activeUserObjectId) as? ActiveUser,
              let activeUserData = try? activeUserObject.active
        else {
            return false
        }
        return ActiveUser.context.performAndWait {
            activeUserData.name = target
            print(ActiveUser.context.hasChanges)
            return ActiveUser.context.saveIfChanged()
        }
    }
}
