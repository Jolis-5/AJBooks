//
//  CategoryFilterView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//
import SwiftUI

enum BookCategory: String, CaseIterable, Identifiable {
    case novel = "Novela"
    case classics = "Clásicos"
    case children = "Infantil"
    case science = "Ciencia"

    var id: String { rawValue }
}

private struct DemoBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let category: BookCategory
}

struct CategoryFilterView: View {

    @State private var selectedCategory: BookCategory? = nil
    @State private var selectedBook: Book?   // 1. estado del detalle

    private let books: [DemoBook] = [
        DemoBook(title: "La Odisea", author: "Homero", category: .classics),
        DemoBook(title: "Don Quijote de la Mancha", author: "Miguel de Cervantes", category: .classics),
        DemoBook(title: "El principito", author: "Antoine de Saint-Exupéry", category: .children),
        DemoBook(title: "Cien años de soledad", author: "Gabriel García Márquez", category: .novel),
        DemoBook(title: "Pedro Páramo", author: "Juan Rulfo", category: .novel),
    ]

    private var filteredBooks: [DemoBook] {
        guard let category = selectedCategory else { return books }
        return books.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()

            VStack {
                Text("Categorías")
                    .font(.system(size: 40))
                    .padding()
                    .fontDesign(.serif)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        chip(title: "Todas", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }

                        ForEach(BookCategory.allCases) { category in
                            chip(title: category.rawValue,
                                 isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredBooks) { book in
                            BookCardView(title: book.title, author: book.author)
                                // 2. toque en la tarjeta
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedBook = Book(
                                        id: book.id.uuidString,
                                        title: book.title,
                                        author: book.author
                                    )
                                }
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .animation(.default, value: selectedCategory)
        // 3. hoja de detalle
        .sheet(item: $selectedBook) { book in
            BookDetailView(book: book)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontDesign(.serif)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundStyle(.black)
                .background(isSelected ? Color.yellow : Color.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .accessibilityLabel("Categoría \(title)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    CategoryFilterView()
}
