//
//  ContentView.swift
//  AJBooks
//
//  Created by Jolette Rivera on 26/09/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var text :String = ""
    let test: Bool = false
    var body: some View {
        
        ZStack{
            Color.cyan
            .ignoresSafeArea()
        
        
            VStack{
                Text("Bienvenido")
                    .font(.system(size: 40))
                    .padding()
                    .fontDesign(.rounded)
                
                Text("AJBooks")
                    .font(.system(size: 60))
                    .bold()
                    .fontDesign(.serif)
                
                
                Button {
                    
                } label :{
                    Text ("Entrar")
                        .padding() //espaciado (horizontal,vertical,etc,etc..
                        .font(.title)
                        .bold()
                        .fontDesign(.serif)
                        .foregroundStyle(.black)
                        .background(.yellow)
                        .clipShape(RoundedRectangle (cornerRadius: 20))
                    
                        .accessibilityLabel("Boton Entrar")
                        .accessibilityHint("Toca dos veces para ingresar a la aplicación")
                        .accessibilityAddTraits(.isButton)
                }
                
            }
        }
    }
}

#Preview {
    ContentView()
}
