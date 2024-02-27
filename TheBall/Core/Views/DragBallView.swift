//
//  HomeView.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct DragBallView: View {
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.linearGradient(colors: [Color("gradient1"), Color("gradient2"), Color("gradient3")], startPoint: .top, endPoint: .bottom))
                .mask {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                        context.addFilter(.blur(radius: 21))
                        context.drawLayer { ctx in
                            for index in [1, 2] {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        Ball()
                            .tag(1)
                        
                        Ball(offset: dragOffset)
                            .tag(2)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                dragOffset = .zero
                            }
                        }
                )
        }
    }
}

#Preview {
    ContentView()
}
