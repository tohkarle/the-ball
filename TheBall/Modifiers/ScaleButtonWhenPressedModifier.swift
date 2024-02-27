//
//  ScaleButtonWhenPressedModifier.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct ScaleButtonWhenPressedModifier: ViewModifier {
    
    var scaleEffect: CGFloat = 0.96
    var duration: Double = 0.15
    
    var action: () -> Void
    
    @State private var pressing: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(pressing ? scaleEffect : 1)
            ._onButtonGesture(pressing: { pressing in
                withAnimation(.easeInOut(duration: duration)) {
                    self.pressing = pressing
                }
            }, perform: {
                action()
            })
    }
}

extension View {
    func scaleButtonWhenPressed(scaleEffect: CGFloat = 0.96, duration: Double = 0.15, action: @escaping () -> Void) -> some View {
        self.modifier(ScaleButtonWhenPressedModifier(scaleEffect: scaleEffect, duration: duration, action: action))
    }
}

