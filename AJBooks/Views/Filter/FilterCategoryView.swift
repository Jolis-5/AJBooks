//
//  FiltroCategoriaView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import SwiftUI

enum CategoriaLibro: String, CaseIterable, Identifiable {
    case novela = "Novela"
    case clasicos = "Clásicos"
    case infantil = "Infantil"
    case ciencia = "Ciencia"

    var id: String { rawValue }
}

private struct LibroDemo: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let categoria: CategoriaLibro
}

struct FiltroCategoriaView: View {

    @State private var categoriaSeleccionada: CategoriaLibro? = nil

    private let libros: [LibroDemo] = [
        LibroDemo(title: "La Odisea", author: "Homero", categoria: .clasicos),
        LibroDemo(title: "Don Quijote de la Mancha", author: "Miguel de Cervantes", categoria: .clasicos),
        LibroDemo(title: "El principito", author: "Antoine de Saint-Exupéry", categoria: .infantil),
        LibroDemo(title: "Cien años de soledad", author: "Gabriel García Márquez", categoria: .novela),
        LibroDemo(title: "Pedro Páramo", author: "Juan Rulfo", categoria: .novela),
        
    ]

    private var librosFiltrados: [LibroDemo] {
        guard let categoria = categoriaSeleccionada else { return libros }
        return libros.filter { $0.categoria == categoria }
    }

    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()

            VStack {
                Text("Categorías")
                    .font(.system(size: 40))
                    .padding()
                    .fontDesign(.serif)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        chip(titulo: "Todas", seleccionado: categoriaSeleccionada == nil) {
                            categoriaSeleccionada = nil
                        }

                        ForEach(CategoriaLibro.allCases) { categoria in
                            chip(titulo: categoria.rawValue,
                                 seleccionado: categoriaSeleccionada == categoria) {
                                categoriaSeleccionada = categoria
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(librosFiltrados) { libro in
                            BookCardView(title: libro.title, author: libro.author)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .animation(.default, value: categoriaSeleccionada)
    }

    private func chip(titulo: String, seleccionado: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(titulo)
                .font(.headline)
                .fontDesign(.serif)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(.black)
                .background(seleccionado ? Color.yellow : Color.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .accessibilityLabel("Categoría \(titulo)")
        .accessibilityAddTraits(seleccionado ? .isSelected : [])
    }
}

#Preview {
    FiltroCategoriaView()
}
