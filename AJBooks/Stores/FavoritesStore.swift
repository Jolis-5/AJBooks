//
//  FavoritesStore.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import Foundation
import Observation

@Observable
final class FavoritesStore {
    private(set) var books: [Book] = []

    func isFavorite(_ book: Book) -> Bool {
        books.contains { $0.id == book.id }
    }

    func toggle(_ book: Book) {
        if isFavorite(book) {
            remove(book)
        } else {
            books.append(book)
        }
    }

    func remove(_ book: Book) {
        books.removeAll { $0.id == book.id }
    }
}
