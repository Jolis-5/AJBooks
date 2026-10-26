//
//  BookListView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//


import SwiftUI

struct BookListView: View {
    @State private var selectedBook: Book?
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
                        ForEach(Book.examples) { book in
                            BookCardFavoritesView(book: book)
                                // 1. toque en la tarjeta
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedBook = book
                                }
                                .accessibilityAddTraits(.isButton)
                        }
                    }

                }
            }
        }
        // 2. hoja de detalle
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }

    }
}

#Preview {
    BookListView()
        .environment(FavoritesStore())
}
