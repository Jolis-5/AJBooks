//
//  BookCardFavoritesView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import SwiftUI

struct TarjetaLibroView: View {
    let libro: Libro

    @Environment(FavoritosStore.self) private var favoritos

    var body: some View {
        let esFavorito = favoritos.esFavorito(libro)

        BookCardView(title: libro.title, author: libro.author)
        
        
            .overlay(alignment: .topTrailing) {
                Button {
                    favoritos.alternar(libro)
                } label: {
                    Image(systemName: esFavorito ? "heart.fill" : "heart")
                    
                    
                        .font(.title2)
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: esFavorito)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(.top, 24)
                .padding(.trailing, 40)
                .accessibilityLabel(esFavorito ? "Quitar de favoritos" : "Guardar en favoritos")
                .accessibilityHint(esFavorito ? "Quita este libro de tu lista de favoritos."
                                              : "Agrega este libro a tu lista de favoritos.")
            }
    }
}
