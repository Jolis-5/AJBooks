//
//  FavoritesStore.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//
//  Servicio de persistencia: guarda, elimina y lee los libros con SwiftData.
//  No es @Observable ni guarda mensajes para la interfaz: cada función dice en su firma
//  que puede fallar ("throws") y quien la llama (FavoritesViewModel) decide qué mostrar.
//

import Foundation
import SwiftData

/// Errores propios del almacenamiento de Mis libros
enum FavoritesError: LocalizedError {
    case invalidBook

    var errorDescription: String? {
        switch self {
        case .invalidBook:
            return "El libro no tiene un identificador válido."
        }
    }
}

final class FavoritesStore {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    init(container: ModelContainer) {
        self.container = container
    }

    /// Todos los libros guardados, del más reciente al más antiguo
    func fetchAll() throws -> [Book] {
        let descriptor = FetchDescriptor<SavedBook>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(\.asBook)
    }

    /// Guarda un libro. Si ya estaba guardado no hace nada (no se duplica)
    func add(_ book: Book) throws {
        let id = book.id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { throw FavoritesError.invalidBook }
        guard try fetchSaved(id: book.id) == nil else { return }

        context.insert(SavedBook(book: book))
        try save()
    }

    /// Elimina un libro guardado. Si no estaba guardado no hace nada
    func remove(_ book: Book) throws {
        guard let saved = try fetchSaved(id: book.id) else { return }

        context.delete(saved)
        try save()
    }

    // MARK: - Privado

    private func fetchSaved(id: String) throws -> SavedBook? {
        let descriptor = FetchDescriptor<SavedBook>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    /// Escribe en disco. Si falla, deshace los cambios pendientes y vuelve a lanzar el error
    private func save() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

// MARK: - Contenedores en memoria (previews y pruebas)
extension FavoritesStore {
    static func makeInMemory() throws -> FavoritesStore {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SavedBook.self, configurations: config)
        return FavoritesStore(container: container)
    }
}
