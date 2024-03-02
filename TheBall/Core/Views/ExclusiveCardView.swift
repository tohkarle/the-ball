//
//  ExclusiveCardView.swift
//  TheBall
//
//  Created by Toh Kar Le on 2/3/24.
//

import SwiftUI

struct ExclusiveCardView: View {
    
    @State private var offset: CGSize = .zero
    
    @AppStorage("cardRandomOffsets") private var randomOffsets: [CGSize] = []
    @AppStorage("cardRandomized") private var randomized: Bool = false
    
    @State private var stickiness: Double = 21
    @State private var maxBallCount: Double = 15
    @State private var ballSize: Double = 180
    @State private var bgColor: Color = Color.purple
    @State private var gradient1: Color = Color("gradient1")
    @State private var gradient2: Color = Color("gradient2")
    @State private var gradient3: Color = Color("gradient3")

    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let cardWidth = size.width * 0.81
            let cardHeight = cardWidth * 1.5
            
            VStack {
                RoundedRectangle(cornerRadius: 21, style: .continuous)
                    .fill(bgColor)
                    .frame(width: cardWidth, height: cardHeight)
                    .animation(.easeInOut, value: bgColor)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .overlay {
                GradientColorBackground(setCustomBallColor: true,
                                        gradient1: gradient1,
                                        gradient2: gradient2,
                                        gradient3: gradient3)
                    .mask {
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                            context.addFilter(.blur(radius: stickiness))
                            context.drawLayer { ctx in
                                withAnimation {
                                    for index in 1...Int(maxBallCount) {
                                        if let resolvedView = context.resolveSymbol(id: index) {
                                            ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                        }
                                    }
                                }
                            }
                        } symbols: {
                            ForEach(1...Int(maxBallCount), id: \.self) { index in
                                Ball(width: ballSize,
                                     offset: randomOffsets[index - 1])
                                    .tag(index)
                                    .animation(.easeInOut(duration: 4), value: randomOffsets[index - 1])
                            }
                        }
                    }
                    .offset(x: offset2Angle().degrees * 3, y: offset2Angle(true).degrees * 3)
            }
            .overlay {
                VStack(spacing: 6.0) {
                    Spacer()
                    
                    HStack {
                        Text("Toh Kar Le")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("2 March 2024")
                            .font(.footnote)
                        Spacer()
                    }
                }
                .foregroundStyle(.black)
                .frame(width: cardWidth, height: cardHeight)
                .padding([.leading, .bottom], 45)
                .offset(x: offset2Angle().degrees * 6, y: offset2Angle(true).degrees * 6)
            }
//            .background {
//                
//                VStack {
//                    GradientColorBackground(setCustomBallColor: true,
//                                            gradient1: gradient1,
//                                            gradient2: gradient2,
//                                            gradient3: gradient3)
//                        .mask {
//                            Canvas { context, size in
//                                context.addFilter(.alphaThreshold(min: 0.5, color: .white))
//                                context.addFilter(.blur(radius: stickiness))
//                                context.drawLayer { ctx in
//                                    withAnimation {
//                                        for index in 1...Int(maxBallCount) {
//                                            if let resolvedView = context.resolveSymbol(id: index) {
//                                                ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
//                                            }
//                                        }
//                                    }
//                                }
//                            } symbols: {
//                                ForEach(1...Int(maxBallCount), id: \.self) { index in
//                                    Ball(width: ballSize,
//                                         offset: randomOffsets[index - 1])
//                                        .tag(index)
//                                        .animation(.easeInOut(duration: 4), value: randomOffsets[index - 1])
//                                }
//                            }
//                        }
//                }
//                .background(Color("cardBackgroundColor"))
//                .frame(width: cardWidth, height: cardHeight)
//                .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
//                
//            }
            .rotation3DEffect(offset2Angle(true), axis: (x: -1, y: 0, z: 0))
            .rotation3DEffect(offset2Angle(), axis: (x: 0, y: 1, z: 0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        offset = value.translation
                    })
                    .onEnded({ _ in
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.32, blendDuration: 0.32)) {
                            offset = .zero
                        }
                    })
            )
            .onAppear {
                if !randomized {
                    randomize(cardWidth: cardWidth)
                    randomized = true
                }
            }
            .overlay(alignment: .bottom) {
                Button("Randomize") {
                    randomize(cardWidth: cardWidth)
                }
            }
        }
    }
    
    func randomize(cardWidth: CGFloat) {
//        stickiness = .random(in: 0...30)
//        maxBallCount = .random(in: 3...15)
//        ballSize = .random(in: 90...180)
        
        let randomWidth: Int = Int(cardWidth / 3)
        let randomHeight: Int = Int(Double(randomWidth) * 2)
        
        stickiness = 21
        maxBallCount = 9
        ballSize = 180
        bgColor = randomColor()
        gradient1 = randomColor()
        gradient2 = randomColor()
        gradient3 = randomColor()
        
        randomOffsets = []
        for _ in 0..<Int(maxBallCount) {
            let randomOffset: CGSize = .zero
            randomOffsets.append(randomOffset)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            randomOffsets = []
            for _ in 0..<Int(maxBallCount) {
                let randomOffset = CGSize(width: .random(in: -randomWidth...randomWidth),
                                          height: .random(in: -randomHeight...randomHeight))
                randomOffsets.append(randomOffset)
            }
        }
    }
    
    func randomColor() -> Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        
        return Color(red: red, green: green, blue: blue)
    }
    
    func offset2Angle(_ isVertical: Bool = false) -> Angle {
        let progress = (isVertical ? offset.height : offset.width) / (isVertical ? screenSize.height : screenSize.width)
        return .init(degrees: progress * 15)
    }
    
    var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

#Preview {
    ExclusiveCardView()
}
