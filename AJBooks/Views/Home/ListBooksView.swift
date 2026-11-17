//
//  BookListView.swift
//  AJBooks
//
//  Flujo: Inicio → lista de libros → detalle.
//

import SwiftUI

struct BookListView: View {
    /// Consulta de Open Library que alimenta la portada de Inicio
    static let featuredQuery = "subject:classic_literature"

    @State private var viewModel: BookViewModel
    @State private var selectedBook: Book?

    init(viewModel: BookViewModel? = nil) {
        _viewModel = .init(
            wrappedValue: viewModel ?? BookViewModel(
                bookService: BookService(apiClient: APIClient()),
                query: Self.featuredQuery
            )
        )
    }

    var body: some View {
        VStack(spacing: 12) {
            ScreenHeader(
                eyebrow: "AJBooks",
                title: "Descubre",
                subtitle: "Clásicos de la literatura desde Open Library"
            )

            content
        }
        .screenBackground()
        .task {
            await viewModel.fetchBooksIfNeeded()
        }
        .navigationDestination(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.listStatus {
        case .loading:
            LoadingStateView(message: "Buscando clásicos...")

        case .loaded(let books):
            ScrollView {
                LazyVGrid(columns: BookCardView.columns, spacing: 16) {
                    ForEach(books) { book in
                        BookCardFavoritesView(book: book)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedBook = book
                            }
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint("Abre el detalle del libro")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .refreshable {
                await viewModel.fetchBooks()
            }

        case .empty:
            EmptyStateView(
                title: "Sin libros por ahora",
                systemImage: "books.vertical",
                message: "No se encontraron libros para mostrar.",
                actionTitle: "Volver a cargar"
            ) {
                Task { await viewModel.fetchBooks() }
            }

        case .error(let errorMessage):
            ErrorStateView(message: errorMessage) {
                Task { await viewModel.fetchBooks() }
            }
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        BookListView(viewModel: BookViewModel(
            bookService: MockBookService(booksToReturn: BookDTO.previewExamples)
        ))
    }
    .environment(FavoritesStore.preview)
}

#Preview("Empty") {
    NavigationStack {
        BookListView(viewModel: BookViewModel(
            bookService: MockBookService(booksToReturn: [])
        ))
    }
    .environment(FavoritesStore.preview)
}

#Preview("Error") {
    NavigationStack {
        BookListView(viewModel: BookViewModel(
            bookService: MockBookService(error: APIClient.APIError.httpError(statusCode: 500))
        ))
    }
    .environment(FavoritesStore.preview)
}
