//
//  BookDetailViewModel.swift
//  AJBooks
//

import Observation
import Foundation

@MainActor
@Observable
final class BookDetailViewModel {

    enum DescriptionStatus: Equatable {
        case loading
        case loaded(String)
        case empty
        case error(String)
    }

    private(set) var status: DescriptionStatus = .loading

    private let book: Book
    private let bookService: any BookServiceProtocol

    init(book: Book, bookService: any BookServiceProtocol) {
        self.book = book
        self.bookService = bookService
    }

    func loadDescription() async {
        guard book.id.hasPrefix("/works/") else {
            status = localStatus()
            return
        }

        status = .loading
        do {
            if let text = try await bookService.fetchBookDescription(key: book.id) {
                status = .loaded(text)
            } else {
                status = localStatus()
            }
        } catch is CancellationError {
            return
        } catch {
            status = .error(
                (error as? LocalizedError)?.errorDescription
                ?? "No se pudo cargar la descripción."
            )
        }
    }

    /// Si el libro no tiene descripción
    private func localStatus() -> DescriptionStatus {
        if let summary = book.summary {
            return .loaded(summary)
        }
        return .empty
    }
}
