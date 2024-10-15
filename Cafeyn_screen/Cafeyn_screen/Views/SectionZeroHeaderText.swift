//
//  SectionZeroHeaderText.swift
//  Cafeyn_screen
//
//  Created by Antoine Antoiniol on 15/10/2024.
//

import SwiftUI

struct SectionZeroHeaderText: View {
    @State var text = ""
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SectionZeroHeaderText()
}
