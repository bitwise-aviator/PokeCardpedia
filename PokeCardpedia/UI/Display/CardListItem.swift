//
//  CardListTime.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/24/23.
//

import SwiftUI

struct CardListItem: View {
    @Binding var activeImage: String
    @Binding var imageDetailShown: Bool
    @ObservedObject var card: Card
    @ObservedObject var collection: CollectionTracker
    let core = Core.core
    var favorite: Bool {
        collection.favorite
    }
    var wantIt: Bool {
        collection.wantIt
    }
    var haveIt: Bool {
        collection.amount > 0
    }
    var amount: Int {
        Int(collection.amount)
    }
    
    @ViewBuilder
    var body: some View {
        GeometryReader { geom in
            let width = geom.size.width
            let height = geom.size.height
            // Start with set & number.
            HStack {
                HStack {
                    Label {
                        Text("\(card.setNumber)").font(.system(size: 18)).padding(.trailing, 5)
                    } icon: {
                        SetIconImage(url: card.setIconUrl, dimension: 15)
                    }
                    Spacer()
                }.frame(width: min(width / 10, 110), height: 30).padding(.horizontal, 10)
                // Check icon.
                Image(systemName: haveIt ? "checkmark.square" : "square")
                    
                // Card name.
                if let name = card.name {
                    Text(name)
                } else {
                    Text("Retrieving card data...").italic()
                }
                // Space indefinitely.
                Spacer()
                HStack {
                    switch card.superCardType {
                    case .pokemon(data: let data):
                        // Elements
                        if let types = data.types {
                            ForEach(types, id: \.self) { elem in
                                Image(elem.rawValue.lowercased()).resizable().frame(width: 20, height: 20)
                            }
                        }
                        // HP
                        if let hitPt = data.hitPoints {
                            VStack {
                                Text("HP").font(.system(size: 8))
                                Text(String(hitPt)).font(.system(size: 15))
                            }.frame(width: 40, height: 30)
                        }
                    default: EmptyView()
                    }
                }
                HStack {
                    Spacer()
                    RarityImage(rarity: card.rarity, dimension: 15)
                    Image(systemName: wantIt ? "star.fill" : "star" ).foregroundColor(Color(uiColor: .systemYellow))
                    Image(systemName: favorite ? "heart.fill" : "heart" ).foregroundColor(Color(uiColor: .systemPink))
                }.frame(width: min(width / 8, 120), height: 30).padding(.trailing, 5)
            }.frame(height: 30).padding(.vertical, 5).background(haveIt ? Color(uiColor: .systemGray3) : Color(uiColor: .systemBackground))
        }
        .onTapGesture {
            activeImage = card.sortId
            imageDetailShown = true
        }
        .task(priority: .userInitiated) {
            // Use this to get extra info about the card when this view first appears.
            if [ViewMode.none, .favorite, .owned, .want].contains(Core.core.viewMode) {
                // Skip completion if the card has all the data being supported as of current revision.
                guard card.persistentId == nil else {
                    return
                }
                print("Card \(card.id) has requested extra data...")
                await Core.core.getCardsBySet(set: card.setCode)// card.completeData()
            }
        }
    }
}
/*
#Preview {
    CardListTime()
}
*/
