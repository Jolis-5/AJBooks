//
//  FavoritosView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 27/09/26.
//

import SwiftUI

struct FavoritosView: View {

    @Environment(FavoritosStore.self) private var favoritos
    @State private var libroSeleccionado: Libro?

    var body: some View {

        ZStack {

            Color.cyan
                .ignoresSafeArea()

            VStack {
                Text("Favoritos")
                    .font(.system(size: 40))
                    .padding(.top)
                    .fontDesign(.serif)

                Text("Tienes guardados \(favoritos.libros.count) libros")
                    .font(.subheadline)
                    .fontDesign(.serif)
                    .padding(.bottom)
                
                
                

                if favoritos.libros.isEmpty {
                    ContentUnavailableView("Aún no tienes favoritos",
                                           systemImage: "heart",
                                           description: Text("Toca el corazón de un libro para guardarlo."))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(favoritos.libros) { libro in
                                TarjetaLibroView(libro: libro)
                                    .onTapGesture {
                                        libroSeleccionado = libro
                                    }
                                    .accessibilityAddTraits(.isButton)
                            }
                        }
                    }
                }
                
                
                
            }
        }
        .animation(.default, value: favoritos.libros)
        .sheet(item: $libroSeleccionado) { libro in
            BookDetailView(libro: libro)
        }
    }
}

#Preview {
    FavoritosView()
        .environment(FavoritosStore())
}
