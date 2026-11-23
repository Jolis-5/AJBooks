//
//  BookSearchViewModelTests.swift
//  AJBooksTests
//
//  Flujo Buscar → resultados: estados idle, loading, loaded, empty y error.
//

import XCTest
@testable import AJBooks

/// Servicio que registra las consultas recibidas
@MainActor
private final class RecordingBookService: BookServiceProtocol {
    var result: Result<[BookDTO], Error> = .success([])
    private(set) var queries: [String] = []

    func fetchBooksList(query: String) async throws -> [BookDTO] {
        queries.append(query)
        return try result.get()
    }

    func fetchBookDescription(key: String) async throws -> String? { nil }
}

@MainActor
final class BookSearchViewModelTests: XCTestCase {

    private let dtos = [
        BookDTO(key: "/works/OL1W", title: "Cien años de soledad",
                authorName: ["Gabriel García Márquez"], firstPublishYear: 1967, coverI: nil, firstSentence: nil)
    ]

    func testInitialStateIsIdle() {
        let viewModel = BookSearchViewModel(bookService: RecordingBookService())

        XCTAssertEqual(viewModel.status, .idle)
    }

    func testSearchWithResultsShowsLoadedBooks() async {
        let service = RecordingBookService()
        service.result = .success(dtos)
        let viewModel = BookSearchViewModel(bookService: service)

        await viewModel.search("cien años")

        XCTAssertEqual(viewModel.status, .loaded([Book(from: dtos[0])]))
        XCTAssertEqual(service.queries, ["cien años"])
    }

    func testSearchWithoutResultsShowsEmptyWithQuery() async {
        let viewModel = BookSearchViewModel(bookService: RecordingBookService())

        await viewModel.search("xyzxyz")

        XCTAssertEqual(viewModel.status, .empty(query: "xyzxyz"))
    }

    func testSearchErrorShowsMessageAndRetryRecovers() async {
        let error = APIClient.APIError.connectivity(.notConnectedToInternet)
        let service = RecordingBookService()
        service.result = .failure(error)
        let viewModel = BookSearchViewModel(bookService: service)

        await viewModel.search("austen")
        XCTAssertEqual(viewModel.status, .error(error.errorDescription ?? ""))

        service.result = .success(dtos)
        await viewModel.retry()

        XCTAssertEqual(viewModel.status, .loaded([Book(from: dtos[0])]))
        XCTAssertEqual(service.queries, ["austen", "austen"])
    }

    // Entrada inválida: texto muy corto o solo espacios no consulta la API
    func testShortOrBlankQueryDoesNotCallServiceAndStaysIdle() async {
        let service = RecordingBookService()
        let viewModel = BookSearchViewModel(bookService: service, debounce: .zero)

        await viewModel.search("   ")
        await viewModel.queryChanged("a")

        XCTAssertTrue(service.queries.isEmpty)
        XCTAssertEqual(viewModel.status, .idle)
    }

    func testQueryIsNormalizedBeforeSearching() async {
        let service = RecordingBookService()
        let viewModel = BookSearchViewModel(bookService: service, debounce: .zero)

        await viewModel.queryChanged("  jane    austen  ")

        XCTAssertEqual(service.queries, ["jane austen"])
        XCTAssertEqual(viewModel.lastQuery, "jane austen")
    }

    func testClearReturnsToIdle() async {
        let service = RecordingBookService()
        service.result = .success(dtos)
        let viewModel = BookSearchViewModel(bookService: service)
        await viewModel.search("cien")

        viewModel.clear()

        XCTAssertEqual(viewModel.status, .idle)
        XCTAssertEqual(viewModel.lastQuery, "")
    }
}
