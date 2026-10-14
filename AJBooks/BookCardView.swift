//
//  BookCardView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//

import SwiftUI

struct BookCardView: View {
    let title: String
    let author: String
    
    var body: some View {
        VStack {
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 160)
                
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
                    .accessibilityHidden(true)
            }
            
            Text(title)
                .font(.headline)
                .bold()
            
            Text(author)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Libro: \(title), \(author)")
        
    }
    
    
}

