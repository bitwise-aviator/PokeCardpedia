//
//  CardThumbnail.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/10/23.
//

import SwiftUI
import NukeUI

struct CardThumbnail: View {
    @Binding var activeImage: String
    @Binding var imageDetailShown: Bool
    @ObservedObject var card: Card
    var favorite: Bool {
        card.collection!.favorite
    }
    var wantIt: Bool {
        card.collection!.wantIt
    }
    var haveIt: Bool {
        card.collection!.amount > 0
    }
    var amount: Int {
        Int(card.collection!.amount)
    }
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                CardThumbnailImage(
                    card: card, haveIt: haveIt, activeImage: $activeImage, imageDetailShown: $imageDetailShown
                )
                VStack {
                    if haveIt {
                        Text("\(amount)").foregroundColor(.white).padding(.horizontal, 5).background(.green)
                    }
                    if favorite {
                        Image(systemName: "heart.fill").foregroundColor(Color(uiColor: .systemPink))
                    }
                    if wantIt {
                        Image(systemName: "star.fill").foregroundColor(Color(uiColor: .systemYellow))
                    }
                }.offset(x: -5, y: 5)
                VStack {
                    if haveIt {
                        Text("\(amount)").foregroundColor(.white).padding(.horizontal, 5).background(.green)
                    }
                    if favorite {
                        Image(systemName: "heart").foregroundColor(Color(uiColor: .black))
                    }
                    if wantIt {
                        Image(systemName: "star").foregroundColor(Color(uiColor: .black))
                    }
                }.offset(x: -5, y: 5)
            }
            if Core.core.viewMode == .set {
                Label {
                    Text("\(card.setNumber)").font(.footnote).padding(.trailing, 5)
                } icon: {
                    RarityImage(rarity: card.rarity)
                }
            } else {
                Label {
                    Text("\(card.setNumber)").font(.footnote).padding(.trailing, 5)
                } icon: {
                    HStack {
                        SetIconImage(url: card.setIconUrl)
                        RarityImage(rarity: card.rarity)
                    }
                }
            }
        }.task(priority: .userInitiated) {
            // Use this to get extra info about the card when this view first appears.
            await card.completeData()
        }
    }
}

/*
struct CardThumbnail_Previews: PreviewProvider {
    static var previews: some View {
        CardThumbnail(activeImage: .constant(""), imageDetailShown: .constant(true), card: <#T##Card#>)
    }
}
*/
