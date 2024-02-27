//
//  CustomSlider.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct CustomSlider: View {
    
    let title: String
    @Binding var value: Double
    var min: Double = 0
    var max: Double = 99
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(title): \(Int(value))")
                Spacer()
            }
            Slider(value: $value, in: min...max, step: 1)
        }
        .padding(.horizontal)
        .padding(.bottom, 6)
    }
}

#Preview {
    CustomSlider(title: "Corner Radius", value: .constant(20))
}
