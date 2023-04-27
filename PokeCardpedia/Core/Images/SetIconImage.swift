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
    @ViewBuilder
    /// View body.
    var body: some View {
        LazyImage(request: ImageRequest(url: url)) { state in
            if let image = state.image {
                image.resizable().scaledToFit().frame(width: 10, height: 10)
            } else if state.error != nil {
                Image(systemName: "questionmark.app.fill")
                    .resizable().foregroundColor(.red).scaledToFit().frame(width: 10, height: 10)
            } else {
                Image(systemName: "questionmark.app.fill")
                    .resizable().scaledToFit().frame(width: 10, height: 10)
            }
        }
    }
}
