//
//  MainTabView.swift
//  AJBooks
//
//  Contiene los tres flujos del MVP, cada uno con su propio NavigationStack:
//  - Inicio → lista de libros → detalle
//  - Buscar → resultados → detalle
//  - Mis libros → libro guardado → detalle
//  y una pestaña extra para explorar por categorías.
//

import SwiftUI

enum AppTab: Hashable {
    case home, search, favorites, filter
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                BookListView()
            }
            .tabItem { Label("Inicio", systemImage: "books.vertical") }
            .tag(AppTab.home)

            NavigationStack {
                BookSearchView()
            }
            .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
            .tag(AppTab.search)

            NavigationStack {
                FavoritesView(onExplore: { selectedTab = .search })
            }
            .tabItem { Label("Mis libros", systemImage: "heart") }
            .badge(favorites.books.count)
            .tag(AppTab.favorites)

            NavigationStack {
                CategoryFilterView()
            }
            .tabItem { Label("Explorar", systemImage: "square.grid.2x2") }
            .tag(AppTab.filter)
        }
        .tint(AppColors.wine)
        // Errores de persistencia de cualquier pantalla
        .alert(
            "Algo salió mal",
            isPresented: Binding(
                get: { favorites.errorMessage != nil },
                set: { if !$0 { favorites.clearError() } }
            )
        ) {
            Button("Aceptar", role: .cancel) { favorites.clearError() }
        } message: {
            Text(favorites.errorMessage ?? "")
        }
    }
}

#Preview {
    MainTabView()
        .environment(FavoritesStore.preview)
}
