//
//  ContentView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/11/23.
//

import SwiftUI
import CoreData
import CachedAsyncImage
import NavigationStack

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

enum Region {
    case kanto, johto, hoenn, sinnoh, unova, kalos, alola, galar, paldea
}

enum Filter {
    case owned
    case favorite
    case want
    case none
}

struct TierOneListView: View {
    @Binding var userNameAlertActive: Bool
    @Binding var activeFirstLevel: String?
    @Binding var activeSecondLevel: String?
    @ObservedObject var core = Core.core
    var userNamePossessive: String {
        let userName = CoreSettings.settings.trainerName
        if userName.isEmpty {
            return "My"
        } else if userName.uppercased().hasSuffix("S") {
            return userName + "'"
        } else {
            return userName + "'s"
        }
    }
    
    @ViewBuilder
    var body: some View {
        NavigationStackView {
            List {
                HStack {
                    Image(systemName: core.inventoryLocked ? "lock.fill" : "lock.open.fill").resizable().scaledToFit().frame(width: 50, height: 50)
                    Toggle(isOn: !$core.inventoryLocked) {
                        Text(core.inventoryLocked ? "Locked" : "Unlocked")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }.tint(.red).foregroundColor(core.inventoryLocked ? .green : .red)
                }
                HStack {
                    Image(systemName: "person.fill").resizable().scaledToFit().frame(width: 50, height: 50)
                    Text(!CoreSettings.settings.trainerName.isEmpty ? CoreSettings.settings.trainerName : "User")
                        .font(.system(.title3, design: .rounded))
                        .bold()
                }.onTapGesture {
                    userNameAlertActive = true
                }
                ForEach(TopLevelItems.myCollection, id: \.id) { elem in
                    PushView(destination: CollectionSubMenuView(activeFirstLevel: $activeFirstLevel),
                             tag: elem.id, selection: $activeFirstLevel) {
                        HStack {
                            Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                            Text("\(userNamePossessive) collection")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                        }
                    }
                }
                ForEach(TopLevelItems.sets, id: \.id) { elem in
                    PushView(destination: SetSubMenuView(activeFirstLevel: $activeFirstLevel),
                             tag: elem.id, selection: $activeFirstLevel) {
                        HStack {
                            Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                            Text("Sets")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                        }
                    }
                }
                Section(header: Text("Species")) {
                    ForEach(TopLevelItems.pokedex, id: \.id) { elem in
                        PushView(destination: DexSubMenuView(region: elem.id, activeFirstLevel: $activeFirstLevel),
                                 tag: elem.name, selection: $activeFirstLevel) {
                            HStack {
                                CachedAsyncImage(url: elem.imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFit().frame(width: 50, height: 50)
                                    case .failure:
                                        Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                                    case .empty:
                                        Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                                    @unknown default:
                                        Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                                    }
                                }
                                Text(elem.name)
                                    .font(.system(.title3, design: .rounded))
                                    .bold()
                            }
                        }
                    }
                }
            }
        }.onChange(of: activeFirstLevel, perform: { newVal in
            print(newVal)
        })
    }
}

struct CollectionSubMenuView: View {
    @Binding var activeFirstLevel: String?
    @ObservedObject var core = Core.core
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
    
    @ViewBuilder
    var body: some View {
        VStack {
            PopView(destination: .root) {
                HStack {
                    Image(systemName: "arrow.left").resizable().scaledToFit().frame(width: 20, height: 20)
                    Text("Main menu")
                        .font(.system(.title3, design: .rounded)).foregroundColor(.red)
                        .bold()
                }
            }
            List(selection: $core.viewMode) {
                ForEach(SecondLevelItems.myCollection, id: \.id) { elem in
                    HStack {
                        Image(systemName: elem.imagePath).resizable().scaledToFit().frame(width: 50, height: 50)
                        Text(elem.name)
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }
                    .onTapGesture {
                        core.setNonSetViewModeAsActive(target: elem.id)
                    }
                }
            }
        }.onAppear {
        }
    }
}

struct SetSubMenuView: View {
    @Binding var activeFirstLevel: String?
    @ObservedObject var core = Core.core
    @ViewBuilder
    var body: some View {
        VStack {
            PopView(destination: .root) {
                HStack {
                    Image(systemName: "arrow.left").resizable().scaledToFit().frame(width: 20, height: 20)
                    Text("Main menu")
                        .font(.system(.title3, design: .rounded)).foregroundColor(.red)
                        .bold()
                }
            }
            List(selection: $core.activeSet) {
                if let sets = core.sets {
                    ForEach(Array(sets.enumerated()), id: \.element) { _, elem in
                        HStack {
                            CachedAsyncImage(url: URL(string: elem.images.symbol)!) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFit().frame(width: 50, height: 50)
                                case .failure:
                                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                                case .empty:
                                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                                @unknown default:
                                    Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                                }
                            }
                            Text(elem.name)
                                .font(.system(.title3, design: .rounded))
                                .bold()
                        }.onTapGesture {
                            core.setActiveSet(set: elem)
                        }
                    }
                }
            }
        }
    }
}

struct DexSubMenuView: View {
    let region: Region
    @Binding var activeFirstLevel: String?
    @ObservedObject var core = Core.core
    
    func getRange() -> ClosedRange<Int> {
        switch region {
        case .kanto:
            return 1...151
        case .johto:
            return 152...251
        case .hoenn:
            return 252...386
        case .sinnoh:
            return 387...493
        case .unova:
            return 494...649
        case .kalos:
            return 650...721
        case .alola:
            return 722...809
        case .galar:
            return 810...905
        case .paldea:
            return 906...1010
        }
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            PopView(destination: .root) {
                HStack {
                    Image(systemName: "arrow.left").resizable().scaledToFit().frame(width: 20, height: 20)
                    Text("Main menu")
                        .font(.system(.title3, design: .rounded)).foregroundColor(.red)
                        .bold()
                }
            }
            List(selection: $core.activeDex) {
                ForEach(getRange(), id: \.self) { elem in
                    HStack {
                        CachedAsyncImage(url: getPokemonSpritePath(dex: elem)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit().frame(width: 50, height: 50)
                            case .failure:
                                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                            case .empty:
                                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                            @unknown default:
                                Image("CardBack").resizable().scaledToFit().frame(width: 50, height: 50)
                            }
                        }
                        Text(String("#\(elem)"))
                            .font(.system(.title3, design: .rounded))
                            .bold()
                    }.onTapGesture {
                        core.setActiveDex(dex: elem)
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @State var activeFirstLevel: String?
    @State var activeSecondLevel: String?
    @State var partialUsername: String = ""
    @State var activeImage: String = ""
    @ObservedObject var core = Core.core
    @ObservedObject var settings = CoreSettings.settings
    @State var imageDetailShown: Bool = false
    @State var filterBy = Filter.none
    @State var isShowingNameAlert = false

    @State var navColumnVisiblity = NavigationSplitViewVisibility.automatic

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
    let multiLineLayout = [GridItem(.adaptive(minimum: 150))]
    let singleLineLayout = [GridItem(.fixed(150))]
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
        default: return "Cards"
        }
    }
    @ViewBuilder
    var body: some View {
        NavigationSplitView(columnVisibility: $navColumnVisiblity) {
            TierOneListView(userNameAlertActive: $isShowingNameAlert, activeFirstLevel: $activeFirstLevel, activeSecondLevel: $activeSecondLevel)
        } detail: {
            if imageDetailShown && core.activeData[activeImage] != nil {
                HStack {
                    ScrollView {
                        ScrollViewReader { scroller in
                            LazyVGrid(columns: singleLineLayout) {
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
                            }
                            .onAppear {
                                scroller.scrollTo(activeImage)
                            }
                            .onChange(of: activeImage, perform: { newValue in
                                scroller.scrollTo(newValue)
                            })
                        }.frame(maxWidth: 190)
                    }
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
                }
            } else {
                VStack {
                    ScrollView {
                        ScrollViewReader { scroller in
                            LazyVGrid(columns: multiLineLayout) {
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
        .onChange(of: activeFirstLevel) { newVal in
            print(newVal)
        }
        .animation(.default.speed(0.5), value: imageDetailShown).navigationSplitViewStyle(.balanced)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active, .inactive:
                CoreSettings.settings.getAll()
                partialUsername = CoreSettings.settings.trainerName
            default: ()
            }
        }
        .onAppear {
            CoreSettings.settings.getAll()
            partialUsername = CoreSettings.settings.trainerName
        }
        /*detail: {
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
        .onChange(of: navColumnVisiblity, perform: { newVal in
            print(newVal)
        })
        .onAppear {
            CoreSettings.settings.getAll()
        } */
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
