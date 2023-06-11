//
//  CardDetailView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/16/23.
//

import SwiftUI

struct CardDetailView: View {
    @ObservedObject var lock = Padlock.lock
    @Binding var imageDetailShown: Bool
    @ObservedObject var card: Card
    @ObservedObject var collection: CollectionTracker
    
    var favorite: Bool {
        collection.favorite
    }
    var wantIt: Bool {
        collection.wantIt
    }
    var counter: Int16 {
        collection.amount
    }
    @ViewBuilder
    var body: some View {
        VStack {
            CardLargeImage(url: card.imagePaths.large)
            HStack {
                Button(action: {
                    collection.modify(wantIt: !wantIt)
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
                    collection.modify(favorite: !favorite)
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
                if !lock.isLocked {
                    Button(action: {
                        collection.modify(amount: max(0, counter - 1))
                    }, label: {
                        Image(systemName: "minus").foregroundColor(Color(uiColor: .systemGray)).padding(10)
                            .background((counter > 0 ? Color(uiColor: .clear) : .clear)).cornerRadius(10)
                    }).disabled(counter <= 0)
                }
                Text(String(counter)).foregroundColor(counter != 0 ? Color(uiColor: .systemGreen) : Color.primary)
                if !lock.isLocked {
                    Button(action: {
                        collection.modify(amount: min(999, counter + 1))
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
