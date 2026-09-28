//
//  BusquedaLibroView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//

import SwiftUI

struct BusquedaLibroView: View {
    @State private var searchText: String = "Nombre"
    
    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()
            
            VStack() {
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)
                        .accessibilityHidden(true)
                    
                    TextField("Buscar libro...", text: $searchText)
                    
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                Text("1 result found")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
                
                ScrollView {
                    BookCardView(title: "Nombre del libro", author: "Autor / Descripción del libro")
                }
            }
            .padding()
        }
    }
}

#Preview {
    BusquedaLibroView()
}
