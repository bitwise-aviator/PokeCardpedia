//
//  CardThumbnailImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation
import SwiftUI
import NukeUI

struct CardThumbnailImage: View {
    var card: Card
    var haveIt: Bool
    @Binding var activeImage: String
    @Binding var imageDetailShown: Bool
    
    @ViewBuilder
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
