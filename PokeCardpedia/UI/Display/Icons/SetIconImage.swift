//
//  SetIconImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/26/23.
//

import Foundation
import SwiftUI
import NukeUI

/// A view showing a small set icon.
struct SetIconImage: View {
    /// Source URL.
    var url: URL?
    var dimension: CGFloat = 10
    @ViewBuilder
    /// View body.
    var body: some View {
        LazyImage(request: ImageRequest(url: url)) { state in
            if let image = state.image {
                image.resizable().scaledToFit().frame(width: dimension, height: dimension)
            } else if state.error != nil {
                Image(systemName: "questionmark.app.fill")
                    .resizable().foregroundColor(.red).scaledToFit().frame(width: dimension, height: dimension)
            } else {
                Image(systemName: "questionmark.app.fill")
                    .resizable().scaledToFit().frame(width: dimension, height: dimension)
            }
        }
    }
}
