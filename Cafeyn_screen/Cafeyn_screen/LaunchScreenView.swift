//
//  LaunchScreenView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 14/10/2024.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            CategoriesView()  // L'écran principal que vous souhaitez afficher après le LaunchScreen
        } else {
            VStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                Text("Welcome to My App")
                    .font(Font.custom("HelveticaNeue-Bold", size: 26))
                    .foregroundColor(.blue.opacity(0.8))
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 0.9
                    self.opacity = 1.0
                }
                // Changer l'écran après un délai (par ex. 2 secondes)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true
                }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
