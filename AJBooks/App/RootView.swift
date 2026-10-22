//
//  RootView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 11/10/26.
//

//VA A ELEGIR LA VISTA A MOSTRAR

import SwiftUI

struct RootView: View {
    @State private var hasEntered = false

    var body: some View {
        if hasEntered {
            MainTabView()
        } else {
            ContentView(onEnter: {
                hasEntered = true
            })
        }
    }
}

#Preview {
    RootView()
}
