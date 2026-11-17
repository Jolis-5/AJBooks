//
//  BookService.swift
//  AJBooks
//

import Foundation

protocol BookServiceProtocol {
    func fetchBooksList(query: String) async throws -> [BookDTO]
    func fetchBookDescription(key: String) async throws -> String?
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
                URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year,cover_i,first_sentence")
            ]) else {
            throw APIClient.APIError.invalidURL
        }

        let response: BookSearchResponseDTO = try await apiClient.get(from: url)
        return response.docs
    }

    /// Una sola solicitud, cuando el usuario abre el detalle de un libro
    func fetchBookDescription(key: String) async throws -> String? {
        guard key.hasPrefix("/works/"),
              let url = baseURL?.appending(path: "\(key).json") else {
            throw APIClient.APIError.invalidURL
        }

        let response: WorkDetailDTO = try await apiClient.get(from: url)
        return response.description?.cleanedText
    }
}

/// Solo para Previews y pruebas. La app real usa "BookService"
struct MockBookService: BookServiceProtocol {
    var booksToReturn: [BookDTO] = []
    var error: Error? = nil
    var descriptionToReturn: String? = nil
    var descriptionError: Error? = nil

    func fetchBooksList(query: String) async throws -> [BookDTO] {
        if let error {
            throw error
        }
        return booksToReturn
    }

    func fetchBookDescription(key: String) async throws -> String? {
        if let descriptionError {
            throw descriptionError
        }
        return descriptionToReturn
    }
}

extension BookDTO {
    static let previewExamples: [BookDTO] = [
        BookDTO(key: "/works/OL1W", title: "Cien años de soledad", authorName: ["Gabriel García Márquez"], firstPublishYear: 1967),
        BookDTO(key: "/works/OL2W", title: "Orgullo y prejuicio", authorName: ["Jane Austen"], firstPublishYear: 1813),
        BookDTO(key: "/works/OL3W", title: "Buenos presagios", authorName: ["Terry Pratchett", "Neil Gaiman"], firstPublishYear: 1990),
        BookDTO(key: "/works/OL4W", title: "Manuscrito anónimo", authorName: nil, firstPublishYear: nil)
    ]
}
