//
//  BookListView.swift
//  AJBooks
//

import SwiftUI

struct BookListView: View {
    @State private var viewModel: BookViewModel
    @State private var selectedBook: Book?
    init(viewModel: BookViewModel? = nil) {
        _viewModel = .init(
            wrappedValue: viewModel ?? BookViewModel(
                bookService: BookService(apiClient: APIClient())
            )
        )
    }

    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()

            VStack {
                Text("Lista de libros")
                    .font(.system(size: 40))
                    .padding()
                    .fontDesign(.serif)

                switch viewModel.listStatus {
                case .loading:
                    ProgressView("Cargando libros...")
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded(let books):
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(books) { book in
                                BookCardFavoritesView(book: book)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedBook = book
                                    }
                                    .accessibilityAddTraits(.isButton)
                            }
                        }
                    }

                case .empty:
                    ContentUnavailableView(
                        "Sin resultados",
                        systemImage: "books.vertical",
                        description: Text("No se encontraron libros para mostrar.")
                    )

                case .error(let errorMessage):
                    ContentUnavailableView {
                        Label("No se pudo cargar", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Reintentar") {
                            Task { await viewModel.fetchBooks() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchBooksIfNeeded()
        }
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
    }
}

#Preview("Loaded") {
    BookListView(viewModel: BookViewModel(
        bookService: MockBookService(booksToReturn: BookDTO.previewExamples)
    ))
    .environment(FavoritesStore.preview)
}

#Preview("Empty") {
    BookListView(viewModel: BookViewModel(
        bookService: MockBookService(booksToReturn: [])
    ))
    .environment(FavoritesStore.preview)
}

#Preview("Error") {
    BookListView(viewModel: BookViewModel(
        bookService: MockBookService(error: APIClient.APIError.httpError(statusCode: 500))
    ))
    .environment(FavoritesStore.preview)
}
