//
//  ListView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 6/24/23.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var core = Core.core
    @Binding var filterBy: Filter
    @Binding var activeImage: String
    @Binding var imageDetailShown: Bool
    let singleLineLayout = [GridItem(.flexible())]
    
    @ViewBuilder
    var body: some View {
        ScrollView {
            ScrollViewReader { scroller in
                LazyVGrid(columns: singleLineLayout, spacing: 30) {
                    let cardData = core.activeData
                    ForEach(Array(cardData.keys).sorted(by: <), id: \.self) {
                        if (filterBy == .none) ||
                            (filterBy == .owned && (cardData[$0]?.getCollectionObject()?.amount ?? 0) > 0) ||
                            (filterBy == .favorite && (cardData[$0]?.getCollectionObject()?.favorite ?? false)) ||
                            (filterBy == .want && (cardData[$0]?.getCollectionObject()?.wantIt ?? false)) {
                            CardListItem(activeImage: $activeImage,
                                         imageDetailShown: $imageDetailShown,
                                         card: cardData[$0]!, collection: cardData[$0]!.getCollectionObject()!).id($0)
                        }
                    }
                }.onChange(of: activeImage, perform: { newValue in
                    scroller.scrollTo(newValue)
                })
                .onAppear {
                    scroller.scrollTo(activeImage, anchor: .center)
                    activeImage = ""
                }
            }
            Spacer(minLength: 40)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(filterBy: Binding.constant(Filter.none), activeImage: Binding.constant(""), imageDetailShown: Binding.constant(false))
    }
}

