//
//  BookCardView.swift
//  AJBooks
//

import SwiftUI

/// Portada del libro con sus tres estados:
/// - cargando,
/// - imagen de Open Library,
/// - sin portada: una portada "de tela" con el título del libro.
struct BookCoverView: View {
    let book: Book
    var size: Book.CoverSize = .medium

    private enum Phase {
        case loading
        case loaded(UIImage)
        case failed
    }

    @State private var phase: Phase = .loading
    /// Cargador compartido que inyecta AJBooksApp
    @Environment(\.coverImageLoader) private var coverLoader

    var body: some View {
        AppColors.dustyPink.opacity(0.35)
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .overlay {
                if book.coverURL(size: size) == nil {
                    placeholder(label: "Sin portada")
                } else {
                    switch phase {
                    case .loaded(let image):
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity)
                    case .loading:
                        // Si la portada ya está en caché se muestra de inmediato, sin indicador
                        if let url = book.coverURL(size: size),
                           let cached = coverLoader.cachedImage(for: url) {
                            Image(uiImage: cached)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ProgressView()
                                .tint(AppColors.wine)
                        }
                    case .failed:
                        placeholder(label: "Portada no disponible")
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(alignment: .leading) {
                // Sombra del lomo: da sensación de libro físico.
                LinearGradient(colors: [.black.opacity(0.18), .clear],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(width: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .allowsHitTesting(false)
            }
            .shadow(color: AppColors.wine.opacity(0.18), radius: 6, x: 2, y: 4)
            .accessibilityHidden(true)
            // Se ejecuta cada vez que la portada aparece en pantalla; si una
            // descarga anterior se canceló o falló, aquí se vuelve a intentar.
            .task(id: book.coverURL(size: size)) {
                await loadCover()
            }
    }

    private func loadCover() async {
        guard let url = book.coverURL(size: size) else { return }
        if case .loaded = phase { return }

        do {
            let image = try await coverLoader.image(for: url)
            withAnimation(.easeInOut(duration: 0.25)) { phase = .loaded(image) }
        } catch {
            // Una cancelación no es un error real: la vista se fue de pantalla  y al volver se reintenta
            guard !Task.isCancelled else { return }
            phase = .failed
        }
    }

    /// Estado "sin portada": diseño propio con el título
    private func placeholder(label: String) -> some View {
        ZStack {
            AppColors.wineGradient

            VStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(size == .small ? .body : .title2)
                    .foregroundStyle(AppColors.dustyPink)

                if size != .small {
                    Text(book.title)
                        .font(.system(size == .large ? .title3 : .caption, design: .serif).weight(.semibold))
                        .foregroundStyle(AppColors.creme)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .minimumScaleFactor(0.7)

                    Rectangle()
                        .fill(AppColors.sand)
                        .frame(width: 24, height: 1)

                    Text(label)
                        .font(AppFonts.overline)
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(AppColors.sand)
                }
            }
            .padding(10)
        }
    }
}

struct BookCardView: View {
    let book: Book

    /// Dos columnas, Libro vertical
    static let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            BookCoverView(book: book)
                .padding(.bottom, 4)

            Text(book.title)
                .font(AppFonts.cardTitle)
                .foregroundStyle(AppColors.ink)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)

            Text(book.author)
                .font(AppFonts.author)
                .foregroundStyle(AppColors.burgundy)
                .lineLimit(1)

            HStack(spacing: 6) {
                if let year = book.yearText {
                    YearBadge(year: year)
                }
                Spacer(minLength: 0)
            }
            .frame(minHeight: 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var text = "Libro: \(book.title), de \(book.author)"
        if let year = book.yearText { text += ", publicado en \(year)" }
        return text
    }
}

/// Pequeña insignia con el año de publicación
struct YearBadge: View {
    let year: String

    var body: some View {
        Text(year)
            .font(AppFonts.overline)
            .tracking(0.8)
            .foregroundStyle(AppColors.wine)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(AppColors.sand.opacity(0.45), in: Capsule())
    }
}

#Preview {
    HStack(alignment: .top) {
        BookCardView(book: Book.examples[1])
        BookCardView(book: Book(id: "x", title: "Libro con portada", author: "Autor", coverID: 8_739_161, firstPublishYear: 1999))
    }
    .padding()
    .screenBackground()
}
