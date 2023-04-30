//
//  CardThumbnailImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation
import SwiftUI
import NukeUI

/// A view showing a small card image.
struct CardThumbnailImage: View {
    /// Source card object, provides URL & collection tracking.
    var card: Card
    /// Whether the user has a positive number of copies of `card`. Used to determine if grayscale applied.
    var haveIt: Bool
    /// When applicable, the card being shown in the `PagerView`.
    @Binding var activeImage: String
    /// Denotes whether the `PagerView` is active.
    @Binding var imageDetailShown: Bool
    @ViewBuilder
    /// View body.
    var body: some View {
        LazyImage(request: ImageRequest(url: card.imagePaths.small)) { state in
            if let image = state.image {
                image.resizable().scaledToFit().saturation(haveIt ? 1.0 : 0.0)
            } else if state.error != nil {
                Image("CardBackError").resizable().scaledToFit()
            } else {
                Image("CardBack").resizable().scaledToFit().saturation(haveIt ? 1.0 : 0.0)
            }
        }.border(activeImage == card.sortId ? Color(uiColor: .systemBlue) : .clear, width: 5).onTapGesture {
            activeImage = card.sortId
            imageDetailShown = true
        }
    }
}
