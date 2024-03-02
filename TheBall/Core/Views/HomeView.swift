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
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    @StateObject private var viewModel = ColorPresetViewModel()
    
    @State private var offset: CGSize = .zero
    
    let modes = ["Motion", "Animate"]
    @State private var selectedMode: String = "Motion"
    
    let animation = ["Bottom", "Top", "Left", "Right", "All"]
    
    @State private var showCustomization: Bool = false
    @State private var showingConfirmation = false
    
    @AppStorage("selectedPreset") private var selectedPreset: String = ""
    @AppStorage("selectedAnimation") private var selectedAnimation: String = "Bottom"
    @AppStorage("blur") private var blur: Double = 0
    @AppStorage("stickyWall") private var stickyWall: Bool = true
    @AppStorage("stickiness") private var stickiness: Double = 21
    @AppStorage("randomness") private var randomness: Double = 150
    @AppStorage("moveBallCount") private var moveBallCount: Double = 1
    @AppStorage("maxBallCount") private var maxBallCount: Double = 15
    @AppStorage("ballSize") private var ballSize: Double = 180
    @AppStorage("fluidity") private var fluidity: Double = 450
    @AppStorage("setCustomBgColor") private var setCustomBgColor: Bool = false
    @AppStorage("bgColor") private var bgColor: Color = Color.black
    @AppStorage("setCustomBallColor") private var setCustomBallColor: Bool = false
    @AppStorage("gradient1") private var gradient1: Color = Color("gradient1")
    @AppStorage("gradient2") private var gradient2: Color = Color("gradient2")
    @AppStorage("gradient3") private var gradient3: Color = Color("gradient3")
    
    var motionService: MotionService = MotionServiceAdapter.shared
    
    @State private var showSavePresetSheet: Bool = false
    @State private var showPresetsSheet: Bool = false
    @State private var presetName: String = ""
    @State private var showTipJar: Bool = false
    
    var body: some View {
        
        VStack {
            GradientColorBackground(setCustomBallColor: setCustomBallColor,
                                    gradient1: gradient1,
                                    gradient2: gradient2,
                                    gradient3: gradient3)
                .mask {
                    CanvasView(selectedMode: selectedMode, selectedAnimation: selectedAnimation, offset: offset, blur: blur, stickyWall: stickyWall, stickiness: stickiness, randomness: randomness, moveBallCount: moveBallCount, maxBallCount: maxBallCount, ballSize: ballSize, fluidity: fluidity, setCustomBgColor: setCustomBgColor, bgColor: bgColor, setCustomBallColor: setCustomBallColor, gradient1: gradient1, gradient2: gradient2, gradient3: gradient3)
                }
                .contentShape(Rectangle())
        }
        .background(setCustomBgColor ? bgColor : Color.clear)
        .onTapGesture {
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
                        if selectedMode == "Animate" {
                            Picker("Animation", selection: $selectedAnimation) {
                                ForEach(animation, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 15)
                        }
                        CustomSlider(title: "Stickiness", value: $stickiness)
                            .padding(.horizontal, 9)
                        if selectedMode == "Animate" {
                            CustomSlider(title: "Randomness", value: $randomness, min: 0, max: UIScreen.main.bounds.width / 2)
                                .padding(.horizontal, 9)
                            CustomSlider(title: "Animating ball", value: $maxBallCount, min: 3, max: 30)
                                .padding(.horizontal, 9)
                        } else {
                            CustomSlider(title: "Sensitivity", value: $fluidity, min: 150, max: 900)
                                .padding(.horizontal, 9)
                            CustomSlider(title: "Moving ball", value: $moveBallCount, min: 0, max: 3)
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
                        
                        VStack(spacing: 12.0) {
                            CustomButton(title: "Save settings as preset") {
                                showSavePresetSheet = true
                            }
                            .padding(.horizontal, 24)
                            if !viewModel.savedEntities.isEmpty {
                                CustomButton(title: "Load presets") {
                                    showPresetsSheet = true
                                }
                                .padding(.horizontal, 24)
                            }
                            CustomButton(title: "Reset to defaults") {
                                showingConfirmation = true
                            }
                            .padding(.horizontal, 24)
                            .confirmationDialog("Confirmation", isPresented: $showingConfirmation) {
                                Button("Confirm reset", role: .destructive) {
                                    reset()
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("Are you sure you want to reset to default values?")
                            }
                            Button {
                                showTipJar = true
                            } label: {
                                HStack(spacing: 3.0) {
                                    Image(systemName: "hands.clap")
                                    Text("Tip jar")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 39)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)
                            HStack(spacing: 12.0) {
                                Link("Privacy Policy", destination: URL(string: "https://sites.google.com/view/the-ball-app/privacy-policy")!)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 39)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                                
                                Link("Terms of Service", destination: URL(string: "https://sites.google.com/view/the-ball-app/terms-of-service?authuser=0")!)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 39)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 27)
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
            Haptics.shared.play(.soft)
            if selectedMode == "Motion" {
                startMonitoring()
            } else {
                resetOffset()
                stopMonitoring()
            }
        }
        .onChange(of: viewModel.savedEntities.count) { newValue in
            if newValue == 0 {
                showPresetsSheet = false
            }
        }
        .sheet(isPresented: $showSavePresetSheet) {
            VStack(spacing: 0.0) {
                TextField("Give a name for your preset", text: $presetName)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 60)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .padding(.top, 45)
                    .padding(.horizontal, 21)
                
                Button {
                    guard !presetName.isEmpty else { return }
                    let id = UUID()
                    viewModel.addColorPreset(id: id, name: presetName, selectedAnimation: selectedAnimation, blur: blur, stickyWall: stickyWall, stickiness: stickiness, randomness: randomness, moveBallCount: moveBallCount, maxBallCount: maxBallCount, ballSize: ballSize, fluidity: fluidity, setCustomBgColor: setCustomBgColor, bgColor: bgColor, setCustomBallColor: setCustomBallColor, gradient1: gradient1, gradient2: gradient2, gradient3: gradient3)
                    selectedPreset = id.uuidString
                    showSavePresetSheet = false
                    presetName = ""
                } label: {
                    Text("Save as preset")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .padding(.horizontal, 21)
                        .padding(.vertical)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .presentationDragIndicator(.visible)
            .presentationDetents([.height(150)])
        }
        .sheet(isPresented: $showPresetsSheet) {
            List {
                ForEach(viewModel.savedEntities) { preset in
                    HStack {
                        Button(preset.name ?? "Preset") {
                            selectedPreset = preset.id?.uuidString ?? ""
                            selectedAnimation = preset.selectedAnimation ?? "Bottom"
                            blur = preset.blur
                            stickyWall = preset.stickyWall
                            stickiness = preset.stickiness
                            randomness = preset.randomness
                            moveBallCount = preset.moveBallCount
                            maxBallCount = preset.maxBallCount
                            ballSize = preset.ballSize
                            fluidity = preset.fluidity
                            setCustomBgColor = preset.setCustomBgColor
                            bgColor = Color.init(rawValue: Int(preset.bgColor)) ?? Color.black
                            setCustomBallColor = preset.setCustomBallColor
                            gradient1 = Color.init(rawValue: Int(preset.gradient1)) ?? Color("gradient1")
                            gradient2 = Color.init(rawValue: Int(preset.gradient2)) ?? Color("gradient2")
                            gradient3 = Color.init(rawValue: Int(preset.gradient3)) ?? Color("gradient3")
                        }
                        
                        Spacer()
                        
                        if selectedPreset == preset.id?.uuidString {
                            Image(systemName: "checkmark")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                .onDelete(perform: viewModel.delete)
        
            }
            .presentationDetents([.height(150), .medium])
        }
        .sheet(isPresented: $showTipJar) {
            TipJarView()
                .presentationDragIndicator(.visible)
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
                self.updateOffset(x: x, y: y)
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
        selectedPreset = ""
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

#Preview {
    ContentView()
}
