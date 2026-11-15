//
//  BookSearchView.swift
//  AJBooks
//
//  Flujo: Buscar → resultados → detalle.
//  Consulta Open Library mientras el usuario escribe
//

import SwiftUI

struct BookSearchView: View {
    @State private var searchText: String = ""
    @State private var selectedBook: Book?
    @State private var viewModel: BookSearchViewModel
    @FocusState private var isSearchFocused: Bool

    init(viewModel: BookSearchViewModel? = nil) {
        _viewModel = .init(
            wrappedValue: viewModel ?? BookSearchViewModel(
                bookService: BookService(apiClient: APIClient())
            )
        )
    }

    private func resultsText(_ count: Int) -> String {
        count == 1 ? "1 resultado" : "\(count) resultados"
    }

    var body: some View {
        VStack(spacing: 12) {
            ScreenHeader(eyebrow: "Open Library", title: "Buscar")

            searchField

            content
        }
        .screenBackground()
        .task(id: searchText) {
            await viewModel.queryChanged(searchText)
        }
        .navigationDestination(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Campo de búsqueda

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.burgundy)
                .accessibilityHidden(true)

            TextField("Título, autor o tema…", text: $searchText)
                .font(.system(.body, design: .default))
                .foregroundStyle(AppColors.ink)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onSubmit {
                    Task { await viewModel.search(searchText) }
                }
                .accessibilityLabel("Buscar libro")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.clear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.dustyPink)
                }
                .accessibilityLabel("Borrar búsqueda")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppColors.paper, in: Capsule())
        .overlay(Capsule().strokeBorder(isSearchFocused ? AppColors.wine : AppColors.sand, lineWidth: 1.2))
        .padding(.horizontal)
    }

    // MARK: - Estados

    @ViewBuilder
    private var content: some View {
        switch viewModel.status {
        case .idle:
            idleView

        case .loading:
            LoadingStateView(message: "Buscando en Open Library...")

        case .loaded(let books):
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text(resultsText(books.count))
                        .font(AppFonts.overline)
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .foregroundStyle(AppColors.inkSecondary)

                    ForEach(books) { book in
                        BookRowView(book: book)
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
            .scrollDismissesKeyboard(.immediately)

        case .empty(let query):
            EmptyStateView(
                title: "Sin resultados",
                systemImage: "magnifyingglass",
                message: "No encontramos libros para «\(query)». Revisa la ortografía o prueba con otro título o autor."
            )

        case .error(let message):
            ErrorStateView(title: "Búsqueda interrumpida", message: message) {
                Task { await viewModel.retry() }
            }
        }
    }

    /// Estado inicial: invitación y sugerencias de búsqueda
    private var idleView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.dustyPink)
                    Text("¿Qué quieres leer hoy?")
                        .font(AppFonts.sectionTitle)
                        .foregroundStyle(AppColors.wine)
                    Text("Escribe al menos \(BookSearchViewModel.minimumQueryLength) letras para buscar entre millones de libros.")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.inkSecondary)
                }

                Text("Sugerencias")
                    .font(AppFonts.overline)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(AppColors.red)

                FlowLayout(spacing: 8) {
                    ForEach(BookSearchViewModel.suggestions, id: \.self) { suggestion in
                        ChipView(title: suggestion) {
                            searchText = suggestion
                            isSearchFocused = false
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

/// Distribuye chips en varias líneas según el ancho disponible
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: min(widest, maxWidth), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview("Resultados") {
    NavigationStack {
        BookSearchView(viewModel: BookSearchViewModel(
            bookService: MockBookService(booksToReturn: BookDTO.previewExamples),
            debounce: .zero
        ))
    }
    .environment(FavoritesStore.preview)
}
