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
                        chip(title:
