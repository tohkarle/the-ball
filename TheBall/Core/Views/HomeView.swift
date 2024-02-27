//
//  HomeView.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI
import CoreMotion

struct HomeView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var modeIndex = 0
    let modes = ["Motion", "Drag", "Animate"]
    
    @State private var offset: CGSize = .zero
    
    @State private var allowAllBallsToMove: Bool = false
    @State private var showCustomization: Bool = false
    
    @State private var stickiness: CGFloat = 21
    
    @State private var randomness: CGFloat = 180
    
    @State private var maxBallCount: CGFloat = 6  // Original is 15
    
    @State private var cornerRadius: CGFloat = 99
    @State private var width: CGFloat = 180
    
    @State private var fluidity: CGFloat = 450
    
    var motionService: MotionService = MotionServiceAdapter.shared
    
    @GestureState var press = false
    
    var body: some View {
        VStack {
            GradientColorBackground()
                .mask {
                    TimelineView(.animation(minimumInterval: 3.6, paused: false)) { _ in
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                            context.addFilter(.blur(radius: stickiness))
                            context.drawLayer { ctx in
                                for index in 1...Int(maxBallCount + 4) {
                                    if let resolvedView = context.resolveSymbol(id: index) {
                                        ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                    }
                                }
                            }
                        } symbols: {
                            
//                            ForEach(1...Int(maxBallCount), id: \.self) { index in
//                                
//                                if index == 1 {
//                                    Ball(cornerRadius: cornerRadius,
//                                         width: width,
//                                         offset: offset)
//                                        .tag(1)
//                                } else {
//                                    
//                                    let offset = startAnimation ? offset : .zero
//                                    
//                                    Ball(cornerRadius: cornerRadius,
//                                         width: width,
//                                         offset: offset)
//                                    .tag(index)
//                                    .animation(.easeInOut(duration: TimeInterval(index - 1)), value: offset)
//                                }
//                            }
                            
                            ForEach(1...Int(maxBallCount), id: \.self) { index in
                                
                                if index == 1 {
                                    Ball(cornerRadius: cornerRadius,
                                         width: width,
                                         offset: offset)
                                        .tag(1)
                                } else {
                                    let randomHeight = randomness * (UIScreen.main.bounds.height / UIScreen.main.bounds.width)
                                    let offset = (modeIndex == 2 ? CGSize(width: .random(in: -randomness...randomness), height: .random(in: -randomHeight...randomHeight)) : allowAllBallsToMove ? self.offset : .zero)
                                    
                                    Ball(cornerRadius: cornerRadius,
                                         width: width,
                                         offset: offset)
                                        .tag(index)
                                        .animation(.easeInOut(duration: 4), value: offset)
                                }
                            }
                            
                            Rectangle()
                                .fill(.white)
                                .frame(width: UIScreen.main.bounds.width, height: 40)
                                .offset(y: UIScreen.main.bounds.height / 2 + 20)
                                .tag(Int(maxBallCount + 1))
                            
                            Rectangle()
                                .fill(.white)
                                .frame(width: UIScreen.main.bounds.width, height: 40)
                                .offset(y: -(UIScreen.main.bounds.height / 2 + 20))
                                .tag(Int(maxBallCount + 2))
                            
                            Rectangle()
                                .fill(.white)
                                .frame(width: 40, height: UIScreen.main.bounds.height)
                                .offset(x: UIScreen.main.bounds.width / 2 + 20)
                                .tag(Int(maxBallCount + 3))
                            
                            Rectangle()
                                .fill(.white)
                                .frame(width: 40, height: UIScreen.main.bounds.height)
                                .offset(x: -(UIScreen.main.bounds.width / 2 + 20))
                                .tag(Int(maxBallCount + 4))
                        }
                    }
                }
                .contentShape(Rectangle())
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if modeIndex == 1 {
                                offset = value.translation
                            }
                        }
                        .onEnded { _ in
                            if modeIndex == 1 {
                                resetOffset()
                            }
                        }
                )
        }
        .onTapGesture {
            Haptics.shared.play(.soft)
            modeIndex = (modeIndex + 1) % modes.count
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.9)
                .onEnded({ _ in
                    if modeIndex != 2 {
                        Haptics.shared.play(.soft)
                        allowAllBallsToMove.toggle()
                    }
                })
        )
        .ignoresSafeArea(.all)
        .overlay(alignment: .bottom) {
            VStack {
                Button {
                    withAnimation(.snappy) {
                        showCustomization.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.compact.up")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray.opacity(0.6))
                        .padding(.top)
                        .frame(maxWidth: .infinity)
                        .rotationEffect(Angle(degrees: showCustomization ? 180 : 0), anchor: .center)
                }
                .offset(y: showCustomization ? 0 : UIScreen.main.bounds.height / 2.82)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Picker("Mode", selection: $modeIndex) {
                            ForEach(modes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 21)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 15)
                        if modeIndex == 0 {
                            CustomSlider(title: "Fluidity", value: $fluidity, min: 150, max: 900)
                                .padding(.horizontal, 9)
                        }
                        CustomSlider(title: "Randomness", value: $randomness, min: 0, max: UIScreen.main.bounds.width / 2)
                            .padding(.horizontal, 9)
                        CustomSlider(title: "Stickiness", value: $stickiness)
                            .padding(.horizontal, 9)
                        if modeIndex == 2 {
                            CustomSlider(title: "Ball count", value: $maxBallCount, min: 2, max: 30)
                                .padding(.horizontal, 9)
                        }
                        CustomSlider(title: "Ball size", value: $width, min: 50, max: 300)
                            .padding(.bottom)
                            .padding(.horizontal, 9)
                    }
                    .animation(.easeInOut, value: modeIndex)
                }
                .ignoresSafeArea()
                .frame(height: 300)
                .background {
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .padding()
                .offset(y: showCustomization ? 0 : UIScreen.main.bounds.height)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if modeIndex == 0 {
                    startMonitoring()
                } else if modeIndex == 1 {
                    stopMonitoring()
                }
            } else if newPhase == .background {
                if modeIndex == 0 {
                    stopMonitoring()
                }
            }
        }
        .onChange(of: modeIndex) { newValue in
        
            resetOffset()
            
            switch(newValue) {
            case 0:
                maxBallCount = 3
                startMonitoring()
            case 1:
                maxBallCount = 3
                stopMonitoring()
            case 2:
                maxBallCount = 15
                stopMonitoring()
            default:
                stopMonitoring()
            }
        }
    }
    
    private func resetOffset() {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
            offset = .zero
        }
    }
    
    private func startMonitoring() {
        let stream = motionService.getStream()
        Task {
            for await (x, y, _) in stream {
                await self.updateOffset(x: x, y: y)
            }
        }
    }
    
    private func stopMonitoring() {
        motionService.stopStream()
    }
    
    @MainActor
    private func updateOffset(x: Double, y: Double) {
        withAnimation(.snappy) {
            offset = CGSize(width: x * fluidity, height: -y * fluidity)
        }
    }
}

#Preview {
    ContentView()
}
