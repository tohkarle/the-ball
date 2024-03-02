//
//  CustomButton.swift
//  TheBall
//
//  Created by Toh Kar Le on 1/3/24.
//

import SwiftUI

struct CustomButton: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .frame(height: 39)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    CustomButton(title: "Reset to defaults") {}
}
