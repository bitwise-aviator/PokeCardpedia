//
//  Padlock.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation

/// Determines whether user can edit collection or not.
class Padlock: ObservableObject {
    /// Singleton instance.
    static let lock = Padlock()
    /// Lock's current status. Use `setLock` method to change.
    @Published private(set) var isLocked: Bool // defines whether edits are allowed.
    /// Sets the lock's value to a new target setting.
    /// - Parameter target: Locked (true), unlocked (false). Will toggle if `nil` (default).
    func setLock(to target: Bool? = nil) {
        if let target {
            isLocked = target
        } else {
            isLocked.toggle()
        }
    }
    /// Initializes the singleton.
    private init() {
        isLocked = true
    }
}
