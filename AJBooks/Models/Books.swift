//
//  Libro.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

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
