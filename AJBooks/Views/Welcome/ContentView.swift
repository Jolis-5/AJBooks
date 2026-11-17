//
//  ContentView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//

import SwiftUI

struct ContentView: View {
    
    let onEnter: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            AppColors.wineGradient
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()

                // Lomos de libros decorativos
                HStack(alignment: .bottom, spacing: 6) {
                    spine(height: 120, color: AppColors.dustyPink)
                    spine(height: 150, color: AppColors.sand)
                    spine(height: 105, color: AppColors.creme)
                    spine(height: 140, color: AppColors.red)
                    spine(height: 128, color: AppColors.dustyPink.opacity(0.7))
                }
                .rotationEffect(.degrees(-4))
                .padding(.bottom, 24)
                .accessibilityHidden(true)

                Text("Bienvenido a")
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(AppColors.dustyPink)

                Text("AJBooks")
                    .font(AppFonts.brand)
                    .foregroundStyle(AppColors.creme)
                    .accessibilityAddTraits(.isHeader)

                Text("Busca, descubre y guarda tus libros favoritos de Open Library.")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(AppColors.creme.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                Button {
                    onEnter()
                } label: {
                    Text("Entrar")
                        .font(.system(.title3, design: .serif).weight(.bold))
                        .foregroundStyle(AppColors.wine)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.creme, in: Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
                .accessibilityLabel("Entrar")
                .accessibilityHint("Toca dos veces para ingresar a la aplicación")
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appeared = true }
        }
    }

    private func spine(height: CGFloat, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: 34, height: height)
            .overlay(alignment: .top) {
                VStack(spacing: 4) {
                    Rectangle().fill(AppColors.wine.opacity(0.4)).frame(height: 2)
                    Rectangle().fill(AppColors.wine.opacity(0.4)).frame(height: 2)
                }
                .padding(.top, 14)
            }
    }
}

#Preview {
    ContentView(onEnter: {})
}
