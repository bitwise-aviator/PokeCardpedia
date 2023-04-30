//
//  DeckMenuItemView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/29/23.
//

import SwiftUI
import NavigationStack

struct DeckMenuItemView: View {
    let id: String
    @Binding var activeFirstLevel: String?
    var body: some View {
        PushView(destination: DeckSubMenuView(activeFirstLevel: $activeFirstLevel),
                 tag: id, selection: $activeFirstLevel) {
            HStack {
                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                Text("Decks")
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
        }
    }
}

struct DeckMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        DeckMenuItemView(id: "", activeFirstLevel: .constant(""))
    }
}
