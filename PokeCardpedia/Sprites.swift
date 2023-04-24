//
//  Sprites.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/10/23.
//

import Foundation

/// Programmatically determines the URL for Pokémon species' sprites from the PokéAPI.
/// - Parameter dex: the Pokémon species' National Pokédex number (as of 4/2023, 1-1010)
/// - Returns: the URL to the sprite icon.
func getPokemonSpritePath(dex: Int) -> URL {
    return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dex).png")!
}
