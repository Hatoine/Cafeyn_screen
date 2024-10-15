//
//  SectionOneHeaderText.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 15/10/2024.
//

import SwiftUI

struct SectionOneHeaderText: View {
    @State var headerText: String = ""
    
    var body: some View {
        Text(headerText)
            .font(.headline)
            .padding(.top, 20)
    }
}

#Preview {
    SectionOneHeaderText()
}
