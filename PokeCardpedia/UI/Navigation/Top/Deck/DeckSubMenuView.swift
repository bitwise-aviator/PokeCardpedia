//
//  DeckSubMenuView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/29/23.
//

import Foundation
import SwiftUI

struct DeckSubMenuView: View {
    @Binding var activeFirstLevel: String?
    @ObservedObject var core = Core.core
    @ViewBuilder
    var body: some View {
        VStack {
            BackButtonView(text: "Main menu")
            List {
                Text("The deck builder is currently being developed. Stay tuned :)")
            }
        }
    }
}
