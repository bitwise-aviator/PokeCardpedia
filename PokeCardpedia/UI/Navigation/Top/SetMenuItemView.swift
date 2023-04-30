//
//  SetMenuItemView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import SwiftUI
import NavigationStack

struct SetMenuItemView: View {
    let id: String
    @Binding var activeFirstLevel: String?
    var body: some View {
        PushView(destination: SetSubMenuView(activeFirstLevel: $activeFirstLevel),
                 tag: id, selection: $activeFirstLevel) {
            HStack {
                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                Text("Sets")
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
        }
    }
}

struct SetMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        SetMenuItemView(id: "", activeFirstLevel: .constant(""))
    }
}
