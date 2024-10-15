//
//  NoCategoriesView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 15/10/2024.
//

import SwiftUI

//Categories placeholder view
struct NoCategoriesView: View {
    @State var noCategoriesText: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Text(noCategoriesText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        ).padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 0))
    }
}


#Preview {
    NoCategoriesView()
}
