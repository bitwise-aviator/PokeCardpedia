//
//  PokemonCardData.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation

/// Stores data specific to Pokémon cards. To be only used inside a `SuperCardType.pokemon` enum instance.
struct PokemonCardData {
    /// National Pokédex number(s)
    let dex: [Int]?
    /// Pokémon types (elements)
    let types: [Element]?
    /// Subtypes (Basic, Stage 1, Stage 2)
    let subtypes: [String]?
    /// Hit points
    let hitPoints: Int?
    init(from source: CardFromJson) {
        dex = source.nationalPokedexNumbers
        types = source.types?.compactMap({value in
            guard let result = Element(rawValue: value.lowercased()) else {
                print("Could not match element \(value) to enum.")
                return nil
            }
            return result
        })
        subtypes = source.subtypes
        hitPoints = Int(source.hp ?? "")
    }
    init(dex: [Int]?) {
        self.dex = dex
        types = nil
        subtypes = nil
        hitPoints = nil
    }
}
