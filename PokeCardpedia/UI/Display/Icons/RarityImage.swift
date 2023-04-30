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
        case "promo": HStack(spacing: 2) {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
            Text("P").font(.system(size: 10, weight: .bold))
        }
        case "rare secret": HStack(spacing: 2) {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
            Text("S").font(.system(size: 10, weight: .bold))
        }
        case "rare holo": HStack(spacing: 2) {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: 10, height: 10)
            Text("H").font(.system(size: 10, weight: .bold))
        }
        case nil: Image(systemName: "questionmark.app").resizable().scaledToFit().frame(width: 10, height: 10)
        default: Image(systemName: "star").resizable().scaledToFit().frame(width: 10, height: 10)
        }
    }
}
