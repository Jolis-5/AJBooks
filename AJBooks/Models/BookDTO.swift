//
//  BookDTO.swift
//  AJBooks
//
//  Created by Jolette Rivera on 08/11/26.
//


import Foundation

struct BookSearchResponseDTO: Decodable, Sendable {
    let docs: [BookDTO]
}

struct BookDTO: Decodable, Sendable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
    }
}

extension Book {
    /// El `key` de Open Library (ej. "/works/OL45883W") es el id estable del libro.
    init(from dto: BookDTO) {
        self.init(
            id: dto.key,
            title: dto.title,
            author: dto.authorName?.first ?? "Autor desconocido"
        )
    }
}
