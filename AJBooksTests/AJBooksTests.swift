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

    // Coincide por autor, sin importar mayúsculas
    func testSearchByAuthorIgnoresCase() {
        let results = Book.search("HOMERO", in: books)

        XCTAssertEqual(results.map(\.id), ["odisea"])
    }

    // Consulta vacía o solo espacios devuelve todo
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

/// Servicio de persistencia: sus funciones lanzan errores en lugar de devolver Bool
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
    func testAddBookSavesIt() throws {
        try store.add(odisea)

        XCTAssertEqual(try store.fetchAll(), [odisea])
    }

    // Caso límite: el mismo libro dos veces no se duplica
    func testAddSameBookTwiceDoesNotDuplicate() throws {
        try store.add(odisea)
        try store.add(odisea)

        XCTAssertEqual(try store.fetchAll().count, 1)
    }

    // Entrada inválida: id vacío lanza un error
    func testAddBookWithBlankIdThrows() throws {
        let invalid = Book(id: "  ", title: "Sin id", author: "Nadie")

        XCTAssertThrowsError(try store.add(invalid))
        XCTAssertTrue(try store.fetchAll().isEmpty)
    }

    // Eliminar: uno existente y uno que ya no estaba guardado
    func testRemoveDeletesOnlyTheSavedBook() throws {
        try store.add(odisea)
        try store.add(paramo)

        try store.remove(odisea)
        XCTAssertEqual(try store.fetchAll(), [paramo])
        XCTAssertNoThrow(try store.remove(odisea))
    }
}

/// ViewModel de Mis libros: estado compartido y manejo de errores
@MainActor
final class FavoritesViewModelTests: XCTestCase {

    private let odisea = Book(id: "odisea", title: "La Odisea", author: "Homero")

    // toggle alterna entre guardar y quitar
    func testToggleAddsAndThenRemoves() throws {
        let viewModel = FavoritesViewModel(store: try FavoritesStore.makeInMemory())

        viewModel.toggle(odisea)
        XCTAssertTrue(viewModel.isFavorite(odisea))
        XCTAssertEqual(viewModel.books, [odisea])

        viewModel.toggle(odisea)
        XCTAssertFalse(viewModel.isFavorite(odisea))
        XCTAssertNil(viewModel.errorMessage)
    }

    // Si el servicio falla, el ViewModel muestra un mensaje y no agrega el libro
    func testFailedSaveShowsErrorMessage() throws {
        let viewModel = FavoritesViewModel(store: try FavoritesStore.makeInMemory())
        let invalid = Book(id: "", title: "Sin id", author: "Nadie")

        viewModel.add(invalid)

        XCTAssertEqual(viewModel.errorMessage, "No se pudo guardar «Sin id». Intenta de nuevo.")
        XCTAssertTrue(viewModel.books.isEmpty)

        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage)
    }
}
