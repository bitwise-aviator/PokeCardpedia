//
//  CardLargeImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation
import SwiftUI
import NukeUI

/// A view showing a detailed card image.
struct CardLargeImage: View {
    /// Image source URL.
    var url: URL?
    @ViewBuilder
    /// View body.
    var body: some View {
        LazyImage(request: ImageRequest(url: url)) { state in
            if let image = state.image {
                image.resizable().padding(.all).scaledToFit()
            } else if state.error != nil {
                Image("CardBackError").resizable().padding(.all).scaledToFit()
            } else {
                Image("CardBack").resizable().padding(.all).scaledToFit()
            }
        }
    }
}
