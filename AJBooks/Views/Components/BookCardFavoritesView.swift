//
//  BookCardFavoritesView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import SwiftUI

struct BookCardFavoritesView: View {
    let book: Book

    @Environment(FavoritesViewModel.self) private var favorites

    var body: some View {
        BookCardView(book: book)
            .overlay(alignment: .topTrailing) {
                FavoriteButton(book: book)
                    .padding(16)
            }
            .contextMenu {
                FavoriteMenuButton(book: book)
            }
    }
}

/// Botón de corazón reutilizable para guardar / quitar un libro
struct FavoriteButton: View {
    let book: Book
    var compact = false

    @Environment(FavoritesViewModel.self) private var favorites

    var body: some View {
        let isFavorite = favorites.isFavorite(book)

        Button {
            withAnimation(.snappy) { favorites.toggle(book) }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(compact ? .body : .title3)
                .foregroundStyle(isFavorite ? AppColors.red : AppColors.wine)
                .symbolEffect(.bounce, value: isFavorite)
                .frame(width: compact ? 36 : 40, height: compact ? 36 : 40)
                .background(AppColors.paper.opacity(0.92), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
        .accessibilityLabel(isFavorite ? "Quitar de Mis libros" : "Guardar en Mis libros")
        .accessibilityHint(isFavorite ? "Elimina este libro de tu lista guardada."
                                      : "Agrega este libro a tu lista guardada.")
    }
}

/// Opción de menú contextual para guardar / eliminar
struct FavoriteMenuButton: View {
    let book: Book
    @Environment(FavoritesViewModel.self) private var favorites

    var body: some View {
        if favorites.isFavorite(book) {
            Button(role: .destructive) {
                favorites.remove(book)
            } label: {
                Label("Eliminar de Mis libros", systemImage: "trash")
            }
        } else {
            Button {
                favorites.add(book)
            } label: {
                Label("Guardar en Mis libros", systemImage: "heart")
            }
        }
    }
}

#Preview {
    BookCardFavoritesView(book: Book.examples[0])
        .frame(width: 190)
        .padding()
        .screenBackground()
        .environment(FavoritesViewModel.preview)
}
