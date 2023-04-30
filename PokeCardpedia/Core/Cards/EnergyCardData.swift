//
//  EnergyCardData.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation

enum EnergySubtype: String {
    case basic
    case special
    case teamPlasma = "team plasma"
}

/// Stores data specific to Energy cards. To be only used inside a `SuperCardType.energy` enum instance.
struct EnergyCardData {
    /// Subtypes (Basic/Special)
    let subtypes: [EnergySubtype]?
    ///
    init(from source: CardFromJson) {
        subtypes = source.subtypes?.compactMap({value in
            guard let result = EnergySubtype(rawValue: value.lowercased()) else {
                print("Could not match energy subtype \(value) to enum.")
                return nil
            }
            return result
        })
    }
}
