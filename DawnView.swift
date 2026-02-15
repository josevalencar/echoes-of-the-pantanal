//
//  DawnView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Scene 2: Dawn in the Pantanal — the emotional centerpiece with layered animations.

import SwiftUI

struct DawnView: View {
    let onBegin: () -> Void
    
    @State private var showBackground = false
    @State private var showSun = false
    @State private var showVegetation = false
    @State private var showWater = false
    @State private var showTitle = false
    @State private var showSoundWaves = false
    @State private var showCTA = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DawnGradientBackground()
                    .opacity(showBackground ? 1 : 0)
                
                SunGlow()
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.16)
                    .opacity(showSun ? 1 : 0)
                    .scaleEffect(showSun ? 1 : 0.8)
                
                VegetationLeft()
                    .opacity(showVegetation ? 0.85 : 0)
                
                VegetationRight(width: geometry.size.width)
                    .opacity(showVegetation ? 0.85 : 0)
                
                WaterLayer(height: geometry.size.height)
                    .opacity(showWater ? 1 : 0)
                
                WaterRipples()
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.79)
                    .opacity(showWater ? 1 : 0)
                
                FirefliesView()
                
                if showSoundWaves {
                    SoundWaveBars()
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.62)
                }
                
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.24)
                    
                    DawnTitle()
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 15)
                    
                    Spacer()
                    
                    DawnCTA(onBegin: onBegin)
                        .opacity(showCTA ? 1 : 0)
                        .offset(y: showCTA ? 0 : 20)
                        .padding(.bottom, 70)
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await animateEntrance()
        }
    }
    
    private func animateEntrance() async {
        withAnimation(.easeOut(duration: 3.0)) {
            showBackground = true
        }
        
        try? await Task.sleep(for: .milliseconds(500))
        withAnimation(.easeOut(duration: 2.5)) {
            showSun = true
        }
        
        try? await Task.sleep(for: .milliseconds(800))
        withAnimation(.easeOut(duration: 2.0)) {
            showVegetation = true
        }
        
        try? await Task.sleep(for: .milliseconds(600))
        withAnimation(.easeOut(duration: 2.0)) {
            showWater = true
        }
        
        try? await Task.sleep(for: .milliseconds(500))
        withAnimation(.easeOut(duration: 2.5)) {
            showTitle = true
        }
        
        try? await Task.sleep(for: .milliseconds(1000))
        withAnimation(.easeOut(duration: 2.0)) {
            showSoundWaves = true
        }
        
        try? await Task.sleep(for: .milliseconds(1000))
        withAnimation(.easeOut(duration: 1.5)) {
            showCTA = true
        }
    }
}

struct DawnGradientBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color.dawnSkyDark, location: 0),
                .init(color: Color(red: 19/255, green: 44/255, blue: 34/255), location: 0.2),
                .init(color: Color.pantanalMid, location: 0.4),
                .init(color: Color(red: 35/255, green: 96/255, blue: 63/255), location: 0.55),
                .init(color: Color.pantanalMid, location: 0.7),
                .init(color: Color(red: 26/255, green: 64/255, blue: 48/255), location: 0.85),
                .init(color: Color.pantanalDark, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct SunGlow: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pantanalDawn.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pantanalGold.opacity(0.3),
                            Color.pantanalAmber.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 180, height: 180)
        }
    }
}

struct VegetationLeft: View {
    var body: some View {
        Canvas { context, size in
            let stemPath = Path { path in
                path.move(to: CGPoint(x: 40, y: size.height * 0.74))
                path.addQuadCurve(
                    to: CGPoint(x: 20, y: size.height * 0.59),
                    control: CGPoint(x: 32, y: size.height * 0.65)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 14, y: size.height * 0.52),
                    control: CGPoint(x: 8, y: size.height * 0.56)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 24, y: size.height * 0.45),
                    control: CGPoint(x: 10, y: size.height * 0.49)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 28, y: size.height * 0.37),
                    control: CGPoint(x: 18, y: size.height * 0.42)
                )
            }
            
            context.stroke(
                stemPath,
                with: .color(Color.pantanalMid.opacity(0.85)),
                lineWidth: 3.5
            )
            
            let secondStem = Path { path in
                path.move(to: CGPoint(x: 55, y: size.height * 0.74))
                path.addQuadCurve(
                    to: CGPoint(x: 68, y: size.height * 0.64),
                    control: CGPoint(x: 62, y: size.height * 0.69)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 62, y: size.height * 0.58),
                    control: CGPoint(x: 74, y: size.height * 0.60)
                )
            }
            
            context.stroke(
                secondStem,
                with: .color(Color.pantanalMid.opacity(0.6)),
                lineWidth: 2.5
            )
            
            context.fill(
                Path(ellipseIn: CGRect(x: 0, y: size.height * 0.34, width: 48, height: 84)),
                with: .color(Color.pantanalDark.opacity(0.75))
            )
            
            context.fill(
                Path(ellipseIn: CGRect(x: 38, y: size.height * 0.40, width: 40, height: 70)),
                with: .color(Color.pantanalDark.opacity(0.55))
            )
            
            context.fill(
                Path(ellipseIn: CGRect(x: -2, y: size.height * 0.47, width: 32, height: 56)),
                with: .color(Color.pantanalDark.opacity(0.65))
            )
        }
    }
}

struct VegetationRight: View {
    let width: CGFloat
    
    var body: some View {
        Canvas { context, size in
            let stemPath = Path { path in
                path.move(to: CGPoint(x: width - 40, y: size.height * 0.74))
                path.addQuadCurve(
                    to: CGPoint(x: width - 20, y: size.height * 0.59),
                    control: CGPoint(x: width - 32, y: size.height * 0.65)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width - 14, y: size.height * 0.52),
                    control: CGPoint(x: width - 8, y: size.height * 0.56)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width - 24, y: size.height * 0.46),
                    control: CGPoint(x: width - 10, y: size.height * 0.49)
                )
            }
            
            context.stroke(
                stemPath,
                with: .color(Color.pantanalMid.opacity(0.85)),
                lineWidth: 3.5
            )
            
            let secondStem = Path { path in
                path.move(to: CGPoint(x: width - 55, y: size.height * 0.74))
                path.addQuadCurve(
                    to: CGPoint(x: width - 68, y: size.height * 0.64),
                    control: CGPoint(x: width - 62, y: size.height * 0.69)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width - 62, y: size.height * 0.58),
                    control: CGPoint(x: width - 74, y: size.height * 0.60)
                )
            }
            
            context.stroke(
                secondStem,
                with: .color(Color.pantanalMid.opacity(0.6)),
                lineWidth: 2.5
            )
            
            context.fill(
                Path(ellipseIn: CGRect(x: width - 52, y: size.height * 0.42, width: 56, height: 96)),
                with: .color(Color.pantanalDark.opacity(0.75))
            )
            
            context.fill(
                Path(ellipseIn: CGRect(x: width - 78, y: size.height * 0.48, width: 40, height: 64)),
                with: .color(Color.pantanalDark.opacity(0.55))
            )
        }
    }
}

struct WaterLayer: View {
    let height: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            LinearGradient(
                stops: [
                    .init(color: Color.pantanalWater.opacity(0), location: 0),
                    .init(color: Color.pantanalWater.opacity(0.3), location: 0.3),
                    .init(color: Color.pantanalDark.opacity(0.7), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: height * 0.35)
        }
    }
}

struct WaterRipples: View {
    var body: some View {
        ZStack {
            WaterRipple(width: 160, height: 50, delay: 1.5)
            WaterRipple(width: 120, height: 38, delay: 2.8)
            WaterRipple(width: 80, height: 26, delay: 4.0)
        }
    }
}

struct WaterRipple: View {
    let width: CGFloat
    let height: CGFloat
    let delay: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        Ellipse()
            .strokeBorder(Color.pantanalGold.opacity(0.18), lineWidth: 1)
            .frame(width: isAnimating ? width : 0, height: isAnimating ? height : 0)
            .opacity(isAnimating ? 0 : 0.5)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 4)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct FirefliesView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Firefly(size: 4)
                    .position(x: geometry.size.width * 0.18, y: geometry.size.height * 0.28)
                    .modifier(FireflyAnimation(delay: 1.0))
                
                Firefly(size: 4)
                    .position(x: geometry.size.width * 0.84, y: geometry.size.height * 0.42)
                    .modifier(FireflyAnimation(delay: 2.5))
                
                Firefly(size: 4)
                    .position(x: geometry.size.width * 0.38, y: geometry.size.height * 0.50)
                    .modifier(FireflyAnimation(delay: 3.5))
                
                Firefly(size: 3)
                    .position(x: geometry.size.width * 0.72, y: geometry.size.height * 0.35)
                    .modifier(FireflyAnimation(delay: 1.5))
            }
        }
    }
}

struct Firefly: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.pantanalGold)
            .frame(width: size, height: size)
            .shadow(color: Color.pantanalGold.opacity(0.5), radius: 8)
    }
}

struct FireflyAnimation: ViewModifier {
    let delay: Double
    
    @State private var phase: Double = 0
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .opacity(calculateOpacity())
            .offset(offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    phase = 1
                    offset = CGSize(width: 6, height: -12)
                }
            }
    }
    
    private func calculateOpacity() -> Double {
        let progress = phase
        if progress < 0.25 { return progress * 3.2 }
        if progress < 0.5 { return 0.8 - (progress - 0.25) * 1.6 }
        if progress < 0.75 { return 0.4 + (progress - 0.5) * 1.2 }
        return 0.7 - (progress - 0.75) * 2.8
    }
}

struct SoundWaveBars: View {
    let barHeights: [CGFloat] = [8, 16, 24, 18, 30, 20, 12]
    let delays: [Double] = [0, 0.1, 0.2, 0.15, 0.25, 0.12, 0.3]
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { index in
                SoundWaveBar(
                    height: barHeights[index],
                    delay: delays[index]
                )
            }
        }
    }
}

struct SoundWaveBar: View {
    let height: CGFloat
    let delay: Double
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.pantanalGold.opacity(0.55))
            .frame(width: 3, height: height)
            .scaleEffect(y: scale, anchor: .center)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.7)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    scale = 0.35
                }
            }
    }
}

struct DawnTitle: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Echoes of the\nPantanal")
                .font(.pantanalTitle(44))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .shadow(color: .black.opacity(0.5), radius: 24, y: 2)
            
            Text("Listen to nature")
                .font(.pantanalLabel(12))
                .foregroundStyle(Color.pantanalGold.opacity(0.6))
                .tracking(5)
                .textCase(.uppercase)
        }
    }
}

struct DawnCTA: View {
    let onBegin: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            Button(action: onBegin) {
                HStack(spacing: 6) {
                    Image(systemName: "headphones")
                        .font(.system(size: 16, weight: .light))
                    Text("Begin")
                        .font(.pantanalUI(15))
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.textPrimary.opacity(0.9))
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(dawnButtonBackground)
            }
            .buttonStyle(.plain)
            
            Text("3 min · headphones recommended")
                .font(.pantanalCaption(11))
                .foregroundStyle(Color.textMuted)
                .tracking(1)
        }
    }
    
    @ViewBuilder
    private var dawnButtonBackground: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(.clear)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            Capsule()
                .fill(Color.white.opacity(0.06))
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.14), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 24)
                        .padding(.horizontal, 1)
                        .padding(.top, 1)
                }
        }
    }
}

#Preview {
    DawnView(onBegin: {})
}
