//
//  LaunchScreenView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 14/10/2024.
//

import SwiftUI

//Launchscreen animated view
struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            //Main app screen after launchscreen
            CategoriesView()
        } else {
            ZStack {
                Color(UIColor(named: "BackgroundColor_launch") ?? .white)
                    .ignoresSafeArea()
                VStack {
                    Image(.cafeyn)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .frame(width: 20, height: 20)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 3)) {
                        self.size = 170
                        self.opacity = 1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.isActive = true
                    }
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
