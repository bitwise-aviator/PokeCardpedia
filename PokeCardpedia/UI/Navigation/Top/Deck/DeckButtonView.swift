//
//  DeckButtonView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/29/23.
//

import Foundation
import SwiftUI

struct DeckButtonView: View {
    @ObservedObject var core = Core.core
    init (from deck: Deck) {
        self.deck = deck
    }
    var deck: Deck
    var body: some View {
        HStack {
            MenuThumbnailImage()
            Text(deck.name)
                .font(.system(.title3, design: .rounded))
                .bold()
        }.onTapGesture {
            // core.setActiveSet(set: elem)
        }
    }
}
