//
//  CategoryFilterView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//
//  Explorar por categoría: cada categoría consulta un tema (subject) de Open Library. Reutiliza BookViewModel, uno por categoría, para no volver a descargar al cambiar de chip.
//

import SwiftUI

enum BookCategory: String, CaseIterable, Identifiable {
    case novel = "Novela"
    case classics = "Clásicos"
    case fantasy = "Fantasía"
    case romance = "Romance"
    case poetry = "Poesía"
    case children = "Infantil"
    case science = "Ciencia"
    case history = "Historia"

    var id: String { rawValue }

    /// Consulta de Open Library para la categoría
    var query: String {
        switch self {
        case .novel: return "subject:fiction"
        case .classics: return "subject:classic_literature"
        case .fantasy: return "subject:fantasy"
        case .romance: return "subject:romance"
        case .poetry: return "subject:poetry"
        case .children: return "subject:children"
        case .science: return "subject:science"
        case .history: return "subject:history"
        }
    }
}

struct CategoryFilterView: View {

    @State private var selectedCategory: BookCategory = .novel
    @State private var selectedBook: Book?
    @State private var viewModels: [BookCategory: BookViewModel] = [:]

    private let bookService: any BookServiceProtocol

    init(bookService: any BookServiceProtocol = BookService(apiClient: APIClient())) {
        self.bookService = bookService
    }

    /// Devuelve (o crea) el ViewModel de la categoría
    private func viewModel(for category: BookCategory) -> BookViewModel {
        if let existing = viewModels[category] { return existing }
        return BookViewModel(bookService: bookService, query: category.query)
    }

    var body: some View {
        VStack(spacing: 12) {
            ScreenHeader(eyebrow: "Explorar", title: "Categorías")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BookCategory.allCases) { category in
                        ChipView(title: category.rawValue,
                                 isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                        .accessibilityLabel("Categoría \(category.rawValue)")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
            }

            if let viewModel = viewModels[selectedCategory] {
                content(for: viewModel)
            } else {
                LoadingStateView(message: "Cargando \(selectedCategory.rawValue.lowercased())...")
            }
        }
        .screenBackground()
        .task(id: selectedCategory) {
            let viewModel = viewModel(for: selectedCategory)
            viewModels[selectedCategory] = viewModel
            await viewModel.fetchBooksIfNeeded()
        }
        .animation(.default, value: selectedCategory)
        .navigationDestination(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func content(for viewModel: BookViewModel) -> some View {
        switch viewModel.listStatus {
        case .loading:
            LoadingStateView(message: "Cargando \(selectedCategory.rawValue.lowercased())...")

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
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .id(selectedCategory)

        case .empty:
            EmptyStateView(
                title: "Sin libros",
                systemImage: "books.vertical",
                message: "No hay libros en esta categoría por ahora."
            )

        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.fetchBooks() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CategoryFilterView(bookService: MockBookService(booksToReturn: BookDTO.previewExamples))
    }
    .environment(FavoritesViewModel.preview)
}
