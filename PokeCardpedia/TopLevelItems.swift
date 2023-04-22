//
//  TopLevelItems.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/10/23.
//

import Foundation

enum ImageType {
    case url, icon, asset
}

struct TopLevelMenuItem: Identifiable, Hashable {
    var id: String
    var name: String
    var imageType: ImageType
    var imagePath: String = ""
    var imageURL: URL?
}

struct CollectionMenuItem: Identifiable, Hashable {
    var id: ViewMode
    var name: String
    var imageType: ImageType
    var imagePath: String = ""
    var imageURL: URL?
}

struct PokedexMenuItem: Identifiable, Hashable {
    var id: Region
    var name: String
    var imageType: ImageType
    var imagePath: String = ""
    var imageURL: URL?
}

struct TopLevelItems {
    static var myCollection: [TopLevelMenuItem] = [
        TopLevelMenuItem(id: "collection", name: "Collection", imageType: .asset, imagePath: "CardBack")
    ]
    static var sets: [TopLevelMenuItem] = [
        TopLevelMenuItem(id: "sets", name: "Sets", imageType: .asset, imagePath: "CardBack")
    ]
    static var pokedex: [PokedexMenuItem] = [
        PokedexMenuItem(id: .kanto, name: "Kanto (#1 - #151)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 151)),
        PokedexMenuItem(id: .johto, name: "Johto (#152 - #251)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 251)),
        PokedexMenuItem(id: .hoenn, name: "Hoenn (#252 - #386)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 385)),
        PokedexMenuItem(id: .sinnoh, name: "Sinnoh (#387 - #493)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 493)),
        PokedexMenuItem(id: .unova, name: "Unova (#494 - #649)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 646)),
        PokedexMenuItem(id: .kalos, name: "Kalos (#650 - #721)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 718)),
        PokedexMenuItem(id: .alola, name: "Alola (#722 - #809)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 789)),
        PokedexMenuItem(id: .galar, name: "Galar (#810 - #905)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 890)),
        PokedexMenuItem(id: .paldea, name: "Paldea (#906 - #1010)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 1008))
    ]
}

struct SecondLevelItems {
    static var myCollection: [CollectionMenuItem] = [
        CollectionMenuItem(id: .owned, name: "Collection", imageType: .icon, imagePath: "checkmark"),
        CollectionMenuItem(id: .want, name: "Wishlist", imageType: .icon, imagePath: "star.fill"),
        CollectionMenuItem(id: .favorite, name: "Favorites", imageType: .icon, imagePath: "heart.fill")
    ]
    static var sets: [TopLevelMenuItem] = [
        TopLevelMenuItem(id: "sets", name: "Sets", imageType: .asset, imagePath: "CardBack")
    ]
    static var pokedex: [TopLevelMenuItem] = [
        TopLevelMenuItem(id: "pokedex.kanto", name: "Kanto (#1 - #151)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 151)),
        TopLevelMenuItem(id: "pokedex.johto", name: "Johto (#152 - #251)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 251)),
        TopLevelMenuItem(id: "pokedex.hoenn", name: "Hoenn (#252 - #386)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 385)),
        TopLevelMenuItem(id: "pokedex.sinnoh", name: "Sinnoh (#387 - #493)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 493)),
        TopLevelMenuItem(id: "pokedex.unova", name: "Unova (#494 - #649)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 646)),
        TopLevelMenuItem(id: "pokedex.kalos", name: "Kalos (#650 - #721)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 718)),
        TopLevelMenuItem(id: "pokedex.alola", name: "Alola (#722 - #809)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 789)),
        TopLevelMenuItem(id: "pokedex.galar", name: "Galar (#810 - #905)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 890)),
        TopLevelMenuItem(id: "pokedex.paldea", name: "Paldea (#906 - #1010)",
                         imageType: .url, imageURL: getPokemonSpritePath(dex: 1008))
    ]
}
