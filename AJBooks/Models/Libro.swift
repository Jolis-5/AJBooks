//
//  Libro.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import Foundation

struct Libro: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
}

extension Libro {
    static let ejemplos: [Libro] = [
        Libro(id: "odisea", title: "La Odisea", author: "Homero"),
        Libro(id: "quijote", title: "Don Quijote de la Mancha", author: "Miguel de Cervantes"),
        Libro(id: "principito", title: "El principito", author: "Antoine de Saint-Exupéry"),
        Libro(id: "soledad", title: "Cien años de soledad", author: "Gabriel García Márquez"),
        Libro(id: "paramo", title: "Pedro Páramo", author: "Juan Rulfo"),
        
    ]
}
