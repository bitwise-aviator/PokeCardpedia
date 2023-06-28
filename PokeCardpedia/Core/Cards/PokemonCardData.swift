//
//  PokemonCardData.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/12/23.
//

import Foundation

enum PokemonSubtype: String {
    case basic
    case stage1 = "stage 1"
    case stage2 = "stage 2"
    case ex // swiftlint:disable:this identifier_name
    case teraEx = "tera ex"
    case radiant
    case v // swiftlint:disable:this identifier_name
    case vmax
    case vstar
    case fusionStrike = "fusion strike"
    case singleStrike = "single strike"
    case rapidStrike = "rapid strike"
    case levelUp = "level-up"
    case star
    case baby
    case mega
    case prime
    case legend
    case sp // swiftlint:disable:this identifier_name
    case tera
    case vUnion = "v-union"
}

/// Stores data specific to Pokémon cards. To be only used inside a `SuperCardType.pokemon` enum instance.
struct PokemonCardData {
    /// National Pokédex number(s)
    let dex: [Int]?
    /// Pokémon types (elements)
    let types: [Element]?
    /// Subtypes (Basic, Stage 1, Stage 2)
    let subtypes: [PokemonSubtype]?
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
        subtypes = source.subtypes?.compactMap({value in
            guard let result = PokemonSubtype(rawValue: value.lowercased()) else {
                print("Could not match pokemon subtype \(value) to enum.")
                return nil
            }
            return result
        })
        hitPoints = Int(source.hp ?? "")
    }
    init(fromPersist source: PokemonData) {
        dex = (source.dex?.allObjects as? [DexNumber])?.compactMap({Int($0.id)})
        types = (source.types?.allObjects as? [CDElement])?.compactMap({Element(rawValue: $0.id ?? "")})
        subtypes = (source.subtypes?.allObjects as? [CDPokemonSubtype])?.compactMap({PokemonSubtype(rawValue: $0.id ?? "")})
        hitPoints = source.hitPoints != 0 ? Int(source.hitPoints) : nil
    }
    
    init(dex: [Int]?) {
        self.dex = dex
        types = nil
        subtypes = nil
        hitPoints = nil
    }
}
