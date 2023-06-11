//
//  MainView.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/11/23.
//

import SwiftUI
import CoreData
import NukeUI
import NavigationStack

/// Generates a reversed boolean binding.
/// - Parameter value: the input boolean binding.
/// - Returns: a binding to a boolean that will show the reverse value.
prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

enum Filter {
    case owned
    case favorite
    case want
    case none
}

/// Stores main UI view.
struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @State var activeFirstLevel: String?
    @State var partialUsername: String = ""
    @State var activeImage: String = ""
    @ObservedObject var lock = Padlock.lock
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
            TopLevelListView(userNameAlertActive: $isShowingNameAlert, activeFirstLevel: $activeFirstLevel)
        } detail: {
            if imageDetailShown && core.activeData[activeImage] != nil {
                HStack {
                    ScrollView {
                        ScrollViewReader { scroller in
                            LazyVGrid(columns: singleLineLayout) {
                                let cardData = core.activeData
                                ForEach(Array(cardData.keys).sorted(by: <), id: \.self) {
                                    if (filterBy == .none) ||
                                        (filterBy == .owned && (cardData[$0]?.getCollectionObject()?.amount ?? 0) > 0) ||
                                        (filterBy == .favorite && (cardData[$0]?.getCollectionObject()?.favorite ?? false)) ||
                                        (filterBy == .want && (cardData[$0]?.getCollectionObject()?.wantIt ?? false)) {
                                        CardThumbnail(activeImage: $activeImage,
                                                      imageDetailShown: $imageDetailShown,
                                                      card: cardData[$0]!, collection: cardData[$0]!.getCollectionObject()!).id($0)
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
                        }, label: {
                            Text("Go back")
                        })
                        PagerView(imageDetailShown: $imageDetailShown, activePage: $activeImage)
                        if lock.isLocked {
                            Text("Card amounts are locked. Tap on the lock" +
                                 " icon in the navigation menu to allow editing.")
                            .foregroundColor(Color(uiColor: .systemRed))
                        }
                    }
                }
            } else {
                VStack {
                    ScrollView {
                        ScrollViewReader { scroller in
                            LazyVGrid(columns: multiLineLayout) {
                                let cardData = core.activeData
                                ForEach(Array(cardData.keys).sorted(by: <), id: \.self) {
                                    if (filterBy == .none) ||
                                        (filterBy == .owned && (cardData[$0]?.getCollectionObject()?.amount ?? 0) > 0) ||
                                        (filterBy == .favorite && (cardData[$0]?.getCollectionObject()?.favorite ?? false)) ||
                                        (filterBy == .want && (cardData[$0]?.getCollectionObject()?.wantIt ?? false)) {
                                        CardThumbnail(activeImage: $activeImage,
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
                            .foregroundColor((filterBy == .favorite ?
                                              Color(uiColor: .black): Color(uiColor: .systemGray)))
                            .padding(10)
                            .background((filterBy == .favorite ? Color(uiColor: .systemPink) : .clear))
                            .cornerRadius(10)
                            .onTapGesture {
                                filterBy = filterBy != .favorite ? .favorite : .none
                            }
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.square")
                                .foregroundColor((filterBy == .owned ?
                                                  Color(uiColor: .black): Color(uiColor: .systemGray)))
                            Text("\(Core.core.activeUniqueOwned)").foregroundColor(filterBy == .owned ?
                                .black : .primary)
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
