//
//  AJBooksTests.swift
//  AJBooksTests
//

import XCTest
@testable import AJBooks

// MARK: - Regla de búsqueda
@MainActor
final class BookSearchTests: XCTestCase {

    private let books = [
        Book(id: "odisea", title: "La Odisea", author: "Homero"),
        Book(id: "quijote", title: "Don Quijote de la Mancha", author: "Miguel de Cervantes"),
        Book(id: "paramo", title: "Pedro Páramo", author: "Juan Rulfo"),
    ]

    
    func testSearchByTitleReturnsMatchingBook() {
        let results = Book.search("quijote", in: books)

        XCTAssertEqual(results.map(\.id), ["quijote"])
    }

    // Caso normal: coincide por autor, sin importar mayúsculas
    func testSearchByAuthorIgnoresCase() {
        let results = Book.search("HOMERO", in: books)

        XCTAssertEqual(results.map(\.id), ["odisea"])
    }

    // Caso límite: consulta vacía o solo espacios devuelve todo
    func testSearchWithBlankQueryReturnsAllBooks() {
        XCTAssertEqual(Book.search("", in: books), books)
        XCTAssertEqual(Book.search("   ", in: books), books)
    }

    // Caso sin resultados
    func testSearchWithNoMatchReturnsEmpty() {
        let results = Book.search("xyz123", in: books)

        XCTAssertTrue(results.isEmpty)
    }
}

// MARK: - Colección personal (SwiftData)
@MainActor
final class FavoritesStoreTests: XCTestCase {

    private var store: FavoritesStore!

    private let odisea = Book(id: "odisea", title: "La Odisea", author: "Homero")
    private let paramo = Book(id: "paramo", title: "Pedro Páramo", author: "Juan Rulfo")

    override func setUpWithError() throws {
        store = try FavoritesStore.makeInMemory()
    }

    override func tearDown() {
        store = nil
    }

    // Caso normal
    func testAddBookSavesItAsFavorite() {
        let added = store.add(odisea)

        XCTAssertTrue(added)
        XCTAssertEqual(store.books, [odisea])
        XCTAssertTrue(store.isFavorite(odisea))
    }

    // Caso límite: el mismo libro dos veces no se duplica
    func testAddSameBookTwiceDoesNotDuplicate() {
        store.add(odisea)
        let addedAgain = store.add(odisea)

        XCTAssertFalse(addedAgain)
        XCTAssertEqual(store.books.count, 1)
    }

    // Entrada inválida: id vacío
    func testAddBookWithBlankIdIsRejected() {
        let invalid = Book(id: "  ", title: "Sin id", author: "Nadie")

        XCTAssertFalse(store.add(invalid))
        XCTAssertTrue(store.books.isEmpty)
    }

    // Eliminar: uno existente y uno que no estaba guardado
    func testRemoveDeletesOnlyTheSavedBook() {
        store.add(odisea)
        store.add(paramo)

        XCTAssertTrue(store.remove(odisea))
        XCTAssertEqual(store.books, [paramo])
        XCTAssertFalse(store.remove(odisea))
    }

    // toggle alterna entre guardar y quitar
    func testToggleAddsAndThenRemoves() {
        store.toggle(odisea)
        XCTAssertTrue(store.isFavorite(odisea))

        store.toggle(odisea)
        XCTAssertFalse(store.isFavorite(odisea))
    }
}
