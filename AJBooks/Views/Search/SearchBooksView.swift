//
//  BookSearchView.swift
//  AJBooks
//

import SwiftUI

struct BookSearchView: View {
    @State private var searchText: String = ""
    @State private var selectedBook: Book?

    private var results: [Book] {
        Book.search(searchText, in: Book.examples)
    }

    private var resultsText: String {
        results.count == 1 ? "1 resultado" : "\(results.count) resultados"
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

                Text(resultsText)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(results) { book in
                            BookCardFavoritesView(book: book)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedBook = book
                                }
                                .accessibilityAddTraits(.isButton)
                                .accessibilityHint("Abre el detalle del libro")
                        }
                        if results.isEmpty {
                            Text("No se encontraron libros")
                                .foregroundStyle(.gray)
                                .padding(.top, 40)
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
    }
}

#Preview {
    BookSearchView()
        .environment(FavoritesStore.preview)
}
