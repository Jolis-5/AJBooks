//
//  FavoritesStore.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.




import Foundation
import Observation
import SwiftData
import OSLog

@Observable
final class FavoritesStore {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    /// Estado que leen las vistas, se recarga desde SwiftData tras cada cambio ordenado del más reciente al más antiguo
    private(set) var books: [Book] = []

    /// Mensaje para el usuario cuando una operación de guardado falla
    /// La vista lo muestra en una alerta y luego lo limpia con "clearError()".
    private(set) var errorMessage: String?

    init(container: ModelContainer) {
        self.container = container
        reload()
    }

    func isFavorite(_ book: Book) -> Bool {
        books.contains { $0.id == book.id }
    }

    /// Guarda un libro. Devuelve false si el id es inválido, ya estaba guardado o la escritura falló
    @discardableResult
    func add(_ book: Book) -> Bool {
        let id = book.id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !isFavorite(book) else { return false }

        context.insert(SavedBook(book: book))
        return save(failureMessage: "No se pudo guardar «\(book.title)». Intenta de nuevo.")
    }

    /// Elimina un libro guardado. Devuelve false si no estaba guardado o la escritura falló
    @discardableResult
    func remove(_ book: Book) -> Bool {
        guard let saved = fetchSaved(id: book.id) else { return false }

        context.delete(saved)
        return save(failureMessage: "No se pudo eliminar «\(book.title)». Intenta de nuevo.")
    }

    func clearError() {
        errorMessage = nil
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

    /// Persiste los cambios. Si falla, deshace los cambios pendientes para que la interfaz nunca muestre un estado distinto al que está guardado
    @discardableResult
    private func save(failureMessage: String) -> Bool {
        var succeeded = true
        do {
            try context.save()
        } catch {
            Logger(subsystem: "FCA.AJBooks", category: "persistence")
                .error("Error al guardar favoritos: \(error.localizedDescription)")
            context.rollback()
            errorMessage = failureMessage
            succeeded = false
        }
        reload()
        return succeeded
    }

    private func reload() {
        let descriptor = FetchDescriptor<SavedBook>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
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
        try! makeInMemory()
    }
}
