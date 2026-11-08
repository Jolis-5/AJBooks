


import Foundation

struct Book: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
}

extension Book {
    static let examples: [Book] = [
        Book(id: "odisea", title: "La Odisea", author: "Homero"),
        Book(id: "quijote", title: "Don Quijote de la Mancha", author: "Miguel de Cervantes"),
        Book(id: "principito", title: "El principito", author: "Antoine de Saint-Exupéry"),
        Book(id: "soledad", title: "Cien años de soledad", author: "Gabriel García Márquez"),
        Book(id: "paramo", title: "Pedro Páramo", author: "Juan Rulfo"),
    ]
}

// MARK: - Búsqueda
extension Book {
    /// Filtra por título o autor, sin distinguir mayúsculas.
    /// Una consulta vacía (o solo espacios) devuelve todos los libros.
    static func search(_ query: String, in books: [Book]) -> [Book] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return books }
        return books.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.author.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
