//
//  SetButtonView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/23/23.
//

import Foundation
import SwiftUI

struct SetButtonView: View {
    @ObservedObject var core = Core.core
    init (from elem: SetFromJson) {
        self.elem = elem
    }
    var elem: SetFromJson
    var body: some View {
        HStack {
            MenuThumbnailImage(url: URL(string: elem.images.symbol))
            Text(elem.name)
                .font(.system(.title3, design: .rounded))
                .bold()
        }.onTapGesture {
            core.setActiveSet(set: elem)
        }
    }
}

struct SetButtonGroup: View {
    let groupBy: SetOrder
    let contents: [SetFromJson]
    let groupName: String
    @ObservedObject var core = Core.core
    var body: some View {
        List(selection: $core.activeSet) {
            Section {
                ForEach(Array(contents.enumerated()), id: \.element) { _, elem in
                    SetButtonView(from: elem)
                }
            } header: {
                Text(groupName)
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
        }
    }
}
