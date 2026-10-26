//
//  MainTabView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

import SwiftUI

enum AppTab: Hashable {
    case home, search, favorites, filter
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    
    

    var body: some View {
        TabView(selection: $selectedTab) {
            BookListView()
                .tabItem { Label("Inicio", systemImage: "books.vertical") }
                .tag(AppTab.home)

            BookSearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            FavoritesView()
                .tabItem { Label("Saved", systemImage: "heart") }
                .tag(AppTab.favorites)

            CategoryFilterView()
                .tabItem { Label("Filter", systemImage: "slider.horizontal.3") }
                .tag(AppTab.filter)
        }
        .tint(.pink)
    }
}

#Preview {
    MainTabView()
}
