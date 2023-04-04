//
//  ContentView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/11/23.
//

import SwiftUI
import CoreData

enum Filter {
    case owned
    case favorite
    case want
    case none
}

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
                AsyncImage(url: card.imagePaths.small) { image in
                    image.resizable().scaledToFit().saturation(haveIt ? 1.0 : 0.0)
                } placeholder: {
                    Image("CardBack").resizable().scaledToFit()
                }.onTapGesture {
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
        }.onTapGesture(count: 2) {
            card.addOne()
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var activeImage: String = ""
    @ObservedObject var core = Core.core
    @State var imageDetailShown: Bool = false
    @State var filterBy = Filter.none

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    /*private func testData() async {
        let data = await ApiClient.client.getBySetId(id: "bwp")
        //let data = await ApiClient.client.getById(id: "g1-72"/*"bwp-BW94"*/)
        //let data = await ApiClient.client.getSetById()
        
        if let data {
            //imageUrls = parseCardsFromJson(data: data)
            imageUrls = parseCardsFromJson(data: data)
        }
    }*/
    let layout = [GridItem(.adaptive(minimum: 100))]
    @ViewBuilder
    var body: some View {
        NavigationSplitView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: layout) {
                        if let cardData = core.activeData {
                            ForEach(Array(cardData.keys).sorted(by: <), id: \.self) {
                                if (filterBy == .none) ||
                                    (filterBy == .owned && (cardData[$0]?.collection?.amount ?? 0) > 0) ||
                                    (filterBy == .favorite && (cardData[$0]?.collection?.favorite ?? false)) ||
                                    (filterBy == .want && (cardData[$0]?.collection?.wantIt ?? false))
                                { CardThumbnail(activeImage: $activeImage,
                                    imageDetailShown: $imageDetailShown,
                                    card: cardData[$0]!)
                                }
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Image(systemName: (filterBy == .want ? "star.fill" : "star"))
                        .foregroundColor((filterBy == .want ? Color(uiColor: .black): Color(uiColor: .systemGray)))
                        .padding(10)
                        .background((filterBy == .want ? Color(uiColor: .systemYellow) : .clear))
                        .cornerRadius(10)
                        .onTapGesture {
                            filterBy = filterBy != .want ? .want : .none
                        }
                    Spacer()
                    Image(systemName: (filterBy == .favorite ? "heart.fill" : "heart"))
                        .foregroundColor((filterBy == .favorite ? Color(uiColor: .black): Color(uiColor: .systemGray)))
                        .padding(10)
                        .background((filterBy == .favorite ? Color(uiColor: .systemPink) : .clear))
                        .cornerRadius(10)
                        .onTapGesture {
                            filterBy = filterBy != .favorite ? .favorite : .none
                        }
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.square")
                            .foregroundColor((filterBy == .owned ? Color(uiColor: .black): Color(uiColor: .systemGray)))
                        Text("\(Core.core.activeUniqueOwned)").foregroundColor(filterBy == .owned ? .black : .primary)
                    }
                    .padding(10)
                    .background((filterBy == .owned ? Color(uiColor: .systemGreen) : .clear))
                    .cornerRadius(10)
                    .onTapGesture {
                        filterBy = filterBy != .owned ? .owned : .none
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "rectangle.stack")
                        Text("\(Core.core.activeOwned)")
                    }
                    Spacer()
                }
            }
            .navigationSplitViewColumnWidth(min: 310, ideal: 480, max: 600)
            .navigationTitle("Cards")
        } detail: {
            if imageDetailShown && core.activeData[activeImage] != nil {
                CardDetailView(imageDetailShown: $imageDetailShown, card: core.activeData[activeImage]!)
            } else {
                SetView()
            }
        }.animation(.default.speed(0.5), value: imageDetailShown).navigationSplitViewStyle(.balanced)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
