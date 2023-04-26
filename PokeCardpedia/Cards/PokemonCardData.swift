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
    
    init(from source: CardFromJson) {
        dex = source.nationalPokedexNumbers
    }
    
    init(dex: [Int]?) {
        self.dex = dex
    }
}
