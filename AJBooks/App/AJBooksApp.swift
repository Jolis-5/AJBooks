//
//  AJBooksApp.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//


import SwiftUI
import SwiftData
import OSLog

@main
struct AJBooksApp: App {
    private let container: ModelContainer
    @State private var favorites: FavoritesStore

    init() {
        let container = Self.makeContainer()
        self.container = container
        _favorites = State(initialValue: FavoritesStore(container: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(favorites)
                .tint(AppColors.wine)
        }
        .modelContainer(container)
    }

    /// Crea el almacenamiento en disco. Si no es posible (disco lleno, datos corruptos) usa uno en memoria para que la app no se cierre.
    private static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: SavedBook.self)
        } catch {
            Logger(subsystem: "FCA.AJBooks", category: "persistence")
                .error("No se pudo abrir el almacenamiento local, se usará memoria: \(error.localizedDescription)")
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: SavedBook.self, configurations: config)
        }
    }
}
