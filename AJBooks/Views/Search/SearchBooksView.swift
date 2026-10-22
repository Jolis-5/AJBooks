//
//  BusquedaLibroView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//


import SwiftUI

struct BusquedaLibroView: View {
    @State private var searchText: String = ""
    @State private var libroSeleccionado: Libro?

    private var resultados: [Libro] {
        let busqueda = searchText.trimmingCharacters(in: .whitespaces)
        guard !busqueda.isEmpty else { return Libro.ejemplos }
        return Libro.ejemplos.filter {
            $0.title.localizedCaseInsensitiveContains(busqueda) ||
            $0.author.localizedCaseInsensitiveContains(busqueda)
        }
    }

    private var textoResultados: String {
        resultados.count == 1 ? "1 resultado" : "\(resultados.count) resultados"
    }

    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()

            VStack {

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .accessibilityHidden(true)

                    TextField("Buscar libro...", text: $searchText)

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                        .accessibilityLabel("Borrar búsqueda")
                    }
                }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()

                Text(textoResultados)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(resultados) { libro in
                            TarjetaLibroView(libro: libro)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    libroSeleccionado = libro
                                }
                                .accessibilityAddTraits(.isButton)
                                .accessibilityHint("Abre el detalle del libro")
                        }
                        if resultados.isEmpty {
                            Text("No se encontraron libros")
                                .foregroundStyle(.gray)
                                .padding(.top, 40)
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(item: $libroSeleccionado) { libro in
            BookDetailView(libro: libro)
        }
    }
}

#Preview {
    BusquedaLibroView()
}
