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

enum CardTab {
    case next
    case previous
    case current
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

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @State var partialUsername: String = ""
    @State var activeImage: String = ""
    @ObservedObject var core = Core.core
    @ObservedObject var settigns = CoreSettings.settings
    @State var imageDetailShown: Bool = false
    @State var filterBy = Filter.none
    @State var isShowingNameAlert = false

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
    var userNamePossessive: String {
        let userName = CoreSettings.settings.trainerName
        if userName.count == 0 {
            return "My"
        } else if userName.uppercased().hasSuffix("S") {
            return userName + "'"
        } else {
            return userName + "'s"
        }
    }
    var navTitle: String {
        switch core.viewMode {
        case .want: return "\(userNamePossessive) wishlist"
        case .favorite: return "\(userNamePossessive) favorites"
        case .owned: return "\(userNamePossessive) collection"
        case .set: return "Set: \(core.activeSet?.name ?? "---")"
        case .dex: return "Species: #\(core.activeDex ?? 0)"
        case .none: return "Cards"
        }
    }
    @State private var cardTab = CardTab.current
    @ViewBuilder
    var body: some View {
        NavigationSplitView {
            VStack {
                ScrollView {
                    ScrollViewReader { scroller in
                        LazyVGrid(columns: layout) {
                            if let cardData = core.activeData {
                                ForEach(Array(cardData.keys).sorted(by: <), id: \.self) {
                                    if (filterBy == .none) ||
                                        (filterBy == .owned && (cardData[$0]?.collection?.amount ?? 0) > 0) ||
                                        (filterBy == .favorite && (cardData[$0]?.collection?.favorite ?? false)) ||
                                        (filterBy == .want && (cardData[$0]?.collection?.wantIt ?? false)) {
                                        CardThumbnail(activeImage: $activeImage,
                                                      imageDetailShown: $imageDetailShown,
                                                      card: cardData[$0]!).id($0)
                                    }
                                }
                            }
                        }.onChange(of: activeImage, perform: { newValue in
                            scroller.scrollTo(newValue)
                        })
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
            .navigationTitle(Text(navTitle))
        } detail: {
            if imageDetailShown && core.activeData[activeImage] != nil {
                VStack {
                    Button(action: {
                        imageDetailShown = false
                        activeImage = ""
                    }, label: {
                        Text("Go back")
                    })
                    PagerView(imageDetailShown: $imageDetailShown, activePage: $activeImage)
                    if core.inventoryLocked {
                        Text("Card amounts are locked. Tap on the \"Inventory locked\"" +
                             " icon under Overview to allow editing.").foregroundColor(Color(uiColor: .systemRed))
                    }
                }
            } else {
                SetView(nameAlert: $isShowingNameAlert)
            }
        }
        .alert("What's your name?", isPresented: $isShowingNameAlert) {
            TextField("First name", text: $partialUsername)
                .textInputAutocapitalization(.words)
            Button("OK") {
                CoreSettings.settings.setTrainerName(target: partialUsername)
            }
            Button("Cancel", role: .cancel) {}
        }
        .animation(.default.speed(0.5), value: imageDetailShown).navigationSplitViewStyle(.balanced)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active, .inactive: CoreSettings.settings.getAll()
            default: ()
            }
        }
        .onChange(of: isShowingNameAlert) { newVal in
            if newVal == true {
                partialUsername = CoreSettings.settings.trainerName
            }
        }
        .onAppear {
            CoreSettings.settings.getAll()
        }
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
