//
//  FavoritosView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 27/09/26.
//

import SwiftUI

struct FavoritosView: View {
    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()
            
            
            
            VStack() {
                Text("Favorites")
                    .font(.largeTitle)
                    .bold()
                
               
                
                ScrollView {
                    VStack(spacing: 16) {
                        BookCardView(title: "Nombre del libro 1", author: "Autor / Descripción")
                        BookCardView(title: "Nombre del libro 2", author: "Autor / Descripción")
                        BookCardView(title: "Nombre del libro 3", author: "Autor / Descripción")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

#Preview
{
    FavoritosView()
}
