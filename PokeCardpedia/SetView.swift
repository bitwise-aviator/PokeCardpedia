//
//  SetView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/15/23.
//

import SwiftUI
import CachedAsyncImage

struct SetButtonStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }.padding(.all, 5)
    }
}

struct SetButtonView: View {
    let url: String
    let text: String
    func loadedImage(_ image: Image) -> some View {
        return image.resizable().scaledToFit().frame(width: 50, height: 50)
    }
    func failedToLoadImage(_ error: Error) -> some View {
        print(error)
        return Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50).border(.red)
    }
    @ViewBuilder
    var body: some View {
        Label {
            Text(text).multilineTextAlignment(.center).lineLimit(3, reservesSpace: true)
        } icon: {
            CachedAsyncImage(url: URL(string: url)!) { phase in
                switch phase {
                case .success(let image):
                    loadedImage(image)
                case .failure(let error):
                    failedToLoadImage(error)
                case .empty:
                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                @unknown default:
                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                }
            }
        }
        .labelStyle(SetButtonStyle())
    }
}

struct PokemonButtonView: View {
    let dexNumber: Int
    /*var body: some View {
        Text(String(dexNumber)).multilineTextAlignment(.center).lineLimit(3, reservesSpace: true)
    }*/
    func loadedImage(_ image: Image) -> some View {
        return image.resizable().scaledToFit().frame(width: 50, height: 50)
    }
    func failedToLoadImage(_ error: Error) -> some View {
        print(error)
        return Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50).border(.red)
    }
    @ViewBuilder
    var body: some View {
        let url = getPokemonSpritePath(dex: dexNumber)
        Label {
            Text(String(dexNumber)).multilineTextAlignment(.center).lineLimit(3, reservesSpace: true)
        } icon: {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    loadedImage(image)
                case .failure(let error):
                    failedToLoadImage(error)
                case .empty:
                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                @unknown default:
                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                }
            }
        }.labelStyle(SetButtonStyle())
    }
}

struct NonSetButtonView: View {
    let imagePath: String
    let text: String
    var body: some View {
        Label {
            Text(text).multilineTextAlignment(.center).lineLimit(3, reservesSpace: true)
        } icon: { Image(systemName: imagePath).resizable().scaledToFit().frame(width: 50, height: 50)
        }.labelStyle(SetButtonStyle())
    }
}

struct SetView: View {
    @ObservedObject var core = Core.core
    @Binding var nameAlert: Bool
    let layout = [GridItem(.adaptive(minimum: 100, maximum: 150))]
    var body: some View {
        ScrollView {
            ScrollViewReader { scroller in
                Text("Overview").frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                LazyVGrid(columns: layout, content: {
                    NonSetButtonView(imagePath: core.inventoryLocked ? "lock.fill" : "lock.open.fill",
                                     text: core.inventoryLocked ? "Inventory locked" : "Inventory unlocked")
                    .id("lock")
                    .frame(maxWidth: .infinity)
                    .background(core.inventoryLocked ? Color(uiColor: .systemRed) : Color(uiColor: .systemGreen))
                    .onTapGesture {
                        core.setInventoryLock(target: !core.inventoryLocked)
                    }
                    NonSetButtonView(imagePath: "checkmark",
                                     text: "Owned")
                    .id("owned")
                    .frame(maxWidth: .infinity)
                    .background(core.viewMode == .owned ? Color(.lightGray) : .clear)
                    .onTapGesture {
                        core.setNonSetViewModeAsActive(target: .owned)
                    }
                    NonSetButtonView(imagePath: "heart.fill",
                                     text: "Favorites")
                    .id("favorite")
                    .frame(maxWidth: .infinity)
                    .background(core.viewMode == .favorite ? Color(.lightGray) : .clear)
                    .onTapGesture {
                        core.setNonSetViewModeAsActive(target: .favorite)
                    }
                    NonSetButtonView(imagePath: "star.fill", text: "Wishlist").id("wanted").frame(maxWidth: .infinity)
                        .background(core.viewMode == .want ? Color(.lightGray) : .clear).onTapGesture {
                        core.setNonSetViewModeAsActive(target: .want)
                    }
                    NonSetButtonView(imagePath: "person.fill", text: "About me").id("aboutMe")
                        .frame(maxWidth: .infinity)
                        .background(.clear).onTapGesture {
                            if !nameAlert {
                               nameAlert = true
                            }
                    }
                })
                Text("Sets").frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                LazyVGrid(columns: layout ) {
                    if let sets = core.sets {
                        ForEach(Array(sets.enumerated()), id: \.element) { _, elem in
                            SetButtonView(url: elem.images.symbol, text: elem.name)
                                .id(elem)
                                .frame(maxWidth: .infinity)
                                .background(core.activeSet == elem ? Color(.lightGray) : .clear)
                                .onTapGesture {
                                core.setActiveSet(set: elem)
                            }
                        }
                    }
                }
                Text("Pokédex").frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                LazyVGrid(columns: layout ) {
                    ForEach((1...1010), id: \.self) { ident in
                        PokemonButtonView(dexNumber: ident)
                            .id("#\(String(ident))")
                            .frame(maxWidth: .infinity)
                            .background(core.activeDex == ident ? Color(.lightGray) : .clear)
                            .onTapGesture {
                            core.setActiveDex(dex: ident)
                        }
                    }
                }.onAppear {
                    switch core.viewMode {
                    case .set: scroller.scrollTo(core.activeSet)
                    case .dex: scroller.scrollTo("#\(core.activeDex ?? 0)")
                    default: break
                    }
                }
            }
        }
    }
}
/*
struct SetView_Previews: PreviewProvider {
    static var previews: some View {
        SetView()
    }
}
*/
