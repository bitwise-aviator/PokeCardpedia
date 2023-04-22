//
//  Padlock.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation

class Padlock: ObservableObject {
    static let lock = Padlock()
    @Published private(set) var isLocked: Bool = true // defines whether edits are allowed.
    func setLock(to target: Bool? = nil) {
        if let target {
            isLocked = target
        } else {
            isLocked.toggle()
        }
    }
}
