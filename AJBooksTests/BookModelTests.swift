//
//  BookModelTests.swift
//  AJBooksTests
//
//  Mapeo DTO → Book, datos para mostrar y persistencia de los campos nuevos.
//

import XCTest
@testable import AJBooks

@MainActor
final class BookModelTests: XCTestCase {

    // MARK: - Mapeo desde la API

    func testDTOMapsAllAuthorsAndYear() {
        let dto = BookDTO(key: "/works/OL3W", title: "Buenos presagios",
                          authorName: ["Terry Pratchett", "Neil Gaiman"], firstPublishYear: 1990, coverI: nil, firstSentence: nil)

        let book = Book(from: dto)

        XCTAssertEqual(book.author, "Terry Pratchett")
        XCTAssertEqual(book.authors, ["Terry Pratchett", "Neil Gaiman"])
        XCTAssertEqual(book.firstPublishYear, 1990)
        XCTAssertEqual(book.yearText, "1990")
    }

    // Caso límite: la API omite el título; no debe romper toda la respuesta
    func testMissingTitleDecodesWithFallback() throws {
        let json = #"{"docs":[{"key":"/works/OL5W"},{"key":"/works/OL6W","title":"Ok"}]}"#

        let response = try JSONDecoder().decode(BookSearchResponseDTO.self, from: Data(json.utf8))

        XCTAssertEqual(response.docs.count, 2)
        XCTAssertEqual(Book(from: response.docs[0]).title, "Sin título")
    }

    // Caso límite: autores vacíos o con espacios
    func testBlankAuthorsUseFallback() {
        let dto = BookDTO(key: "/works/OL7W", title: "T", authorName: ["  "], firstPublishYear: nil, coverI: nil, firstSentence: nil)

        let book = Book(from: dto)

        XCTAssertEqual(book.author, "Autor desconocido")
        XCTAssertTrue(book.authors.isEmpty)
        XCTAssertNil(book.yearText)
    }

    // MARK: - Datos para mostrar

    func testAuthorsTextJoinsSeveralAuthors() {
        let book = Book(id: "x", title: "T", author: "Ana", authors: ["Ana", "Luis"])

        XCTAssertTrue(book.authorsText.contains("Ana"))
        XCTAssertTrue(book.authorsText.contains("Luis"))
    }

    func testAuthorsTextFallsBackToMainAuthor() {
        let book = Book(id: "x", title: "T", author: "Homero")

        XCTAssertEqual(book.authorsText, "Homero")
    }

    func testOpenLibraryURLOnlyForWorks() {
        XCTAssertEqual(Book(id: "/works/OL1W", title: "T", author: "A").openLibraryURL?.absoluteString,
                       "https://openlibrary.org/works/OL1W")
        XCTAssertNil(Book(id: "odisea", title: "T", author: "A").openLibraryURL)
    }

    func testSearchMatchesSecondaryAuthor() {
        let book = Book(id: "x", title: "Buenos presagios", author: "Terry Pratchett",
                        authors: ["Terry Pratchett", "Neil Gaiman"])

        XCTAssertEqual(Book.search("gaiman", in: [book]), [book])
    }

    // MARK: - Persistencia

    func testSavedBookRoundTripKeepsAllFields() {
        let book = Book(id: "/works/OL1W", title: "T", author: "Ana", coverID: 9,
                        summary: "S", authors: ["Ana", "Luis"], firstPublishYear: 2001)

        XCTAssertEqual(SavedBook(book: book).asBook, book)
    }

    func testStorePersistsYearAndAuthorsAndOrdersNewestFirst() throws {
        let store = try FavoritesStore.makeInMemory()
        let first = Book(id: "a", title: "A", author: "X", authors: ["X", "Y"], firstPublishYear: 1999)
        let second = Book(id: "b", title: "B", author: "Z")

        try store.add(first)
        try store.add(second)

        let books = try store.fetchAll()
        XCTAssertEqual(books.map(\.id), ["b", "a"])
        XCTAssertEqual(books.last, first)
    }
}
