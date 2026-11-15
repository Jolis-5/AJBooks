//
//  SavedBook.swift
//  AJBooks
//

import Foundation
import SwiftData

/// Libro guardado en favoritos
/// Solo guarda lo necesario para identificarlo y mostrarlo
@Model
final class SavedBook {
    @Attribute(.unique) var id: String
    var title: String
    var author: String
    var coverID: Int?
    var summary: String?
    var savedAt: Date
    /// Opcionales para que SwiftData migre sin problemas los datos ya guardados
    var authors: [String]?
    var firstPublishYear: Int?

    init(id: String,
         title: String,
         author: String,
         coverID: Int? = nil,
         summary: String? = nil,
         savedAt: Date = .now,
         authors: [String]? = nil,
         firstPublishYear: Int? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.coverID = coverID
        self.summary = summary
        self.savedAt = savedAt
        self.authors = authors
        self.firstPublishYear = firstPublishYear
    }

    convenience init(book: Book) {
        self.init(
            id: book.id,
            title: book.title,
            author: book.author,
            coverID: book.coverID,
            summary: book.summary,
            authors: book.authors,
            firstPublishYear: book.firstPublishYear
        )
    }

    var asBook: Book {
        Book(id: id, title: title, author: author, coverID: coverID, summary: summary,
             authors: authors ?? [], firstPublishYear: firstPublishYear)
    }
}
