//
//  Deck.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/27/23.
//

import Foundation

extension [Card] {
    func tabulate() -> [String: Int] {
        var result = [String: Int]()
        for item in self {
            if result[item.sortId] != nil {
                result[item.sortId]! += 1
            } else {
                result[item.sortId] = 1
            }
        }
        return result
    }
}

class Deck: ObservableObject {
    @Published var name: String
    @Published var contents: [Card]
    var deckSizeIsLegal: Bool {
        contents.count == 60
    }
    var noIllegalDuplicates: Bool {
        // let tabulated = contents.tabulate()
        // to be expanded.
        return true
    }
    init() {
        name = ""
        contents = []
    }
    func addCardTo(_ card: Card) {
        if contents.count <= 99 {
            contents.append(card)
        }
    }
    func addCardsTo(_ cards: [Card]) {
        if contents.count + cards.count <= 100 {
            contents.append(contentsOf: cards)
        }
    }
}
