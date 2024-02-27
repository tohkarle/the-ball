//
//  GradientColorBackground.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct GradientColorBackground: View {
    var body: some View {
        Rectangle()
            .fill(.linearGradient(colors: [Color("gradient1"), Color("gradient2"), Color("gradient3")], startPoint: .top, endPoint: .bottom))
    }
}

#Preview {
    GradientColorBackground()
}
