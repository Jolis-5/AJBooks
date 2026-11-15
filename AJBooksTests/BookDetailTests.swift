//
//  BookDetailTests.swift
//  AJBooksTests
//

import XCTest
@testable import AJBooks

@MainActor
final class BookDetailTests: XCTestCase {

    // MARK: - Decodificación
    func testDescriptionDecodesFromPlainString() throws {
        let json = #"{"description":"Una historia."}"#

        let work = try JSONDecoder().decode(WorkDetailDTO.self, from: Data(json.utf8))

        XCTAssertEqual(work.description?.cleanedText, "Una historia.")
    }

    func testDescriptionDecodesFromObjectWithValue() throws {
        let json = #"{"description":{"type":"/type/text","value":"Una historia."}}"#

        let work = try JSONDecoder().decode(WorkDetailDTO.self, from: Data(json.utf8))

        XCTAssertEqual(work.description?.cleanedText, "Una historia.")
    }

    func testFirstSentenceAndCoverMapToBook() throws {
        let json = #"{"docs":[{"key":"/works/OL1W","title":"T","first_sentence":["Era de noche."],"cover_i":123}]}"#

        let response = try JSONDecoder().decode(BookSearchResponseDTO.self, from: Data(json.utf8))
        let book = Book(from: try XCTUnwrap(response.docs.first))

        XCTAssertEqual(book.summary, "Era de noche.")
        XCTAssertEqual(book.coverID, 123)
    }

    // MARK: - Portada
    func testCoverURLUsesCoverID() {
        let book = Book(id: "/works/OL1W", title: "T", author: "A", coverID: 123)

        XCTAssertEqual(book.coverURL(size: .medium)?.absoluteString,
                       "https://covers.openlibrary.org/b/id/123-M.jpg")
    }

    func testCoverURLIsNilWithoutCoverID() {
        let book = Book(id: "/works/OL1W", title: "T", author: "A")

        XCTAssertNil(book.coverURL())
    }

    // MARK: - ViewModel del detalle
    func testLoadDescriptionShowsRemoteText() async {
        let book = Book(id: "/works/OL1W", title: "T", author: "A")
        let viewModel = BookDetailViewModel(
            book: book,
            bookService: MockBookService(descriptionToReturn: "Texto completo")
        )

        await viewModel.loadDescription()

        XCTAssertEqual(
            viewModel.status,
            BookDetailViewModel.DescriptionStatus.loaded("Texto completo")
        )
    }

    func testLoadDescriptionWithoutAnyTextShowsEmpty() async {
        let book = Book(id: "/works/OL1W", title: "T", author: "A")
        let viewModel = BookDetailViewModel(book: book, bookService: MockBookService())

        await viewModel.loadDescription()

        XCTAssertEqual(
            viewModel.status,
            BookDetailViewModel.DescriptionStatus.empty
        )
    }

    func testLocalBookUsesItsSummaryWithoutCallingTheApi() async {
        let book = Book(id: "odisea", title: "La Odisea", author: "Homero", summary: "Resumen local")
        let viewModel = BookDetailViewModel(
            book: book,
            bookService: MockBookService(descriptionError: APIClient.APIError.httpError(statusCode: 500))
        )

        await viewModel.loadDescription()

        XCTAssertEqual(
            viewModel.status,
            BookDetailViewModel.DescriptionStatus.loaded("Resumen local")
        )
    }

    func testLoadDescriptionErrorShowsMessage() async {
        let error = APIClient.APIError.httpError(statusCode: 404)
        let book = Book(id: "/works/OL1W", title: "T", author: "A")
        let viewModel = BookDetailViewModel(
            book: book,
            bookService: MockBookService(descriptionError: error)
        )

        await viewModel.loadDescription()

        XCTAssertEqual(
            viewModel.status,
            BookDetailViewModel.DescriptionStatus.error(error.errorDescription ?? "")
        )
    }
}
