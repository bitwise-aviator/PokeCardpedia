//
//  TopLevelListView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/29/23.
//

import Foundation
import SwiftUI
import NavigationStack

struct TopLevelListView: View {
    @Binding var userNameAlertActive: Bool
    @Binding var activeFirstLevel: String?
    // WARNING!
    // Do NOT observe Core here. Use ad-hoc bindings instead.
    @ViewBuilder
    var body: some View {
        NavigationStackView {
            List {
                CollectionLockView()
                UsernameView(userNameSelectionActive: $userNameAlertActive)
                ForEach(TopLevelItems.myCollection, id: \.id) { elem in
                    CollectionMenuItemView(id: elem.id, activeFirstLevel: $activeFirstLevel)
                }
                ForEach(TopLevelItems.myDecks, id: \.id) { elem in
                    DeckMenuItemView(id: elem.id, activeFirstLevel: $activeFirstLevel)
                }
                ForEach(TopLevelItems.sets, id: \.id) { elem in
                    SetMenuItemView(id: elem.id, activeFirstLevel: $activeFirstLevel)
                }
                Section(header: Text("Species")) {
                    ForEach(TopLevelItems.pokedex, id: \.id) { elem in
                        PushView(destination: DexSubMenuView(region: elem.id, activeFirstLevel: $activeFirstLevel),
                                 tag: elem.name, selection: $activeFirstLevel) {
                            HStack {
                                MenuThumbnailImage(url: elem.imageURL)
                                Text(elem.name)
                                    .font(.system(.title3, design: .rounded))
                                    .bold()
                            }
                        }
                    }
                }
            }
        }
    }
}
