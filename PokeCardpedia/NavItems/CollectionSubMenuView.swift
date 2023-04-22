//
//  CollectionSubMenuView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/13/23.
//

import SwiftUI
import NavigationStack

struct CollectionSubMenuView: View {
    @ObservedObject var core = Core.core
    
    @ViewBuilder
    var body: some View {
        VStack {
            BackButtonView(text: "Main menu")
            List(selection: $core.viewMode) {
                ForEach(SecondLevelItems.myCollection, id: \.id) { elem in
                    HStack {
                        Image(systemName: elem.imagePath).resizable().scaledToFit().frame(width: 50, height: 50)
                        Text(elem.name)
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }
                    .onTapGesture {
                        core.setNonSetViewModeAsActive(target: elem.id)
                    }
                }
            }
        }
    }
}

struct CollectionSubMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionSubMenuView()
    }
}
