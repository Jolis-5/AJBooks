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
    private let container: ModelContainer
    @State private var favorites: FavoritesStore

    init() {
        do {
            let container = try ModelContainer(for: SavedBook.self)
            self.container = container
            _favorites = State(initialValue: FavoritesStore(container: container))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(favorites)
        }
        .modelContainer(container)
    }
}
