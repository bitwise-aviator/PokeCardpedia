//
//  MenuThumbnailImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation
import SwiftUI
import NukeUI

struct MenuThumbnailImage: View {
    var url: URL?
    
    @ViewBuilder
    var body: some View {
        LazyImage(request: ImageRequest(url: url)) { state in
            if let image = state.image {
                image.resizable().scaledToFit().frame(width: 50, height: 50)
            } else if state.error != nil {
                Image("CardBackError").resizable().scaledToFit().frame(width: 50, height: 50)
            } else {
                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
            }
        }
    }
}
