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
    /// nil si no se pudo preparar el almacenamiento: en ese caso se muestra un mensaje
    @State private var favorites: FavoritesViewModel?
    /// Una sola instancia para toda la app, creada aquí y compartida por el Environment
    private let coverLoader = CoverImageLoader()

    init() {
        if let container = Self.makeContainer() {
            let store = FavoritesStore(container: container)
            _favorites = State(initialValue: FavoritesViewModel(store: store))
        }
    }

    var body: some Scene {
        WindowGroup {
            if let favorites {
                RootView()
                    .environment(favorites)
                    .environment(\.coverImageLoader, coverLoader)
                    .tint(AppColors.wine)
            } else {
                EmptyStateView(
                    title: "No se pudo abrir AJBooks",
                    systemImage: "exclamationmark.triangle",
                    message: "No fue posible preparar el almacenamiento del teléfono. Cierra la app y vuelve a intentarlo."
                )
                .screenBackground()
            }
        }
    }

    /// Crea el almacenamiento sin forzar ningún "try!":
    /// 1. Intenta guardar en disco (lo normal).
    /// 2. Si falla, usa uno en memoria: la app funciona, pero no conserva los libros al cerrarse.
    /// 3. Si vuelve a fallar, devuelve nil y la app muestra un mensaje en lugar de cerrarse.
    private static func makeContainer() -> ModelContainer? {
        let logger = Logger(subsystem: "FCA.AJBooks", category: "persistence")

        do {
            return try ModelContainer(for: SavedBook.self)
        } catch {
            logger.error("No se pudo abrir el almacenamiento en disco: \(error.localizedDescription)")
        }

        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: SavedBook.self, configurations: config)
        } catch {
            logger.error("Tampoco se pudo crear el almacenamiento en memoria: \(error.localizedDescription)")
            return nil
        }
    }
}
