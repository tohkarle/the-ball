//
//  CanvasView.swift
//  TheBall
//
//  Created by Toh Kar Le on 27/2/24.
//

import SwiftUI

struct CanvasView: View {
    
    var selectedMode: String
    var selectedAnimation: String
    var offset: CGSize
    var blur: Double
    var stickyWall: Bool
    var stickiness: Double
    var randomness: Double
    var moveBallCount: Double
    var maxBallCount: Double
    var ballSize: Double
    var fluidity: Double
    var setCustomBgColor: Bool
    var bgColor: Color
    var setCustomBallColor: Bool
    var gradient1: Color
    var gradient2: Color
    var gradient3: Color
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 3.6, paused: false)) { _ in
            Canvas { context, size in
                context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                context.addFilter(.blur(radius: stickiness))
                context.drawLayer { ctx in
                    withAnimation {
                        for index in 1...34 {
                            if let resolvedView = context.resolveSymbol(id: index) {
                                ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                        }
                    }
                }
            } symbols: {
                
                let randomHeight = randomness * (UIScreen.main.bounds.height / UIScreen.main.bounds.width)
                
                let ball1Offset = selectedMode == "Animate" ? CGSize(width: .random(in: -randomness...randomness), height: .random(in: -randomHeight...randomHeight)) : moveBallCount > 0 ? offset : .zero
                Ball(width: ballSize,
                     offset: ball1Offset)
                .tag(1)
                .animation(selectedMode == "Motion" ? .snappy : .easeInOut(duration: 4), value: ball1Offset)
                
                let ball2Offset = selectedMode == "Animate" ? CGSize(width: .random(in: -randomness...randomness), height: .random(in: -randomHeight...randomHeight)) : moveBallCount > 1 ? offset : .zero
                Ball(width: ballSize,
                     offset: ball2Offset)
                .tag(2)
                .animation(.easeInOut(duration: selectedMode == "Animate" ? 4 : 1), value: ball2Offset)
                
                let ball3Offset = selectedMode == "Animate" ? CGSize(width: .random(in: -randomness...randomness), height: .random(in: -randomHeight...randomHeight)) : moveBallCount > 2 ? offset : .zero
                Ball(width: ballSize,
                     offset: ball3Offset)
                .tag(3)
                .animation(.easeInOut(duration: selectedMode == "Animate" ? 4 : 2), value: ball3Offset)
                
                ForEach(0...26, id: \.self) { index in
                    let scale = Int(maxBallCount)
                    let bottom = CGSize(width: 0, height: UIScreen.main.bounds.height / 1.5)
                    let top = CGSize(width: 0, height: -UIScreen.main.bounds.height / 1.5)
                    let left = CGSize(width: -UIScreen.main.bounds.width, height: 0)
                    let right = CGSize(width: UIScreen.main.bounds.width, height: 0)
                    let selected = selectedAnimation == "Bottom" ? bottom : selectedAnimation == "Top" ? top : selectedAnimation == "Left" ? left : right
                    let all = [CGSize(width: CGFloat(index * scale), height: UIScreen.main.bounds.height / 1.5),
                               CGSize(width: -CGFloat(index * scale), height: -UIScreen.main.bounds.height / 1.5),
                               CGSize(width: CGFloat(index * scale), height: -UIScreen.main.bounds.height / 1.5),
                               CGSize(width: -CGFloat(index * scale), height: UIScreen.main.bounds.height / 1.5),
                               CGSize(width: UIScreen.main.bounds.width, height: CGFloat(index * scale)),
                               CGSize(width: -UIScreen.main.bounds.width, height: -CGFloat(index * scale)),
                               CGSize(width: UIScreen.main.bounds.width, height: -CGFloat(index * scale)),
                               CGSize(width: -UIScreen.main.bounds.width, height: CGFloat(index * scale))]
                    let offset = (selectedMode == "Animate" && Int(maxBallCount) >= index + 4 ? CGSize(width: .random(in: -randomness...randomness), height: .random(in: -randomHeight...randomHeight)) : selectedAnimation == "All" ? all[index % 8] : selected)
                    
                    Ball(width: ballSize,
                         offset: offset)
                        .tag(index + 4)
                        .animation(.easeInOut(duration: 4), value: offset)
                }
                
                if stickyWall {
                    Rectangle()
                        .fill(.white)
                        .frame(width: UIScreen.main.bounds.width, height: 40)
                        .offset(y: UIScreen.main.bounds.height / 2 + 20)
                        .tag(31)
                    
                    Rectangle()
                        .fill(.white)
                        .frame(width: UIScreen.main.bounds.width, height: 40)
                        .offset(y: -(UIScreen.main.bounds.height / 2 + 20))
                        .tag(32)
                    
                    Rectangle()
                        .fill(.white)
                        .frame(width: 40, height: UIScreen.main.bounds.height)
                        .offset(x: UIScreen.main.bounds.width / 2 + 20)
                        .tag(33)
                    
                    Rectangle()
                        .fill(.white)
                        .frame(width: 40, height: UIScreen.main.bounds.height)
                        .offset(x: -(UIScreen.main.bounds.width / 2 + 20))
                        .tag(34)
                }
            }
        }
        .blur(radius: blur)
    }
}
