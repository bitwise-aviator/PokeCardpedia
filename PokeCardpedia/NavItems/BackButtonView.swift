//
//  BackButtonView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import SwiftUI
import NavigationStack

struct BackButtonView: View {
    let text: String
    var body: some View {
        PopView(destination: .root) {
            HStack {
                Image(systemName: "arrow.left").resizable().scaledToFit().frame(width: 20, height: 20)
                Text(text)
                    .font(.system(.title3, design: .rounded)).foregroundColor(.red)
                    .bold()
            }
        }
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        BackButtonView(text: "Main menu")
    }
}
