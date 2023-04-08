//
//  PagerView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/8/23.
//

import SwiftUI
import SwiftUIPager

struct PagerView: View {
    @Binding var imageDetailShown: Bool
    @Binding var activePage: String
    @StateObject var page: Page = .first()
    func getNewActivePageIndex(_ text: String) -> Int? {
        let keys = Array(Core.core.activeData.keys.sorted())
        return keys.firstIndex(of: text)
    }
    var body: some View {
        Pager(page: page, data: Array(Core.core.activeData.keys.sorted()), id: \.self, content: { index in
            CardDetailView(imageDetailShown: $imageDetailShown, card: Core.core.activeData[index]!)
        }).itemAspectRatio(0.7)
            .itemSpacing(10)
            .padding(8)
            .interactive(rotation: true)
            .interactive(scale: 0.7)
            .onPageChanged({ newIndex in
                activePage = Array(Core.core.activeData.keys.sorted())[newIndex]
            }).onChange(of: activePage) { newValue in
                guard let idx = getNewActivePageIndex(newValue) else { return }
                page.update(Page.Update.new(index: idx))
            }.onAppear {
                guard let idx = getNewActivePageIndex(activePage) else { return }
                page.update(Page.Update.new(index: idx))
            }
    }
}

struct PagerViewModel_Previews: PreviewProvider {
    static var previews: some View {
        PagerView(imageDetailShown: .constant(true), activePage: .constant(""))
    }
}
