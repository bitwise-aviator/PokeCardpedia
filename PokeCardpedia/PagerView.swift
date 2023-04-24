//
//  PagerView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 4/8/23.
//

import SwiftUI
import SwiftUIPager

/// A carousel-like view that allows animated scrolling of large card images.
struct PagerView: View {
    /// Whether this view is shown.
    @Binding var imageDetailShown: Bool
    /// Active card's sort ID
    @Binding var activePage: String
    /// Tracker for active page view inside `Pager` object.
    @StateObject var page: Page = .first()
    /// Retrieves the index within the `Pager` for a new card's sort ID.
    /// - Parameter text: the `Card`'s sortID.
    /// - Returns: index for page with new card's sort ID, if it exists.
    func getNewActivePageIndex(_ text: String) -> Int? {
        let keys = Array(Core.core.activeData.keys.sorted())
        return keys.firstIndex(of: text)
    }
    /// View body.
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
