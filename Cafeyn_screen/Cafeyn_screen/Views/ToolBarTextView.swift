//
//  ToolBarTextView.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 15/10/2024.
//

import SwiftUI

//Toolbar text view
struct ToolBarTextView: View {
    @State var toolbarText: String = ""
    
    var body: some View {
        Text(toolbarText)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

#Preview {
    ToolBarTextView()
}
