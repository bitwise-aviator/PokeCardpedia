//
//  Sprites.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/10/23.
//

import Foundation

func getPokemonSpritePath(dex: Int) -> URL {
    return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(dex).png")!
}
