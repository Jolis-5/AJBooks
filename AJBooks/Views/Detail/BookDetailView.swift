//
//  BookDetailView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 19/10/26.
//


import SwiftUI

struct BookDetailView: View {
    let book: Book

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cyan
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 220)

                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                            .accessibilityHidden(true)
                    }

                    Text(book.title)
                        .font(.title)
                        .bold()
                        .fontDesign(.serif)
                        .multilineTextAlignment(.center)

                    Text(book.author)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BookDetailView(book: Book.examples[0])
}
