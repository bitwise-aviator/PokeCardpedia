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
    var dimension: CGFloat = 10
    @ViewBuilder
    /// View body.
    var body: some View {
        switch rarity?.lowercased() {
        case "common": Image(systemName: "circle.fill").resizable().scaledToFit().frame(width: dimension, height: dimension)
        case "uncommon": Image(systemName: "diamond.fill").resizable().scaledToFit().frame(width: dimension, height: dimension)
        case "rare": Image(systemName: "star.fill").resizable().scaledToFit().frame(width: dimension, height: dimension)
        case "promo": HStack(spacing: 2) {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: dimension, height: dimension)
            Text("P").font(.system(size: dimension, weight: .bold))
        }
        case "rare secret": HStack(spacing: max(2, dimension / 5)) {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: dimension, height: dimension)
            Text("S").font(.system(size: dimension, weight: .bold))
        }
        case "rare holo": HStack(spacing: max(2, dimension / 5)) {
            Image(systemName: "star.fill").resizable().scaledToFit().frame(width: dimension, height: dimension)
            Text("H").font(.system(size: dimension, weight: .bold))
        }
        case nil: Image(systemName: "questionmark.app").resizable().scaledToFit().frame(width: dimension, height: dimension)
        default: Image(systemName: "star").resizable().scaledToFit().frame(width: dimension, height: dimension)
        }
    }
}
