//
//  FavoritesStore.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.




import Foundation
import Observation
import SwiftData

@Observable
final class FavoritesStore {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    /// Estado que leen las vistas. Se recarga desde SwiftData tras cada cambio.
    private(set) var books: [Book] = []

    init(container: ModelContainer) {
        self.container = container
        reload()
    }

    func isFavorite(_ book: Book) -> Bool {
        books.contains { $0.id == book.id }
    }

    /// true si se guardó; false si el id es inválido o ya estaba guardado.
    @discardableResult
    func add(_ book: Book) -> Bool {
        let id = book.id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !isFavorite(book) else { return false }

        context.insert(SavedBook(book: book))
        save()
        return true
    }

    /// true si se eliminó; false si no estaba guardado.
    @discardableResult
    func remove(_ book: Book) -> Bool {
        guard let saved = fetchSaved(id: book.id) else { return false }

        context.delete(saved)
        save()
        return true
    }

    func toggle(_ book: Book) {
        if isFavorite(book) {
            remove(book)
        } else {
            add(book)
        }
    }

    // MARK: - Privado

    private func fetchSaved(id: String) -> SavedBook? {
        let descriptor = FetchDescriptor<SavedBook>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }

    private func save() {
        do {
            try context.save()
        } catch {
            print("Error al guardar favoritos:", error)
        }
        reload()
    }

    private func reload() {
        let descriptor = FetchDescriptor<SavedBook>(
            sortBy: [SortDescriptor(\.savedAt)]
        )
        let saved = (try? context.fetch(descriptor)) ?? []
        books = saved.map(\.asBook)
    }
}

// MARK: - Contenedores en memoria (previews y pruebas)
extension FavoritesStore {
    static func makeInMemory() throws -> FavoritesStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SavedBook.self, configurations: config)
        return FavoritesStore(container: container)
    }

    static var preview: FavoritesStore {
        // swiftlint:disable:next force_try
        try! makeInMemory()
    }
}
