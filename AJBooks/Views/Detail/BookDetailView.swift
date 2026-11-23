//
//  BookDetailView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 19/10/26.
//
//  Destino común de los tres flujos (Inicio, Buscar y Mis libros).
//  Muestra portada, título, autores, año de publicación, descripción y permite guardar o eliminar el libro.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    @State private var viewModel: BookDetailViewModel
    @Environment(FavoritesViewModel.self) private var favorites

    init(book: Book, viewModel: BookDetailViewModel? = nil) {
        self.book = book
        _viewModel = .init(
            wrappedValue: viewModel ?? BookDetailViewModel(
                book: book,
                bookService: BookService(apiClient: APIClient())
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header
                saveButton
                infoCard
                descriptionCard
            }
            .padding()
            .padding(.bottom, 24)
        }
        .background(alignment: .top) {
            AppColors.wineGradient
                .frame(height: 260)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
                .ignoresSafeArea(edges: .top)
        }
        .screenBackground()
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.wine, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            if let url = book.openLibraryURL {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: url, subject: Text(book.title)) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Compartir enlace de Open Library")
                }
            }
        }
        .task {
            await viewModel.loadDescription()
        }
    }

    // MARK: - Portada, título y autores

    private var header: some View {
        VStack(spacing: 14) {
            BookCoverView(book: book, size: .large)
                .frame(width: 190)
                .shadow(color: .black.opacity(0.25), radius: 16, y: 10)
                .padding(.top, 8)

            Text(book.title)
                .font(AppFonts.bookTitle)
                .foregroundStyle(AppColors.ink)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(book.authorsText)
                .font(.system(.title3, design: .default).weight(.medium))
                .foregroundStyle(AppColors.burgundy)
                .multilineTextAlignment(.center)

            if let year = book.yearText {
                YearBadge(year: "Publicado en \(year)")
            }
        }
    }

    // MARK: - Guardar / eliminar

    @ViewBuilder
    private var saveButton: some View {
        let isSaved = favorites.isFavorite(book)

        Button {
            withAnimation(.snappy) { favorites.toggle(book) }
        } label: {
            Label(isSaved ? "Eliminar de Mis libros" : "Guardar en Mis libros",
                  systemImage: isSaved ? "heart.slash" : "heart.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle(tint: isSaved ? AppColors.red : AppColors.wine))
        .sensoryFeedback(.success, trigger: isSaved)
        .accessibilityHint(isSaved ? "Quita el libro de tu lista guardada" : "Guarda el libro para verlo sin conexión")
    }

    // MARK: - Ficha

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ficha")
                .font(AppFonts.sectionTitle)
                .foregroundStyle(AppColors.wine)

            infoRow(icon: "person.2", label: book.authors.count > 1 ? "Autores" : "Autor",
                    value: book.authorsText)
            Divider().overlay(AppColors.sand)
            infoRow(icon: "calendar", label: "Primera publicación",
                    value: book.yearText ?? "No disponible")
            Divider().overlay(AppColors.sand)
            infoRow(icon: "photo", label: "Portada",
                    value: book.coverID == nil ? "No disponible" : "Open Library")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.red)
                .frame(width: 22)
                .accessibilityHidden(true)
            Text(label)
                .font(AppFonts.caption)
                .foregroundStyle(AppColors.inkSecondary)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(.subheadline, design: .serif).weight(.medium))
                .foregroundStyle(AppColors.ink)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Descripción

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Descripción")
                .font(AppFonts.sectionTitle)
                .foregroundStyle(AppColors.wine)

            descriptionContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }

    @ViewBuilder
    private var descriptionContent: some View {
        switch viewModel.status {
        case .loading:
            HStack(spacing: 10) {
                ProgressView().tint(AppColors.wine)
                Text("Cargando descripción...")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.inkSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .loaded(let text):
            Text(text)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.ink)
                .lineSpacing(4)
                .textSelection(.enabled)

        case .empty:
            Text("Este libro no tiene descripción disponible.")
                .font(AppFonts.body)
                .italic()
                .foregroundStyle(AppColors.inkSecondary)

        case .error(let message):
            VStack(alignment: .leading, spacing: 10) {
                Label(message, systemImage: "exclamationmark.triangle")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.inkSecondary)

                Button("Reintentar", systemImage: "arrow.clockwise") {
                    Task { await viewModel.loadDescription() }
                }
                .buttonStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            book: Book.examples[1],
            viewModel: BookDetailViewModel(
                book: Book.examples[1],
                bookService: MockBookService(descriptionToReturn: "Texto largo de ejemplo.")
            )
        )
    }
    .environment(FavoritesViewModel.preview)
}
