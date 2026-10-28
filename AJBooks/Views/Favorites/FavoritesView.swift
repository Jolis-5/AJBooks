//
//  FavoritesView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 27/09/26.
//

import SwiftUI

struct FavoritesView: View {

    @Environment(FavoritesStore.self) private var favorites
    @State private var selectedBook: Book?

    var body: some View {

        ZStack {

            Color.cyan
                .ignoresSafeArea()

            VStack {
                Text("Favoritos")
                    .font(.system(size: 40))
                    .padding(.top)
                    .fontDesign(.serif)

                Text("Tienes guardados \(favorites.books.count) libros")
                    .font(.subheadline)
                    .fontDesign(.serif)
                    .padding(.bottom)
                
                
                

                if favorites.books.isEmpty {
                    ContentUnavailableView("Aún no tienes favoritos",
                                           systemImage: "heart",
                                           description: Text("Toca el corazón de un libro para guardarlo."))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(favorites.books) { book in
                                BookCardFavoritesView(book: book)
                                    .onTapGesture {
                                        selectedBook = book
                                    }
                                    .accessibilityAddTraits(.isButton)
                            }
                        }
                    }
                }
                
                
                
            }
        }
        .animation(.default, value: favorites.books)
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
    }
}

#Preview {
    FavoritesView()
        .environment(FavoritesStore())
}
