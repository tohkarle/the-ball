//
//  AnimateBallView.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI

struct AnimateBallView: View {
    
    @State private var startAnimation: Bool = false
    
    @State private var cornerRadius: CGFloat = 99
    @State private var width: CGFloat = 180
    
    var body: some View {
        VStack {
            GradientColorBackground()
                .mask {
                    TimelineView(.animation(minimumInterval: 3.6, paused: false)) { _ in
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                            context.addFilter(.blur(radius: 36))
                            context.drawLayer { ctx in
                                for index in 1...15 {
                                    if let resolvedView = context.resolveSymbol(id: index) {
                                        ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                    }
                                }
                            }
                        } symbols: {
                            ForEach(1...15, id: \.self) { index in
                                
                                let offset = (startAnimation ? CGSize(width: .random(in: -180...180), height: .random(in: -240...240)) : .zero)
                                
                                Ball(cornerRadius: cornerRadius,
                                     width: width,
                                     offset: offset)
                                    .tag(index)
                                    .animation(.easeInOut(duration: 4), value: offset)
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    startAnimation.toggle()
                }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
