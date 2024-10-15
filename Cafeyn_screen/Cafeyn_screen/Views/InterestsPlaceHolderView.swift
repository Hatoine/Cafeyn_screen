//
//  InterestsPlaceHolderView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 15/10/2024.
//

import SwiftUI

//Interests placeholder view
struct InterestsPlaceHolderView: View {
    @State var mainText: String = ""
    @State var subText: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Text(mainText)
                .bold()
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text(subText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
                .background(Color.white)
        )
        .padding()
    }
}

#Preview {
    InterestsPlaceHolderView()
}
