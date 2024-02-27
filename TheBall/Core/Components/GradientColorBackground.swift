//
//  GradientColorBackground.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct GradientColorBackground: View {
    
    var setCustomBallColor: Bool = false
    var gradient1 = Color("gradient1")
    var gradient2 = Color("gradient2")
    var gradient3 = Color("gradient3")
    
    var body: some View {
        Rectangle()
            .fill(.linearGradient(colors: [setCustomBallColor ? gradient1 : Color("gradient1"),
                                           setCustomBallColor ? gradient2 : Color("gradient2"),
                                           setCustomBallColor ? gradient3 : Color("gradient3")], 
                                  startPoint: .top,
                                  endPoint: .bottom))
    }
}

#Preview {
    GradientColorBackground()
}
