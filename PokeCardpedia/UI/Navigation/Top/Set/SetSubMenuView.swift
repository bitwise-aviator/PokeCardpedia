//
//  SetSubMenuView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/29/23.
//

import Foundation
import SwiftUI

struct SetSubMenuView: View {
    @Binding var activeFirstLevel: String?
    @ObservedObject var core = Core.core
    @ViewBuilder
    var body: some View {
        VStack {
            BackButtonView(text: "Main menu")
            List(selection: $core.activeSet) {
                if let sets = core.sets {
                    ForEach(Array(sets.enumerated()), id: \.element) { _, elem in
                        SetButtonView(from: elem)
                    }
                }
            }
        }
    }
}

