//
//  PokeCardpediaApp.swift
//  PokeCardpedia
//
//  Created by Daniel Sanchez on 3/11/23.
//

import SwiftUI

@main
struct PokeCardpediaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
