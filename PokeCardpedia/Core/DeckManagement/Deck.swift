//
//  Deck.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/27/23.
//

import Foundation

enum DeckBuildIssue {
    case tooManyCardsWithSameName(limit: Int, actual: Int)
    case missingPreviousEvolution
    case notEnoughEnergyForAttack(missingEnergies: [Element])
    case categoryAbsoluteLimitExceeded(limit: Int, actual: Int)
}

extension [Card] {
    func groupById() -> [String: [Card]] {
        var result = [String: [Card]]()
        for item in self {
            result[item.sortId] = (result[item.sortId] ?? []) + [item]
        }
        return result
    }
    
    func groupByName() -> [String: [Card]] {
        var result = [String: [Card]]()
        for item in self {
            guard let name = item.legalName else {
                result[""] = (result[""] ?? []) + [item]
                continue
            }
            result[name] = (result[name] ?? []) + [item]
        }
        return result
    }
    
    func allAreBasicEnergies() -> Bool {
        return self.allSatisfy({
            switch $0.superCardType {
            case .energy(let data):
                if let subtypes = data.subtypes, subtypes.contains(.basic) {
                    return true
                }
                return false
            default: return false
            }
        })
    }
    
    func hasABasicPokemon() -> Bool {
        return self.contains(where: {
            switch $0.superCardType {
            case .pokemon(let data):
                if let subtypes = data.subtypes, subtypes.contains(.basic) {
                    return true
                }
            default: ()
            }
            return false
        })
        
    }
}

class Deck: ObservableObject, Identifiable {
    let id: UUID
    @Published var name: String
    @Published var contents: [Card]
    
    // Standardization for deck-checking: flag should return `true` if compliant and `false` if not.
    // MARK: Deck-wide failable issues.
    // These will not highlight specific cards, but will flag the whole deck as non-compliant.
    var deckSizeIsLegal: Bool {
        contents.count == 60
    }
    var hasBasicPokemon: Bool {
        return true
    }
    
    // MARK: Card-specific failable issues.
    // These will flag specific cards that are within the deck's contents.
    var noIllegalDuplicates: (check: Bool, highlight: [Int: DeckBuildIssue]?) {
        let names = contents.groupByName()
        var highlights = [Int: DeckBuildIssue]()
        names.forEach( {key, value in
            if value.count > 4 && !value.allAreBasicEnergies() {
                for (idx, item) in contents.enumerated() {
                    if item.legalName == key {
                        highlights[idx] = .tooManyCardsWithSameName(limit: 4, actual: value.count)
                    }
                }
            }
        })
        return highlights.isEmpty ? (check: false, highlight: nil) : (check: true, highlight: highlights)
    }
    
    /// Returns indices of cards flagged by error checker and reasons for doing so.
    var highlighted: [Int: [DeckBuildIssue]] {
        [Int: [DeckBuildIssue]]()
    }
    /// Initialize as new deck
    init() {
        id = UUID()
        name = ""
        contents = []
    }
    /// Initialize from CoreData record
    init(source: Data) {
        // TODO: Replace.
        id = UUID()
        name = ""
        contents = []
    }
    func addTo(card: Card) {
        if contents.count <= 99 {
            contents.append(card)
        }
    }
    func addTo(cards: [Card]) {
        if contents.count + cards.count <= 100 {
            contents.append(contentsOf: cards)
        }
    }
    
    func removeFrom(card: Card) {
        if let idx = contents.firstIndex(where: { $0.sortId == card.sortId }) {
            contents.remove(at: idx)
        }
    }
    
    func removeFrom(cards: [Card]) {
        for card in cards {
            removeFrom(card: card)
        }
    }
}
