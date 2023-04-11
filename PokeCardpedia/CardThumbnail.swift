//
//  CardThumbnail.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/10/23.
//

import SwiftUI
import CachedAsyncImage

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
                CachedAsyncImage(url: card.imagePaths.small) { image in
                    image.resizable().scaledToFit().saturation(haveIt ? 1.0 : 0.0)
                } placeholder: {
                    Image("CardBack").resizable().scaledToFit()
                }.border(activeImage == card.sortId ? Color(uiColor: .systemBlue) : .clear, width: 5).onTapGesture {
                    activeImage = card.sortId
                    imageDetailShown = true
                }
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
                Text("\(card.setNumber)").font(.footnote).padding(.horizontal, 5)
            } else {
                Label {
                    Text("\(card.setNumber)").font(.footnote).padding(.trailing, 5)
                } icon: { AsyncImage(url: card.setIconUrl) { image in
                        image.resizable().scaledToFit().frame(width: 10, height: 10)
                    } placeholder: {
                        Image(systemName: "questionmark.app.fill")
                            .resizable().scaledToFit().frame(width: 10, height: 10)
                    }
                }
            }
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
