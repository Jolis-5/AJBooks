//
//  ListaLibrosView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//


import SwiftUI

struct ListaLibrosView: View {
    @State private var libroSeleccionado: Libro?
    var body: some View {

        ZStack {

            Color.cyan
                .ignoresSafeArea()

            VStack {
                Text("Lista de libros")
                    .font(.system(size: 40))
                    .padding()
                    .fontDesign(.serif)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Libro.ejemplos) { libro in
                            TarjetaLibroView(libro: libro)
                                // 1. toque en la tarjeta
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    libroSeleccionado = libro
                                }
                                .accessibilityAddTraits(.isButton)
                        }
                    }

                }
            }
        }
        // 2. hoja de detalle
        .sheet(item: $libroSeleccionado) { libro in
            BookDetailView(libro: libro)
        }

    }
}

#Preview {
    ListaLibrosView()
        .environment(FavoritosStore())
}
