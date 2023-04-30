//
//  TrainerCardData.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation

/// Stores data specific to Trainer cards. To be only used inside a `SuperCardType.trainer` enum instance.
struct TrainerCardData {
    /// Subtypes (Supporter, Tool, Stadium, etc.)
    let subtypes: [TrainerSubtype]?
    ///
    init(from source: CardFromJson) {
        subtypes = source.subtypes?.compactMap({value in
            guard let result = TrainerSubtype(rawValue: value.lowercased()) else {
                print("Could not match trainer subtype \(value) to enum.")
                return nil
            }
            return result
        })
    }
}
