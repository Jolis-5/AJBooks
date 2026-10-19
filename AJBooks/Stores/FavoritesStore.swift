//
//  FavoritesStore.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import Foundation
import Observation

@Observable
final class FavoritosStore {
    private(set) var libros: [Libro] = []

    func esFavorito(_ libro: Libro) -> Bool {
        libros.contains { $0.id == libro.id }
    }

    func alternar(_ libro: Libro) {
        if esFavorito(libro) {
            quitar(libro)
        } else {
            libros.append(libro)
        }
    }

    func quitar(_ libro: Libro) {
        libros.removeAll { $0.id == libro.id }
    }
}
