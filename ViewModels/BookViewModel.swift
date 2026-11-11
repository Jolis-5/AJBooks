//
//  BookViewModel.swift
//  AJBooks
//
//  Created by Jolette Rivera on 08/11/26.
//

import Observation
import Foundation

@MainActor
@Observable
final class BookViewModel {

    enum BookListStatus: Equatable {
        case error(String)
        case loading
        case loaded([Book])
        case empty
    }

    private(set) var listStatus: BookListStatus = .loading

    private let bookService: any BookServiceProtocol
    private let query: String

    /// Cambia `query` si tu equipo definió otra búsqueda para la pantalla principal.
    init(bookService: any BookServiceProtocol, query: String = "swift") {
        self.bookService = bookService
        self.query = query
    }

    /// Para `.task`: no vuelve a consultar si ya hay resultados (evita recargar al cambiar de pestaña).
    func fetchBooksIfNeeded() async {
        switch listStatus {
        case .loaded, .empty:
            return
        case .loading, .error:
            await fetchBooks()
        }
    }

    /// También es la acción de "Reintentar".
    func fetchBooks() async {
        listStatus = .loading
        do {
            let booksDTO: [BookDTO] = try await bookService.fetchBooksList(query: query)
            let books = booksDTO.map { Book(from: $0) }
            listStatus = books.isEmpty ? .empty : .loaded(books)
        } catch is CancellationError {
            // La vista dejó de mostrarse; no se presenta como error.
            return
        } catch {
            print(error)
            listStatus = .error(
                (error as? LocalizedError)?.errorDescription
                ?? "Error obteniendo libros, vuelve a intentar"
            )
        }
    }
}
