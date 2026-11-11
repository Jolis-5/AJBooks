//
//  SavedBook.swift
//  AJBooks
//

import Foundation
import SwiftData

/// Libro guardado en la colección personal (favoritos).
/// Solo guarda lo necesario para identificarlo y mostrarlo.
@Model
final class SavedBook {
    @Attribute(.unique) var id: String
    var title: String
    var author: String
    var savedAt: Date

    init(id: String, title: String, author: String, savedAt: Date = .now) {
        self.id = id
        self.title = title
        self.author = author
        self.savedAt = savedAt
    }

    convenience init(book: Book) {
        self.init(id: book.id, title: book.title, author: book.author)
    }

    var asBook: Book {
        Book(id: id, title: title, author: author)
    }
}
