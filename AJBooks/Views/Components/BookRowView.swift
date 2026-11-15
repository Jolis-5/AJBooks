//
//  BookRowView.swift
//  AJBooks
//
//  Fila horizontal para resultados de búsqueda: portada pequeña, título, autor, año y botón de guardar
//

import SwiftUI

struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            BookCoverView(book: book, size: .medium)
                .frame(width: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(AppFonts.cardTitle)
                    .foregroundStyle(AppColors.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(book.authorsText)
                    .font(AppFonts.author)
                    .foregroundStyle(AppColors.burgundy)
                    .lineLimit(1)

                if let year = book.yearText {
                    YearBadge(year: year)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            FavoriteButton(book: book, compact: true)
        }
        .padding(12)
        .cardStyle(cornerRadius: 16)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    VStack {
        BookRowView(book: Book.examples[3])
        BookRowView(book: Book.examples[0])
    }
    .padding()
    .screenBackground()
    .environment(FavoritesStore.preview)
}
