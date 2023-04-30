//
//  DexSubMenuView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/29/23.
//

import Foundation
import SwiftUI

struct DexSubMenuView: View {
    let region: Region
    @Binding var activeFirstLevel: String?
    @ObservedObject var core = Core.core
    func getRange() -> ClosedRange<Int> {
        switch region {
        case .kanto:
            return 1...151
        case .johto:
            return 152...251
        case .hoenn:
            return 252...386
        case .sinnoh:
            return 387...493
        case .unova:
            return 494...649
        case .kalos:
            return 650...721
        case .alola:
            return 722...809
        case .galar:
            return 810...905
        case .paldea:
            return 906...1010
        }
    }
    @ViewBuilder
    var body: some View {
        VStack {
            BackButtonView(text: "Main menu")
            List(selection: $core.activeDex) {
                ForEach(getRange(), id: \.self) { elem in
                    HStack {
                        MenuThumbnailImage(url: getPokemonSpritePath(dex: elem))
                        Text("#\(elem) \(PokemonNameset.common.getLocalizedName(id: elem) ?? "")")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }.onTapGesture {
                        core.setActiveDex(dex: elem)
                    }
                }
            }
        }
    }
}
