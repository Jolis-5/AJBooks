//
//  BookCardFavoritesView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import SwiftUI

struct BookCardFavoritesView: View {
    let book: Book

    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        let isFavorite = favorites.isFavorite(book)

        BookCardView(title: book.title, author: book.author)
        
        
            .overlay(alignment: .topTrailing) {
                Button {
                    favorites.toggle(book)
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                    
                    
                        .font(.title2)
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: isFavorite)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(.top, 24)
                .padding(.trailing, 40)
                .accessibilityLabel(isFavorite ? "Quitar de favoritos" : "Guardar en favoritos")
                .accessibilityHint(isFavorite ? "Quita este libro de tu lista de favoritos."
                                              : "Agrega este libro a tu lista de favoritos.")
            }
    }
}
