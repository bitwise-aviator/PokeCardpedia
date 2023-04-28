//
//  RarityImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/26/23.
//

import Foundation
import SwiftUI
import NukeUI

/// A view showing a rarity icon.
struct RarityImage: View {
    /// Rarity
    var rarity: String?
    @ViewBuilder
    /// View body.
    var body: some View {
        switch rarity?.lowercased() {
        case "common": Image(systemName: "circle.fill").resizable().scaledToFit().frame(width: 10, height: 10)
        case "uncommon": Image(systemName: "diamond.fill").resizable().scaledToFit().frame(width: 10, height: 10)
        case "rare": Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
        case "promo": HStack {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
            Text("P").fontWeight(.bold).scaledToFit().frame(width: 10, height: 10)
        }
        case "rare secret": HStack {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
            Text("S").fontWeight(.bold).scaledToFit().frame(width: 10, height: 10)
        }
        case "rare holo": HStack {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
            Text("H").fontWeight(.bold).scaledToFit().frame(width: 10, height: 10)
        }
        case nil: Image(systemName: "questionmark.app").resizable().scaledToFit().frame(width: 10, height: 10)
        default: Image(systemName: "star").resizable().scaledToFit().frame(width: 10, height: 10)
        }
    }
}
