//
//  CardLargeImage.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/22/23.
//

import Foundation
import SwiftUI
import NukeUI

struct CardLargeImage: View {
    var url: URL?
    @ViewBuilder
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
