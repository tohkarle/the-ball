//
//  HomeView.swift
//  TheBall
//
//  Created by Toh Kar Le on 25/2/24.
//

import SwiftUI
import CoreMotion

#if os(iOS)
typealias PlatformColor = UIColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(uiColor: platformColor)
    }
}
#elseif os(macOS)
typealias PlatformColor = NSColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(nsColor: platformColor)
    }
}
#endif

struct HomeView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var offset: CGSize = .zero
    
    let modes = ["Motion", "Animate"]
    @State private var selectedMode: String = "Motion"
    
    @State private var showCustomization: Bool = false
    @State private var showingConfirmation = false
    
    @AppStorage("blur") private var blur: Double = 0
    @AppStorage("stickyWall") private var stickyWall: Bool = true
    @AppStorage("stickiness") private var stickiness: Double = 21
    @AppStorage("randomness") private var randomness: Double = 150
    @AppStorage("moveBallCount") private var moveBallCount: Double = 1
    @AppStorage("maxBallCount") private var maxBallCount: Double = 15
    @AppStorage("ballSize") private var ballSize: Double = 180
    @AppStorage("fluidity") private var fluidity: Double = 450
    @AppStorage("setCustomBgColor") private var setCustomBgColor: Bool = false
    @AppStorage("bgColor") private var bgColor = Color.black
    @AppStorage("setCustomBallColor") private var setCustomBallColor: Bool = false
    @AppStorage("gradient1") private var gradient1 = Color("gradient1")
    @AppStorage("gradient2") private var gradient2 = Color("gradient2")
    @AppStorage("gradient3") private var gradient3 = Color("gradient3")
    
    var motionService: MotionService = MotionServiceAdapter.shared
    
    @GestureState var press = false
    
    var body: some View {
        VStack {
            GradientColorBackground(setCustomBallColor: setCustomBallColor,
                                    gradient1: gradient1,
                                    gradient2: gradient2,
                                    gradient3: gradient3)
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
                            
                            ForEach(1...Int(maxBallCount), id: \.self) { index in
                                
                                if index == 1 {
                                    Ball(width: ballSize,
                                         offset: offset)
                                    .tag(1)
                                } else if index == 2 && moveBallCount > 1 {
                                    Ball(width: ballSize,
                                         offset: offset)
                                    .tag(2)
                                    .animation(.easeInOut(duration: 1), value: offset)
                                } else if index == 3 && moveBallCount > 2 {
                                    Ball(width: ballSize,
                                         offset: offset)
                                    .tag(3)
                                    .animation(.easeInOut(duration: 2), value: offset)
                                } else {
                                let randomHeight = randomness * (UIScreen.main.bounds.height / UIScreen.main.bounds.width)
                                let offset = (selectedMode == "Animate" ? CGSize(width: .random(in: -randomness...randomness), height: .random(in: -randomHeight...randomHeight)) : .zero)
                                
                                Ball(width: ballSize,
                                     offset: offset)
                                    .tag(index)
                                    .animation(.easeInOut(duration: 4), value: offset)
                                }
                            }
                            
                            if stickyWall {
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
                    .blur(radius: blur)
                }
                .contentShape(Rectangle())
        }
        .background(setCustomBgColor ? bgColor : Color.clear)
        .onTapGesture {
            Haptics.shared.play(.soft)
            if selectedMode == "Motion" {
                selectedMode = "Animate"
            } else {
                selectedMode = "Motion"
            }
        }
        .ignoresSafeArea(.all)
        .overlay(alignment: .bottom) {
            VStack(spacing: 0.0) {
                Button {
                    withAnimation(.snappy) {
                        showCustomization.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.compact.up")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray.opacity(0.6))
                        .rotationEffect(Angle(degrees: showCustomization ? 180 : 0), anchor: .center)
                        .padding([.top, .horizontal], 36)
                        .padding(.bottom, 15)
                }
                .offset(y: showCustomization ? 0 : UIScreen.main.bounds.height / 2.82)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(modes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding([.top, .horizontal], 24)
                        .padding(.bottom, 15)
                        CustomSlider(title: "Stickiness", value: $stickiness)
                            .padding(.horizontal, 9)
                        if selectedMode == "Animate" {
                            CustomSlider(title: "Randomness", value: $randomness, min: 0, max: UIScreen.main.bounds.width / 2)
                                .padding(.horizontal, 9)
                            CustomSlider(title: "Animating ball", value: $maxBallCount, min: 2, max: 30)
                                .padding(.horizontal, 9)
                        } else {
                            CustomSlider(title: "Sensitivity", value: $fluidity, min: 150, max: 900)
                                .padding(.horizontal, 9)
                            CustomSlider(title: "Moving ball", value: $moveBallCount, min: 1, max: 3)
                                .padding(.horizontal, 9)
                        }
                        CustomSlider(title: "Ball size", value: $ballSize, min: 50, max: 300)
                            .padding(.horizontal, 9)
                        CustomSlider(title: "Blur", value: $blur, min: 0, max: 60)
                            .padding(.horizontal, 9)
                        Toggle("Sticky wall", isOn: $stickyWall)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 9)
                        Toggle("Custom background color", isOn: $setCustomBgColor)
                            .padding(.horizontal, 24)
                            .padding(.bottom, setCustomBgColor ? 0 : 9)
                        if setCustomBgColor {
                            ColorPicker("Background color", selection: $bgColor)
                                .padding(.leading, 15)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 9)
                        }
                        Toggle("Custom ball color", isOn: $setCustomBallColor)
                            .padding(.horizontal, 24)
                            .padding(.bottom, setCustomBallColor ? 0 : 12)
                        if setCustomBallColor {
                            ColorPicker("Gradient 1", selection: $gradient1)
                                .padding(.leading, 15)
                                .padding(.horizontal, 24)
                            ColorPicker("Gradient 2", selection: $gradient2)
                                .padding(.leading, 15)
                                .padding(.horizontal, 24)
                            ColorPicker("Gradient 3", selection: $gradient3)
                                .padding(.leading, 15)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                        }
                        Button("Reset to defaults") {
                            showingConfirmation = true
                        }
                        .padding(.bottom, 27)
                        .confirmationDialog("Confirmation", isPresented: $showingConfirmation) {
                            Button("Confirm reset", role: .destructive) {
                                reset()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to reset to default values?")
                        }
                    }
                    .animation(.easeInOut, value: selectedMode)
                    .animation(.easeInOut, value: setCustomBgColor)
                }
                .frame(height: 300)
                .background {
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .padding([.horizontal, .bottom])
                .offset(y: showCustomization ? 0 : UIScreen.main.bounds.height)
            }
            .ignoresSafeArea(.all)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                startMonitoring()
            } else if newPhase == .background {
                stopMonitoring()
            }
        }
        .onChange(of: selectedMode) { newValue in
            if selectedMode == "Motion" {
                startMonitoring()
            } else {
                resetOffset()
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
        if selectedMode == "Motion" {
            withAnimation(.snappy) {
                offset = CGSize(width: x * CGFloat(fluidity), height: -y * CGFloat(fluidity))
            }
        }
    }
    
    private func reset() {
        blur = 0
        stickyWall = true
        stickiness = 21
        randomness = 150
        moveBallCount = 1
        maxBallCount = 15
        ballSize = 180
        fluidity = 450
        setCustomBgColor = false
        bgColor = Color.black
        setCustomBallColor = false
        gradient1 = Color("gradient1")
        gradient2 = Color("gradient2")
        gradient3 = Color("gradient3")
    }
}

extension Color: RawRepresentable {
    // TODO: Sort out alpha
    public init?(rawValue: Int) {
        let red =   Double((rawValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rawValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rawValue & 0x0000FF) / 0xFF
        self = Color(red: red, green: green, blue: blue)
    }

    public var rawValue: Int {
        guard let coreImageColor = coreImageColor else {
            return 0
        }
        let red = Int(coreImageColor.red * 255 + 0.5)
        let green = Int(coreImageColor.green * 255 + 0.5)
        let blue = Int(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }

    private var coreImageColor: CIColor? {
        return CIColor(color: PlatformColor(self))
    }
}

#Preview {
    ContentView()
}
