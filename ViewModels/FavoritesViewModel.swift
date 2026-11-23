//
//  FavoritesViewModel.swift
//  AJBooks
//
//  Estado de "Mis libros" que comparten varias pantallas (corazón, botón del detalle,
//  lista de Mis libros y contador de la pestaña).
//  Llama al servicio FavoritesStore y es quien maneja sus errores: si algo falla,
//  llena errorMessage y MainTabView lo muestra en una alerta.
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class FavoritesViewModel {

    /// Libros guardados, del más reciente al más antiguo
    private(set) var books: [Book] = []

    /// Mensaje para el usuario cuando guardar, eliminar o cargar falla
    private(set) var errorMessage: String?

    private let store: FavoritesStore
    private let logger = Logger(subsystem: "FCA.AJBooks", category: "persistence")

    init(store: FavoritesStore) {
        self.store = store
        loadBooks()
    }

    func isFavorite(_ book: Book) -> Bool {
        books.contains { $0.id == book.id }
    }

    func loadBooks() {
        do {
            books = try store.fetchAll()
        } catch {
            logger.error("Error al leer Mis libros: \(error.localizedDescription)")
            errorMessage = "No se pudieron cargar tus libros guardados."
        }
    }

    func add(_ book: Book) {
        do {
            try store.add(book)
            loadBooks()
        } catch {
            logger.error("Error al guardar: \(error.localizedDescription)")
            errorMessage = "No se pudo guardar «\(book.title)». Intenta de nuevo."
        }
    }

    func remove(_ book: Book) {
        do {
            try store.remove(book)
            loadBooks()
        } catch {
            logger.error("Error al eliminar: \(error.localizedDescription)")
            errorMessage = "No se pudo eliminar «\(book.title)». Intenta de nuevo."
        }
    }

    /// Guarda si no estaba guardado; elimina si ya lo estaba (botón de corazón)
    func toggle(_ book: Book) {
        if isFavorite(book) {
            remove(book)
        } else {
            add(book)
        }
    }

    /// La alerta llama a esto al cerrarse
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Previews
extension FavoritesViewModel {
    /// ViewModel con base de datos en memoria para los Previews
    static var preview: FavoritesViewModel {
        do {
            return FavoritesViewModel(store: try FavoritesStore.makeInMemory())
        } catch {
            fatalError("No se pudo crear la base de datos de Preview: \(error)")
        }
    }
}
