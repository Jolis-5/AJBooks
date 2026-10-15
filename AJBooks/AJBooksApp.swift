//
//  AJBooksApp.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//

import SwiftUI
import SwiftData

@main
struct AJBooksApp: App {
    @State private var favoritos = FavoritosStore()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(favoritos)
        }
        .modelContainer(sharedModelContainer)
    }
}
