//
//  CollectionMenuItemView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import SwiftUI
import NavigationStack

struct CollectionMenuItemView: View {
    let id: String
    @Binding var activeFirstLevel: String?
    @ObservedObject var settings = CoreSettings.settings
    var body: some View {
        PushView(destination: CollectionSubMenuView(),
                 tag: id, selection: $activeFirstLevel) {
            HStack {
                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                Text("\(settings.userNamePossessive) collection")
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
        }
    }
}

struct CollectionMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionMenuItemView(id: "", activeFirstLevel: .constant(""))
    }
}
