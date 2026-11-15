//
//  BookSearchViewModel.swift
//  AJBooks
//
//  Lógica de presentación del flujo Buscar → resultados → detalle
//

import Observation
import Foundation

@MainActor
@Observable
final class BookSearchViewModel {

    enum SearchStatus: Equatable {
        /// Aún no se escribe nada: se muestran sugerencias
        case idle
        case loading
        case loaded([Book])
        /// La búsqueda no devolvió libros.
        case empty(query: String)
        case error(String)
    }

    /// Longitud mínima para lanzar una búsqueda contra la API
    static let minimumQueryLength = 2

    /// Sugerencias que se muestran en el estado inicial
    static let suggestions = ["Gabriel García Márquez", "Jane Austen", "Harry Potter", "Poesía", "Frida Kahlo", "Tolkien"]

    private(set) var status: SearchStatus = .idle

    /// Última consulta enviada, sirve para descartar respuestas viejas
    private(set) var lastQuery: String = ""

    private let bookService: any BookServiceProtocol
    private let debounce: Duration

    init(bookService: any BookServiceProtocol, debounce: Duration = .milliseconds(450)) {
        self.bookService = bookService
        self.debounce = debounce
    }

    /// Normaliza el texto: quita espacios sobrantes
    static func normalized(_ query: String) -> String {
        query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    /// Se llama cada vez que cambia el texto. Espera un momento (debounce)
    /// para no consultar la API con cada tecla
    func queryChanged(_ query: String) async {
        let normalized = Self.normalized(query)
        guard normalized.count >= Self.minimumQueryLength else {
            lastQuery = ""
            status = .idle
            return
        }
        do {
            try await Task.sleep(for: debounce)
        } catch {
            return // Se escribió otra letra: esta búsqueda se cancela
        }
        await search(normalized)
    }

    /// Búsqueda inmediata (botón "Buscar" del teclado o "Reintentar")
    func search(_ query: String) async {
        let normalized = Self.normalized(query)
        guard normalized.count >= Self.minimumQueryLength else {
            lastQuery = ""
            status = .idle
            return
        }

        lastQuery = normalized
        status = .loading

        do {
            let dtos = try await bookService.fetchBooksList(query: normalized)
            // Si mientras tanto se lanzó otra búsqueda, se ignora esta respuesta.
            guard !Task.isCancelled, normalized == lastQuery else { return }
            let books = dtos.map { Book(from: $0) }
            status = books.isEmpty ? .empty(query: normalized) : .loaded(books)
        } catch is CancellationError {
            return
        } catch {
            guard normalized == lastQuery else { return }
            status = .error(
                (error as? LocalizedError)?.errorDescription
                ?? "No se pudo completar la búsqueda. Intenta de nuevo."
            )
        }
    }

    /// Vuelve a intentar la última búsqueda
    func retry() async {
        await search(lastQuery)
    }

    /// Limpia la búsqueda y regresa al estado inicial
    func clear() {
        lastQuery = ""
        status = .idle
    }
}
