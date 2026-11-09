
//  Created by Jolette Rivera on 08/11/26.
//
//  BookService.swift
//  AJBooks
//

import Foundation

protocol BookServiceProtocol {
    func fetchBooksList(query: String) async throws -> [BookDTO]
}

class BookService: BookServiceProtocol {

    private let apiClient: APIClientProtocol
    private let baseURL = URL(string: "https://openlibrary.org")

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchBooksList(query: String) async throws -> [BookDTO] {
        guard let url = baseURL?
            .appending(path: "search.json")
            .appending(queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "20"),
                URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year")
            ]) else {
            throw APIClient.APIError.invalidURL
        }

        let response: BookSearchResponseDTO = try await apiClient.get(from: url)
        return response.docs
    }
}

/// Solo para Previews y pruebas. La app real usa `BookService`.
struct MockBookService: BookServiceProtocol {
    var booksToReturn: [BookDTO] = []
    var error: Error? = nil

    func fetchBooksList(query: String) async throws -> [BookDTO] {
        if let error {
            throw error
        }
        return booksToReturn
    }
}

extension BookDTO {
    static let previewExamples: [BookDTO] = [
        BookDTO(key: "/works/OL1W", title: "Swift Básico", authorName: ["Ana"], firstPublishYear: 2020),
        BookDTO(key: "/works/OL2W", title: "Swift Avanzado", authorName: ["Luis"], firstPublishYear: 2022),
        BookDTO(key: "/works/OL3W", title: "Programación en iOS", authorName: nil, firstPublishYear: nil)
    ]
}
