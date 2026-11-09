
//
//  Created by Jolette Rivera on 08/11/26.
//  BookViewModelTests.swift
//  AJBooksTests
//

import XCTest
@testable import AJBooks

// MARK: - Dobles de prueba
@MainActor
private final class SequencedBookService: BookServiceProtocol {
    private var results: [Result<[BookDTO], Error>]
    private(set) var callCount = 0

    init(_ results: [Result<[BookDTO], Error>]) {
        self.results = results
    }

    func fetchBooksList(query: String) async throws -> [BookDTO] {
        callCount += 1
        return try results.removeFirst().get()
    }
}

@MainActor
private final class StubAPIClient: APIClientProtocol {
    var response: Any?
    var error: Error?
    private(set) var requestedURL: URL?

    func get<T: Decodable>(from url: URL) async throws -> T {
        requestedURL = url
        if let error { throw error }
        guard let value = response as? T else { throw APIClient.APIError.decoding }
        return value
    }
}

// MARK: - ViewModel: estados de la pantalla
@MainActor
final class BookViewModelTests: XCTestCase {

    private let dtos = [
        BookDTO(key: "/works/OL1W", title: "Swift Básico", authorName: ["Ana"], firstPublishYear: 2020),
        BookDTO(key: "/works/OL2W", title: "Swift Avanzado", authorName: ["Luis"], firstPublishYear: 2022)
    ]

    private let expectedBooks = [
        Book(id: "/works/OL1W", title: "Swift Básico", author: "Ana"),
        Book(id: "/works/OL2W", title: "Swift Avanzado", author: "Luis")
    ]

    // Respuesta exitosa
    func testFetchBooksLoadsBooksFromService() async {
        // Arrange
        let mockService = MockBookService(booksToReturn: dtos)
        let viewModel = BookViewModel(bookService: mockService)

        // Act
        await viewModel.fetchBooks()

        // Assert
        XCTAssertEqual(viewModel.listStatus, .loaded(expectedBooks))
    }

    // Sin resultados
    func testFetchBooksWithNoResultsShowsEmpty() async {
        // Arrange
        let mockService = MockBookService(booksToReturn: [])
        let viewModel = BookViewModel(bookService: mockService)

        // Act
        await viewModel.fetchBooks()

        // Assert
        XCTAssertEqual(viewModel.listStatus, .empty)
    }

    // Error HTTP
    func testFetchBooksHttpErrorShowsErrorMessage() async {
        // Arrange
        let error = APIClient.APIError.httpError(statusCode: 500)
        let mockService = MockBookService(error: error)
        let viewModel = BookViewModel(bookService: mockService)

        // Act
        await viewModel.fetchBooks()

        // Assert
        XCTAssertEqual(viewModel.listStatus, .error(error.errorDescription ?? ""))
    }

    // Reintentar después de un error
    func testRetryAfterErrorLoadsBooks() async {
        // Arrange
        let error = APIClient.APIError.connectivity(.notConnectedToInternet)
        let service = SequencedBookService([.failure(error), .success(dtos)])
        let viewModel = BookViewModel(bookService: service)

        // Act
        await viewModel.fetchBooks()
        let statusAfterFailure = viewModel.listStatus
        await viewModel.fetchBooks()

        // Assert
        XCTAssertEqual(statusAfterFailure, .error(error.errorDescription ?? ""))
        XCTAssertEqual(viewModel.listStatus, .loaded(expectedBooks))
    }

    // No vuelve a consultar si ya hay contenido (cambio de pestaña)
    func testFetchBooksIfNeededDoesNotReloadWhenLoaded() async {
        // Arrange
        let service = SequencedBookService([.success(dtos), .success([])])
        let viewModel = BookViewModel(bookService: service)

        // Act
        await viewModel.fetchBooksIfNeeded()
        await viewModel.fetchBooksIfNeeded()

        // Assert
        XCTAssertEqual(service.callCount, 1)
        XCTAssertEqual(viewModel.listStatus, .loaded(expectedBooks))
    }
}

// MARK: - Service y DTO
@MainActor
final class BookServiceTests: XCTestCase {

    // Verifica que los CodingKeys leen los nombres reales del JSON de Open Library
    func testDecodingMapsOpenLibraryKeys() throws {
        // Arrange
        let json = """
        {"docs":[{"key":"/works/OL1W","title":"Swift Básico",
                  "author_name":["Ana","Luis"],"first_publish_year":2020}]}
        """

        // Act
        let response = try JSONDecoder().decode(BookSearchResponseDTO.self, from: Data(json.utf8))

        // Assert
        XCTAssertEqual(response.docs.first?.key, "/works/OL1W")
        XCTAssertEqual(response.docs.first?.authorName, ["Ana", "Luis"])
        XCTAssertEqual(response.docs.first?.firstPublishYear, 2020)
    }

    // Caso límite: libro sin autor
    func testBookWithoutAuthorUsesFallback() throws {
        // Arrange
        let json = #"{"docs":[{"key":"/works/OL9W","title":"Anónimo"}]}"#
        let response = try JSONDecoder().decode(BookSearchResponseDTO.self, from: Data(json.utf8))

        // Act
        let book = Book(from: try XCTUnwrap(response.docs.first))

        // Assert
        XCTAssertEqual(book.author, "Autor desconocido")
    }

    // El service arma la URL con la búsqueda y devuelve los DTOs
    func testFetchBooksListBuildsQueryAndReturnsDTOs() async throws {
        // Arrange
        let stub = StubAPIClient()
        let dto = BookDTO(key: "/works/OL1W", title: "Swift Básico", authorName: ["Ana"], firstPublishYear: 2020)
        stub.response = BookSearchResponseDTO(docs: [dto])
        let service = BookService(apiClient: stub)

        // Act
        let result = try await service.fetchBooksList(query: "swift")

        // Assert
        XCTAssertEqual(result.map(\.key), ["/works/OL1W"])
        let url = try XCTUnwrap(stub.requestedURL)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.queryItems?.first { $0.name == "q" }?.value, "swift")
    }
}
