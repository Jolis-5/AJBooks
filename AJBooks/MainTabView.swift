//
//  MainTabView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import SwiftUI

enum AppTab: Hashable {
    case inicio, buscar, favoritos, filtro
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .inicio
    
    

    var body: some View {
        TabView(selection: $selectedTab) {
            ListaLibrosView()
                .tabItem { Label("Inicio", systemImage: "books.vertical") }
                .tag(AppTab.inicio)

            BusquedaLibroView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.buscar)

            FavoritosView()
                .tabItem { Label("Saved", systemImage: "heart") }
                .tag(AppTab.favoritos)

            FiltroCategoriaView()
                .tabItem { Label("Filter", systemImage: "slider.horizontal.3") }
                .tag(AppTab.filtro)
        }
        .tint(.pink)
    }
}

#Preview {
    MainTabView()
}
