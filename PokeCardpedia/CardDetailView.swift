//
//  CardDetailView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/16/23.
//

import SwiftUI

struct CardDetailView: View {
    @ObservedObject var core = Core.core
    @Binding var imageDetailShown: Bool
    // @Binding var activeImage: String
    @ObservedObject var card: Card
    var favorite: Bool {
        card.collection!.favorite
    }
    var wantIt: Bool {
        card.collection!.wantIt
    }
    var counter: Int16 {
        card.collection!.amount
    }
    @ViewBuilder
    var body: some View {
        VStack {
            AsyncImage(url: card.imagePaths.large) { image in
                image.resizable().padding(.all).scaledToFit()
            } placeholder: {
                Image("CardBack").resizable().padding(.all).scaledToFit()
            }
            HStack {
                Button(action: {
                    card.setWantIt(!wantIt)
                }, label: {
                    Label {
                        Text("I want it")
                            .lineLimit(1)
                            .foregroundColor((wantIt ? Color(uiColor: .black): Color(uiColor: .systemGray)))
                    } icon: {
                        Image(systemName: (wantIt ? "star.fill" : "star"))
                            .foregroundColor((wantIt ? Color(uiColor: .black): Color(uiColor: .systemGray)))
                    }.padding(10).background((wantIt ? Color(uiColor: .systemYellow) : .clear)).cornerRadius(10)
                })
                Button(action: {
                    card.setFavorite(!favorite)
                }, label: {
                    Label {
                        Text("Love it")
                            .lineLimit(1)
                            .foregroundColor((favorite ? Color(uiColor: .white): Color(uiColor: .systemGray)))
                    } icon: {
                        Image(systemName: (favorite ? "heart.fill" : "heart"))
                            .foregroundColor((favorite ? Color(uiColor: .white): Color(uiColor: .systemGray)))
                    }.padding(10).background((favorite ? Color(uiColor: .systemPink) : .clear)).cornerRadius(10)
                })
                Spacer().frame(width: 100)
                if !core.inventoryLocked {
                    Button(action: {
                        card.setNumberOwned(counter - 1)
                    }, label: {
                        Image(systemName: "minus").foregroundColor(Color(uiColor: .systemGray)).padding(10)
                            .background((counter > 0 ? Color(uiColor: .clear) : .clear)).cornerRadius(10)
                    }).disabled(counter <= 0)
                }
                Text(String(counter)).foregroundColor(counter != 0 ? Color(uiColor: .systemGreen) : Color.primary)
                if !core.inventoryLocked {
                    Button(action: {
                        card.setNumberOwned(counter + 1)
                    }, label: {
                        Image(systemName: "plus").foregroundColor(Color(uiColor: .systemGray)).padding(10)
                            .background((counter < 999 ? Color(uiColor: .clear) : .clear))
                            .cornerRadius(10)
                    }).disabled(counter >= 999)
                }
            }
        }
    }
}

/*struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(imageDetailShown: .constant(true), activeImage: .constant("bwp-1"))
    }
}
*/
