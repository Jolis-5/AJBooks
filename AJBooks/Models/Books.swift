//
//  Books.swift
//  AJBooks
//

import Foundation

/// Modelo de dominio que usan las vistas
/// Es independiente de la API (BookDTO) y de la persistencia (SavedBook)
struct Book: Identifiable, Hashable {
    let id: String
    let title: String
    /// Autor principal (se muestra en tarjetas)
    let author: String
    var coverID: Int? = nil
    var summary: String? = nil
    /// Todos los autores, cuando la API los entrega
    var authors: [String] = []
    /// Año de la primera publicación, si se conoce
    var firstPublishYear: Int? = nil
}

// MARK: - Datos para mostrar
extension Book {
    /// Lista de autores lista para mostrar: "Ana, Luis y Marta"
    var authorsText: String {
        let names = authors.isEmpty ? [author] : authors
        return names.formatted(.list(type: .and, width: .standard).locale(Locale(identifier: "es")))
    }

    /// Año como texto o nil si no está disponible
    var yearText: String? {
        guard let firstPublishYear, firstPublishYear > 0 else { return nil }
        return String(firstPublishYear)
    }
}

extension Book {
    static let examples: [Book] = [
        Book(id: "odisea", title: "La Odisea", author: "Homero",
             summary: "Epopeya griega atribuida a Homero que narra el largo y peligroso viaje de regreso de Odiseo a Ítaca después de la guerra de Troya."),
        Book(id: "quijote", title: "Don Quijote de la Mancha", author: "Miguel de Cervantes",
             summary: "Un hidalgo enloquecido por los libros de caballerías sale a recorrer La Mancha junto a su escudero Sancho Panza en busca de aventuras.",
             firstPublishYear: 1605),
        Book(id: "principito", title: "El principito", author: "Antoine de Saint-Exupéry",
             summary: "Un piloto perdido en el desierto conoce a un pequeño príncipe que le cuenta sus viajes por distintos planetas.",
             firstPublishYear: 1943),
        Book(id: "soledad", title: "Cien años de soledad", author: "Gabriel García Márquez",
             summary: "La historia de la familia Buendía a lo largo de siete generaciones en el pueblo imaginario de Macondo.",
             firstPublishYear: 1967),
        Book(id: "paramo", title: "Pedro Páramo", author: "Juan Rulfo",
             summary: "Juan Preciado viaja a Comala en busca de su padre y descubre un pueblo habitado por voces y fantasmas.",
             firstPublishYear: 1955),
    ]
}

// MARK: - Portadas
extension Book {
    enum CoverSize: String {
        case small = "S"
        case medium = "M"
        case large = "L"
    }

    /// URL de la portada en Open Library, nil cuando el libro no tiene portada.
    func coverURL(size: CoverSize = .medium) -> URL? {
        guard let coverID, coverID > 0 else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-\(size.rawValue).jpg")
    }
}

// MARK: - Enlace web
extension Book {
    /// Página del libro en openlibrary.org (solo para libros de la API)
    var openLibraryURL: URL? {
        guard id.hasPrefix("/works/") else { return nil }
        return URL(string: "https://openlibrary.org\(id)")
    }
}

// MARK: - Búsqueda
extension Book {
    /// Filtra por título o autor, sin distinguir mayúsculas
    /// Una consulta vacía devuelve todos los libros
    static func search(_ query: String, in books: [Book]) -> [Book] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return books }
        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(trimmed) ||
            book.author.localizedCaseInsensitiveContains(trimmed) ||
            book.authors.contains { $0.localizedCaseInsensitiveContains(trimmed) }
        }
    }
}
