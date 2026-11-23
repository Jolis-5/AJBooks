//
//  FavoritesView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 27/09/26.
//
//  Flujo: Mis libros → libro guardado → detalle.
//  Lee los libros guardados a través de FavoritesViewModel (que usa FavoritesStore)
//

import SwiftUI

struct FavoritesView: View {

    @Environment(FavoritesViewModel.self) private var favorites
    @State private var selectedBook: Book?
    @State private var filterText = ""
    @State private var bookToDelete: Book?

    /// Acción opcional para ir a buscar libros desde el estado vacío
    var onExplore: (() -> Void)? = nil

    private var countText: String {
        switch favorites.books.count {
        case 0: return "Aún no has guardado libros"
        case 1: return "Tienes 1 libro guardado"
        default: return "Tienes \(favorites.books.count) libros guardados"
        }
    }

    /// Reutiliza la regla de búsqueda local del modelo
    private var filteredBooks: [Book] {
        Book.search(filterText, in: favorites.books)
    }

    var body: some View {
        VStack(spacing: 12) {
            ScreenHeader(eyebrow: "Tu biblioteca", title: "Mis libros", subtitle: countText)

            if favorites.books.isEmpty {
                EmptyStateView(
                    title: "Tu estante está vacío",
                    systemImage: "books.vertical",
                    message: "Toca el corazón de cualquier libro para guardarlo aquí. Se conservará aunque cierres la app.",
                    actionTitle: onExplore == nil ? nil : "Buscar libros",
                    action: onExplore
                )
            } else {
                filterField

                if filteredBooks.isEmpty {
                    EmptyStateView(
                        title: "Sin coincidencias",
                        systemImage: "magnifyingglass",
                        message: "Ninguno de tus libros coincide con «\(filterText)»."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: BookCardView.columns, spacing: 16) {
                            ForEach(filteredBooks) { book in
                                BookCardView(book: book)
                                    .overlay(alignment: .topTrailing) {
                                        deleteButton(for: book)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedBook = book
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            bookToDelete = book
                                        } label: {
                                            Label("Eliminar de Mis libros", systemImage: "trash")
                                        }
                                    }
                                    .accessibilityAddTraits(.isButton)
                                    .accessibilityHint("Abre el detalle del libro")
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
        }
        .screenBackground()
        .animation(.default, value: favorites.books)
        .navigationDestination(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
        .confirmationDialog(
            "¿Eliminar «\(bookToDelete?.title ?? "")» de Mis libros?",
            isPresented: Binding(
                get: { bookToDelete != nil },
                set: { if !$0 { bookToDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: bookToDelete
        ) { book in
            Button("Eliminar", role: .destructive) {
                favorites.remove(book)
            }
            Button("Cancelar", role: .cancel) {}
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var filterField: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease")
                .foregroundStyle(AppColors.burgundy)
                .accessibilityHidden(true)
            TextField("Filtrar mis libros", text: $filterText)
                .autocorrectionDisabled()
            if !filterText.isEmpty {
                Button {
                    filterText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.dustyPink)
                }
                .accessibilityLabel("Borrar filtro")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.paper, in: Capsule())
        .overlay(Capsule().strokeBorder(AppColors.sand, lineWidth: 1))
        .padding(.horizontal)
    }

    private func deleteButton(for book: Book) -> some View {
        Button {
            bookToDelete = book
        } label: {
            Image(systemName: "trash")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.red)
                .frame(width: 36, height: 36)
                .background(AppColors.paper.opacity(0.92), in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
        .padding(16)
        .accessibilityLabel("Eliminar \(book.title) de Mis libros")
    }
}

#Preview("Con libros") {
    let store = FavoritesViewModel.preview
    Book.examples.forEach { store.add($0) }
    return NavigationStack {
        FavoritesView()
    }
    .environment(store)
}

#Preview("Vacío") {
    NavigationStack {
        FavoritesView(onExplore: {})
    }
    .environment(FavoritesViewModel.preview)
}
