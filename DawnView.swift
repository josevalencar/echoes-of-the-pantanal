//
//  DawnView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 22/02/2026.
//

// Scene 2: Dawn in the Pantanal — the emotional centerpiece with layered landscape.
// All visuals built with SwiftUI Shapes/Paths/Gradients — no raster images except animal SVGs.

import SwiftUI

struct DawnView: View {
    let onBegin: () -> Void
    
    // Animation state
    @State private var showScene = false
    @State private var showTitle = false
    @State private var showSoundWaves = false
    @State private var showCTA = false
    @State private var showAnimals = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Sky gradient (full screen)
                DawnSkyGradient()
                
                // Layer 2: Sun glow (upper third)
                DawnSunGlow()
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.22)
                    .opacity(showScene ? 1 : 0)
                
                // Layer 3: Mist layers
                MistLayers()
                    .opacity(showScene ? 1 : 0)
                
                // Layer 4: SVG-style landscape (canopy, trunks, foliage, water, lily pads)
                DawnLandscape()
                    .opacity(showScene ? 1 : 0)
                
                // Layer 5: Fireflies
                DawnFireflies()
                    .opacity(showScene ? 0.9 : 0)
                
                // Layer 5.5: Flying insects/bugs
                FlyingInsects()
                    .opacity(showScene ? 1 : 0)
                
                // Layer 6: Water shimmer
                WaterShimmerLayer(height: geometry.size.height)
                    .opacity(showScene ? 1 : 0)
                
                // Layer 7: Water ripples
                DawnWaterRipples()
                    .position(x: geometry.size.width * 0.45, y: geometry.size.height * 0.78)
                    .opacity(showScene ? 1 : 0)
                
                // Layer 8: Sound wave bars (center, appears after 4s)
                if showSoundWaves {
                    DawnSoundWaves()
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.44)
                        .transition(.opacity)
                }
                
                // Layer 9: Animals from SVG assets
                AnimalsLayer(size: geometry.size, show: showAnimals)
                
                // Layer 10: Text overlay (title + CTA)
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.11)
                    
                    DawnTitleGroup()
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                    
                    Spacer()
                    
                    DawnBottomSection(onBegin: onBegin)
                        .opacity(showCTA ? 1 : 0)
                        .offset(y: showCTA ? 0 : 20)
                        .padding(.bottom, 60)
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await animateEntrance()
        }
    }
    
    private func animateEntrance() async {
        // Scene fades in
        withAnimation(.easeOut(duration: 2.0)) {
            showScene = true
        }
        
        // Title at 1.5s
        try? await Task.sleep(for: .milliseconds(1500))
        withAnimation(.easeOut(duration: 2.5)) {
            showTitle = true
        }
        
        // Animals start appearing at 3s
        try? await Task.sleep(for: .milliseconds(1500))
        withAnimation(.easeOut(duration: 2.0)) {
            showAnimals = true
        }
        
        // Sound waves at 4s
        try? await Task.sleep(for: .milliseconds(1000))
        withAnimation(.easeOut(duration: 2.0)) {
            showSoundWaves = true
        }
        
        // CTA at 3.5s from start
        try? await Task.sleep(for: .milliseconds(500))
        withAnimation(.easeOut(duration: 1.5)) {
            showCTA = true
        }
    }
}

// MARK: - Sky Gradient

struct DawnSkyGradient: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: "2a7a5e"), location: 0),
                .init(color: Color(hex: "348a68"), location: 0.10),
                .init(color: Color(hex: "3e9a74"), location: 0.25),
                .init(color: Color(hex: "48a47c"), location: 0.38),
                .init(color: Color(hex: "4eac82"), location: 0.50),
                .init(color: Color(hex: "52b488"), location: 0.62),
                .init(color: Color(hex: "48a47c"), location: 0.75),
                .init(color: Color(hex: "3e9a74"), location: 0.88),
                .init(color: Color(hex: "348a68"), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Sun Glow

struct DawnSunGlow: View {
    var body: some View {
        ZStack {
            // Large outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "f0e6a0").opacity(0.28),
                            Color(hex: "f0dc8c").opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
            
            // Bright middle glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "fff5b4").opacity(0.32),
                            Color(hex: "f0dc8c").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
            
            // Inner golden core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "ffffd8").opacity(0.35),
                            Color(hex: "fff5b4").opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
            
            // Star sparkles around the glow
            GoldenSparkles()
        }
    }
}

// MARK: - Star Sparkles

struct GoldenSparkles: View {
    var body: some View {
        ZStack {
            // Multiple star points at different angles and distances
            ForEach(0..<8, id: \.self) { index in
                StarSparkle(
                    size: [4, 3, 5, 3, 4, 3, 5, 3][index],
                    delay: Double(index) * 0.4
                )
                .offset(sparkleOffset(for: index))
            }
        }
    }
    
    private func sparkleOffset(for index: Int) -> CGSize {
        let offsets: [(CGFloat, CGFloat)] = [
            (-60, -40),   // top-left
            (70, -35),    // top-right
            (-80, 20),    // left
            (85, 15),     // right
            (-45, 55),    // bottom-left
            (55, 60),     // bottom-right
            (-25, -70),   // upper
            (30, -65)     // upper-right
        ]
        return CGSize(width: offsets[index].0, height: offsets[index].1)
    }
}

struct StarSparkle: View {
    let size: CGFloat
    let delay: Double
    
    @State private var opacity: Double = 0.3
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // 4-point star shape
            Star4Point(size: size)
                .fill(Color(hex: "ffffd8").opacity(opacity))
            
            // Glow around the star
            Circle()
                .fill(Color(hex: "f0dc8c").opacity(opacity * 0.4))
                .frame(width: size * 3, height: size * 3)
                .blur(radius: 2)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
                .delay(delay)
            ) {
                opacity = 0.9
                scale = 1.2
            }
        }
    }
}

struct Star4Point: Shape {
    let size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let innerRadius = size * 0.3
        let outerRadius = size
        
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4 - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Mist Layers

struct MistLayers: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MistCloud(
                    width: 400, height: 160,
                    color: Color(hex: "f0dc8c").opacity(0.12)
                )
                .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.28)
                .modifier(MistAnimation(duration: 18, delay: 2))
                
                MistCloud(
                    width: 350, height: 140,
                    color: Color(hex: "ffffd4").opacity(0.10)
                )
                .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.38)
                .modifier(MistAnimation(duration: 22, delay: 4, reverse: true))
                
                MistCloud(
                    width: 300, height: 120,
                    color: Color(hex: "f0f0b4").opacity(0.11)
                )
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.20)
                .modifier(MistAnimation(duration: 15, delay: 1))
            }
        }
    }
}

struct MistCloud: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [color, Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: width / 2
                )
            )
            .frame(width: width, height: height)
            .blur(radius: 50)
    }
}

struct MistAnimation: ViewModifier {
    let duration: Double
    let delay: Double
    var reverse: Bool = false
    
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0.4
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = reverse ? -30 : 30
                    opacity = 0.8
                }
            }
    }
}

// MARK: - Landscape (Canvas-based SVG-style rendering)

struct DawnLandscape: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawCanopy(context: context, size: size, isIPad: isRegularWidth)
                drawHangingVines(context: context, size: size)
                drawTreeTrunks(context: context, size: size, isIPad: isRegularWidth)
                drawMidFoliage(context: context, size: size, isIPad: isRegularWidth)
                drawFlowers(context: context, size: size)
                drawWater(context: context, size: size)
                drawLilyPads(context: context, size: size)
                drawForegroundPlants(context: context, size: size)
            }
        }
    }
    
    // MARK: Canopy (top layer - dark green ellipses framing the clearing)
    
    private func drawCanopy(context: GraphicsContext, size: CGSize, isIPad: Bool) {
        let canopyDeep = Color(hex: "2a6e52")
        let canopyMid = Color(hex: "2e7a5a")
        let canopyLight = Color(hex: "3a8a68")
        
        // Top vine curve across
        var vinePath = Path()
        vinePath.move(to: CGPoint(x: -20, y: size.height * 0.12))
        vinePath.addQuadCurve(
            to: CGPoint(x: size.width * 0.3, y: size.height * 0.11),
            control: CGPoint(x: size.width * 0.15, y: size.height * 0.08)
        )
        vinePath.addQuadCurve(
            to: CGPoint(x: size.width * 0.6, y: size.height * 0.10),
            control: CGPoint(x: size.width * 0.45, y: size.height * 0.14)
        )
        vinePath.addQuadCurve(
            to: CGPoint(x: size.width + 20, y: size.height * 0.09),
            control: CGPoint(x: size.width * 0.8, y: size.height * 0.06)
        )
        context.stroke(vinePath, with: .color(canopyDeep), style: StrokeStyle(lineWidth: 18, lineCap: .round))
        
        // Secondary vine
        var vine2 = Path()
        vine2.move(to: CGPoint(x: -10, y: size.height * 0.105))
        vine2.addQuadCurve(
            to: CGPoint(x: size.width * 0.35, y: size.height * 0.10),
            control: CGPoint(x: size.width * 0.17, y: size.height * 0.06)
        )
        vine2.addQuadCurve(
            to: CGPoint(x: size.width + 10, y: size.height * 0.08),
            control: CGPoint(x: size.width * 0.7, y: size.height * 0.13)
        )
        context.stroke(vine2, with: .color(canopyMid.opacity(0.7)), style: StrokeStyle(lineWidth: 12, lineCap: .round))
        
        // Top-left canopy mass
        context.fill(Path(ellipseIn: CGRect(x: -60, y: size.height * 0.02, width: 160, height: 140)), with: .color(canopyDeep))
        context.fill(Path(ellipseIn: CGRect(x: 20, y: size.height * 0.01, width: 120, height: 110)), with: .color(canopyMid))
        context.fill(Path(ellipseIn: CGRect(x: 60, y: size.height * 0.06, width: 100, height: 90)), with: .color(canopyLight.opacity(0.8)))
        
        // Top-right canopy mass
        context.fill(Path(ellipseIn: CGRect(x: size.width - 100, y: size.height * 0.01, width: 160, height: 150)), with: .color(canopyDeep))
        context.fill(Path(ellipseIn: CGRect(x: size.width - 80, y: -10, width: 140, height: 120)), with: .color(canopyMid))
        context.fill(Path(ellipseIn: CGRect(x: size.width - 120, y: size.height * 0.05, width: 110, height: 100)), with: .color(canopyLight.opacity(0.8)))
        
        // Center gap framing
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.18, y: -20, width: 100, height: 90)), with: .color(canopyDeep.opacity(0.7)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.62, y: -15, width: 90, height: 80)), with: .color(canopyDeep.opacity(0.7)))
    }
    
    // MARK: Hanging Vines
    
    private func drawHangingVines(context: GraphicsContext, size: CGSize) {
        let vineColor = Color(hex: "3a8a68")
        let vineColor2 = Color(hex: "2e7a5a")
        
        // Left vines
        var vine1 = Path()
        vine1.move(to: CGPoint(x: size.width * 0.2, y: size.height * 0.14))
        vine1.addQuadCurve(
            to: CGPoint(x: size.width * 0.22, y: size.height * 0.22),
            control: CGPoint(x: size.width * 0.18, y: size.height * 0.18)
        )
        vine1.addQuadCurve(
            to: CGPoint(x: size.width * 0.21, y: size.height * 0.28),
            control: CGPoint(x: size.width * 0.24, y: size.height * 0.25)
        )
        context.stroke(vine1, with: .color(vineColor.opacity(0.5)), style: StrokeStyle(lineWidth: 2))
        
        var vine2 = Path()
        vine2.move(to: CGPoint(x: size.width * 0.28, y: size.height * 0.12))
        vine2.addQuadCurve(
            to: CGPoint(x: size.width * 0.30, y: size.height * 0.20),
            control: CGPoint(x: size.width * 0.26, y: size.height * 0.16)
        )
        vine2.addQuadCurve(
            to: CGPoint(x: size.width * 0.29, y: size.height * 0.26),
            control: CGPoint(x: size.width * 0.32, y: size.height * 0.23)
        )
        context.stroke(vine2, with: .color(vineColor2.opacity(0.4)), style: StrokeStyle(lineWidth: 1.5))
        
        // Right vines
        var vine3 = Path()
        vine3.move(to: CGPoint(x: size.width * 0.72, y: size.height * 0.11))
        vine3.addQuadCurve(
            to: CGPoint(x: size.width * 0.74, y: size.height * 0.19),
            control: CGPoint(x: size.width * 0.70, y: size.height * 0.15)
        )
        vine3.addQuadCurve(
            to: CGPoint(x: size.width * 0.73, y: size.height * 0.25),
            control: CGPoint(x: size.width * 0.76, y: size.height * 0.22)
        )
        context.stroke(vine3, with: .color(vineColor.opacity(0.5)), style: StrokeStyle(lineWidth: 2))
        
        var vine4 = Path()
        vine4.move(to: CGPoint(x: size.width * 0.65, y: size.height * 0.105))
        vine4.addQuadCurve(
            to: CGPoint(x: size.width * 0.66, y: size.height * 0.17),
            control: CGPoint(x: size.width * 0.63, y: size.height * 0.14)
        )
        vine4.addQuadCurve(
            to: CGPoint(x: size.width * 0.65, y: size.height * 0.22),
            control: CGPoint(x: size.width * 0.68, y: size.height * 0.195)
        )
        context.stroke(vine4, with: .color(vineColor2.opacity(0.4)), style: StrokeStyle(lineWidth: 1.5))
    }
    
    // MARK: Tree Trunks
    
    private func drawTreeTrunks(context: GraphicsContext, size: CGSize, isIPad: Bool) {
        let barkDark = Color(hex: "3a7a6a")
        let barkMid = Color(hex: "4a9488")
        let barkLight = Color(hex: "5aa498")
        
        // Left main trunk
        context.fill(
            Path(roundedRect: CGRect(x: 50, y: size.height * 0.20, width: 16, height: size.height * 0.55), cornerRadius: 4),
            with: .color(barkDark.opacity(0.5))
        )
        
        // Right main trunk
        context.fill(
            Path(roundedRect: CGRect(x: size.width - 66, y: size.height * 0.22, width: 14, height: size.height * 0.52), cornerRadius: 4),
            with: .color(barkDark.opacity(0.5))
        )
        
        // Center-left far trunk
        context.fill(
            Path(roundedRect: CGRect(x: size.width * 0.35, y: size.height * 0.24, width: 12, height: size.height * 0.48), cornerRadius: 3),
            with: .color(barkMid.opacity(0.35))
        )
        
        // Center-right far trunk
        context.fill(
            Path(roundedRect: CGRect(x: size.width * 0.60, y: size.height * 0.26, width: 10, height: size.height * 0.46), cornerRadius: 3),
            with: .color(barkMid.opacity(0.30))
        )
        
        // Additional trees for iPad
        if isIPad {
            // Far left additional trunk
            context.fill(
                Path(roundedRect: CGRect(x: 20, y: size.height * 0.18, width: 12, height: size.height * 0.50), cornerRadius: 3),
                with: .color(barkMid.opacity(0.40))
            )
            
            // Far right additional trunk
            context.fill(
                Path(roundedRect: CGRect(x: size.width - 35, y: size.height * 0.20, width: 10, height: size.height * 0.48), cornerRadius: 3),
                with: .color(barkMid.opacity(0.40))
            )
            
            // Background trunks for depth
            context.fill(
                Path(roundedRect: CGRect(x: size.width * 0.25, y: size.height * 0.28, width: 8, height: size.height * 0.42), cornerRadius: 2),
                with: .color(barkLight.opacity(0.25))
            )
            context.fill(
                Path(roundedRect: CGRect(x: size.width * 0.72, y: size.height * 0.30, width: 8, height: size.height * 0.40), cornerRadius: 2),
                with: .color(barkLight.opacity(0.25))
            )
        }
    }
    
    // MARK: Mid-layer Foliage (bush clusters)
    
    private func drawMidFoliage(context: GraphicsContext, size: CGSize, isIPad: Bool) {
        let foliageDark = Color(hex: "2e7a5a")
        let foliageMid = Color(hex: "48946e")
        let foliageLight = Color(hex: "58a47e")
        
        // Left bushes
        context.fill(Path(ellipseIn: CGRect(x: -10, y: size.height * 0.34, width: 80, height: 110)), with: .color(foliageDark.opacity(0.75)))
        context.fill(Path(ellipseIn: CGRect(x: 45, y: size.height * 0.40, width: 65, height: 90)), with: .color(foliageMid.opacity(0.55)))
        context.fill(Path(ellipseIn: CGRect(x: 15, y: size.height * 0.48, width: 55, height: 75)), with: .color(foliageDark.opacity(0.65)))
        
        // Right bushes
        context.fill(Path(ellipseIn: CGRect(x: size.width - 75, y: size.height * 0.36, width: 85, height: 115)), with: .color(foliageDark.opacity(0.75)))
        context.fill(Path(ellipseIn: CGRect(x: size.width - 110, y: size.height * 0.44, width: 60, height: 85)), with: .color(foliageMid.opacity(0.55)))
        context.fill(Path(ellipseIn: CGRect(x: size.width - 65, y: size.height * 0.52, width: 70, height: 80)), with: .color(foliageDark.opacity(0.65)))
        
        // Additional foliage for iPad (more lush)
        if isIPad {
            // Background foliage depth layers
            context.fill(Path(ellipseIn: CGRect(x: size.width * 0.22, y: size.height * 0.38, width: 50, height: 70)), with: .color(foliageLight.opacity(0.35)))
            context.fill(Path(ellipseIn: CGRect(x: size.width * 0.68, y: size.height * 0.40, width: 55, height: 75)), with: .color(foliageLight.opacity(0.35)))
            
            // Extra side bushes
            context.fill(Path(ellipseIn: CGRect(x: 85, y: size.height * 0.46, width: 45, height: 60)), with: .color(foliageMid.opacity(0.45)))
            context.fill(Path(ellipseIn: CGRect(x: size.width - 140, y: size.height * 0.48, width: 45, height: 60)), with: .color(foliageMid.opacity(0.45)))
        }
    }
    
    // MARK: Flowers (with stems and proper bodies)
    
    private func drawFlowers(context: GraphicsContext, size: CGSize) {
        let flowerCoral = Color(hex: "e86a5a")
        let flowerDeep = Color(hex: "c44a3a")
        let stemColor = Color(hex: "2e7a5a")
        
        // Helper to draw a flower with stem
        func drawFlower(x: CGFloat, y: CGFloat, petalSize: CGFloat, opacity: Double) {
            let stemHeight = petalSize * 2.5
            
            // Stem (curved line)
            var stemPath = Path()
            stemPath.move(to: CGPoint(x: x, y: y + petalSize/2))
            stemPath.addQuadCurve(
                to: CGPoint(x: x - 3, y: y + stemHeight),
                control: CGPoint(x: x + 4, y: y + stemHeight * 0.5)
            )
            context.stroke(stemPath, with: .color(stemColor.opacity(0.6)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            
            // Flower center
            context.fill(Path(ellipseIn: CGRect(x: x - petalSize/2, y: y - petalSize/2, width: petalSize, height: petalSize)), with: .color(flowerCoral.opacity(opacity)))
            
            // Inner dot (pistil)
            let innerSize = petalSize * 0.4
            context.fill(Path(ellipseIn: CGRect(x: x - innerSize/2, y: y - innerSize/2, width: innerSize, height: innerSize)), with: .color(flowerDeep.opacity(opacity + 0.1)))
        }
        
        // Left side flowers (bigger with stems)
        drawFlower(x: 42, y: size.height * 0.42, petalSize: 12, opacity: 0.85)
        drawFlower(x: 22, y: size.height * 0.50, petalSize: 10, opacity: 0.80)
        drawFlower(x: 60, y: size.height * 0.47, petalSize: 9, opacity: 0.75)
        
        // Right side flowers
        drawFlower(x: size.width - 48, y: size.height * 0.44, petalSize: 12, opacity: 0.85)
        drawFlower(x: size.width - 72, y: size.height * 0.52, petalSize: 10, opacity: 0.80)
        drawFlower(x: size.width - 38, y: size.height * 0.49, petalSize: 9, opacity: 0.75)
    }
    
    // MARK: Water Layer
    
    private func drawWater(context: GraphicsContext, size: CGSize) {
        let waterRect = CGRect(x: 0, y: size.height * 0.65, width: size.width, height: size.height * 0.35)
        
        let waterGradient = Gradient(stops: [
            .init(color: Color(hex: "48b89a").opacity(0), location: 0),
            .init(color: Color(hex: "48b89a").opacity(0.45), location: 0.20),
            .init(color: Color(hex: "5ac8a6").opacity(0.55), location: 0.50),
            .init(color: Color(hex: "3a8c6e").opacity(0.70), location: 1.0)
        ])
        
        context.fill(
            Path(CGRect(x: 0, y: size.height * 0.65, width: size.width, height: size.height * 0.35)),
            with: .linearGradient(waterGradient, startPoint: CGPoint(x: size.width/2, y: size.height * 0.65), endPoint: CGPoint(x: size.width/2, y: size.height))
        )
    }
    
    // MARK: Lily Pads
    
    private func drawLilyPads(context: GraphicsContext, size: CGSize) {
        let lilyColor = Color(hex: "58b08a")
        let lilyDark = Color(hex: "2d6b5a")
        
        // Large lily pads
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.15, y: size.height * 0.72, width: 55, height: 20)), with: .color(lilyDark.opacity(0.6)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.55, y: size.height * 0.75, width: 60, height: 22)), with: .color(lilyColor.opacity(0.55)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.35, y: size.height * 0.80, width: 50, height: 18)), with: .color(lilyDark.opacity(0.5)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.70, y: size.height * 0.78, width: 45, height: 16)), with: .color(lilyColor.opacity(0.5)))
        
        // Smaller lily pads
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.25, y: size.height * 0.85, width: 35, height: 12)), with: .color(lilyDark.opacity(0.45)))
        context.fill(Path(ellipseIn: CGRect(x: size.width * 0.80, y: size.height * 0.83, width: 40, height: 14)), with: .color(lilyColor.opacity(0.45)))
    }
    
    // MARK: Foreground Plants
    
    private func drawForegroundPlants(context: GraphicsContext, size: CGSize) {
        let foliageDark = Color(hex: "2e7a5a")
        let flowerCoral = Color(hex: "e86a5a")
        
        // Bottom-left large leaves
        context.fill(Path(ellipseIn: CGRect(x: -25, y: size.height * 0.82, width: 90, height: 130)), with: .color(foliageDark.opacity(0.85)))
        context.fill(Path(ellipseIn: CGRect(x: 35, y: size.height * 0.88, width: 70, height: 100)), with: .color(foliageDark.opacity(0.7)))
        
        // Bottom-left flower
        context.fill(Path(ellipseIn: CGRect(x: 45, y: size.height * 0.87, width: 10, height: 10)), with: .color(flowerCoral.opacity(0.9)))
        
        // Bottom-right large leaves
        context.fill(Path(ellipseIn: CGRect(x: size.width - 70, y: size.height * 0.84, width: 95, height: 125)), with: .color(foliageDark.opacity(0.85)))
        context.fill(Path(ellipseIn: CGRect(x: size.width - 110, y: size.height * 0.90, width: 65, height: 95)), with: .color(foliageDark.opacity(0.7)))
        
        // Bottom-right flower
        context.fill(Path(ellipseIn: CGRect(x: size.width - 95, y: size.height * 0.89, width: 10, height: 10)), with: .color(flowerCoral.opacity(0.9)))
    }
}

// MARK: - Fireflies

struct DawnFireflies: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DawnFirefly(size: 5)
                    .position(x: geometry.size.width * 0.28, y: geometry.size.height * 0.22)
                    .modifier(FireflyFloatAnimation(delay: 0.5))
                
                DawnFirefly(size: 4)
                    .position(x: geometry.size.width * 0.65, y: geometry.size.height * 0.30)
                    .modifier(FireflyFloatAnimation(delay: 2.2))
                
                DawnFirefly(size: 6)
                    .position(x: geometry.size.width * 0.18, y: geometry.size.height * 0.42)
                    .modifier(FireflyFloatAnimation(delay: 1.4))
                
                DawnFirefly(size: 3)
                    .position(x: geometry.size.width * 0.78, y: geometry.size.height * 0.35)
                    .modifier(FireflyFloatAnimation(delay: 3.8))
                
                DawnFirefly(size: 5)
                    .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.26)
                    .modifier(FireflyFloatAnimation(delay: 1.0))
                
                DawnFirefly(size: 4)
                    .position(x: geometry.size.width * 0.72, y: geometry.size.height * 0.48)
                    .modifier(FireflyFloatAnimation(delay: 4.5))
                
                DawnFirefly(size: 3)
                    .position(x: geometry.size.width * 0.40, y: geometry.size.height * 0.38)
                    .modifier(FireflyFloatAnimation(delay: 2.8))
                
                DawnFirefly(size: 4)
                    .position(x: geometry.size.width * 0.30, y: geometry.size.height * 0.20)
                    .modifier(FireflyFloatAnimation(delay: 5.2))
            }
        }
    }
}

struct DawnFirefly: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color(hex: "ffffd8").opacity(0.85))
            .frame(width: size, height: size)
            .shadow(color: Color(hex: "ffffd8").opacity(0.5), radius: 6)
    }
}

struct FireflyFloatAnimation: ViewModifier {
    let delay: Double
    
    @State private var phase: CGFloat = 0
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .opacity(phase)
            .offset(offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 6)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    phase = 0.9
                    offset = CGSize(width: 12, height: -18)
                }
            }
    }
}

// MARK: - Flying Insects

struct FlyingInsects: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Flying insects scattered around the scene
                FlyingInsect(size: 2.5)
                    .position(x: geometry.size.width * 0.35, y: geometry.size.height * 0.32)
                    .modifier(InsectFlightAnimation(delay: 0, pathType: .erratic))
                
                FlyingInsect(size: 2)
                    .position(x: geometry.size.width * 0.55, y: geometry.size.height * 0.28)
                    .modifier(InsectFlightAnimation(delay: 1.2, pathType: .circular))
                
                FlyingInsect(size: 2.5)
                    .position(x: geometry.size.width * 0.68, y: geometry.size.height * 0.40)
                    .modifier(InsectFlightAnimation(delay: 2.4, pathType: .erratic))
                
                FlyingInsect(size: 2)
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.38)
                    .modifier(InsectFlightAnimation(delay: 0.8, pathType: .circular))
                
                FlyingInsect(size: 3)
                    .position(x: geometry.size.width * 0.45, y: geometry.size.height * 0.35)
                    .modifier(InsectFlightAnimation(delay: 3.0, pathType: .figure8))
                
                FlyingInsect(size: 2)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.25)
                    .modifier(InsectFlightAnimation(delay: 1.8, pathType: .erratic))
                
                FlyingInsect(size: 2.5)
                    .position(x: geometry.size.width * 0.58, y: geometry.size.height * 0.42)
                    .modifier(InsectFlightAnimation(delay: 4.2, pathType: .circular))
                
                FlyingInsect(size: 2)
                    .position(x: geometry.size.width * 0.32, y: geometry.size.height * 0.45)
                    .modifier(InsectFlightAnimation(delay: 2.0, pathType: .figure8))
            }
        }
    }
}

struct FlyingInsect: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color(hex: "1a3a2a").opacity(0.7))
            .frame(width: size, height: size)
    }
}

enum InsectPathType {
    case erratic
    case circular
    case figure8
}

struct InsectFlightAnimation: ViewModifier {
    let delay: Double
    let pathType: InsectPathType
    
    @State private var offset: CGSize = .zero
    @State private var phase: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .opacity(0.6 + phase * 0.4)
            .onAppear {
                startAnimation()
            }
    }
    
    private func startAnimation() {
        let duration: Double
        let targetOffset: CGSize
        
        switch pathType {
        case .erratic:
            duration = 3.5
            targetOffset = CGSize(width: 25, height: -20)
        case .circular:
            duration = 4.0
            targetOffset = CGSize(width: 18, height: 15)
        case .figure8:
            duration = 5.0
            targetOffset = CGSize(width: -22, height: 12)
        }
        
        withAnimation(
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
            .delay(delay)
        ) {
            offset = targetOffset
            phase = 1
        }
    }
}

// MARK: - Water Shimmer

struct WaterShimmerLayer: View {
    let height: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                ShimmerLine(width: 0.6, bottomPercent: 0.45, leftPercent: 0.10, delay: 0)
                ShimmerLine(width: 0.4, bottomPercent: 0.55, leftPercent: 0.30, delay: 1.2)
                ShimmerLine(width: 0.5, bottomPercent: 0.35, leftPercent: 0.20, delay: 2.4)
                ShimmerLine(width: 0.35, bottomPercent: 0.65, leftPercent: 0.40, delay: 0.8)
                ShimmerLine(width: 0.45, bottomPercent: 0.25, leftPercent: 0.15, delay: 3.2)
            }
            .frame(height: height * 0.38)
        }
    }
}

struct ShimmerLine: View {
    let width: CGFloat
    let bottomPercent: CGFloat
    let leftPercent: CGFloat
    let delay: Double
    
    @State private var shimmerPhase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color(hex: "ffffdc").opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: geometry.size.width * width, height: 1)
                .position(
                    x: geometry.size.width * leftPercent + (geometry.size.width * width / 2),
                    y: geometry.size.height * (1 - bottomPercent)
                )
                .opacity(shimmerPhase)
                .offset(x: shimmerPhase * 20 - 10)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 4)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                    ) {
                        shimmerPhase = 1
                    }
                }
        }
    }
}

// MARK: - Water Ripples

struct DawnWaterRipples: View {
    var body: some View {
        ZStack {
            DawnRipple(width: 40, height: 14, delay: 1.0)
            DawnRipple(width: 30, height: 10, delay: 3.0)
                .offset(x: 40, y: 15)
            DawnRipple(width: 50, height: 16, delay: 5.0)
                .offset(x: -30, y: 25)
        }
    }
}

struct DawnRipple: View {
    let width: CGFloat
    let height: CGFloat
    let delay: Double
    
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.6
    
    var body: some View {
        Ellipse()
            .strokeBorder(Color(hex: "ffffdc").opacity(0.25), lineWidth: 1)
            .frame(width: width, height: height)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 5)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    scale = 2.2
                    opacity = 0
                }
            }
    }
}

// MARK: - Sound Wave Bars

struct DawnSoundWaves: View {
    let barHeights: [CGFloat] = [8, 16, 24, 18, 30, 22, 14, 26, 10]
    let delays: [Double] = [0, 0.08, 0.16, 0.12, 0.22, 0.10, 0.20, 0.15, 0.25]
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<9, id: \.self) { index in
                DawnSoundBar(height: barHeights[index], delay: delays[index])
            }
        }
    }
}

struct DawnSoundBar: View {
    let height: CGFloat
    let delay: Double
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [Color.pantanalGold, Color.pantanalGold.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 3, height: height)
            .scaleEffect(y: scale, anchor: .center)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    scale = 0.3
                }
            }
    }
}

// MARK: - Animals Layer

struct AnimalsLayer: View {
    let size: CGSize
    let show: Bool
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    
    // Adaptive animal sizes for iPad
    private var harpyWidth: CGFloat { isRegularWidth ? 85 : 62 }
    private var macawWidth: CGFloat { isRegularWidth ? 80 : 58 }
    private var jabiruWidth: CGFloat { isRegularWidth ? 75 : 55 }
    private var jaguarWidth: CGFloat { isRegularWidth ? 100 : 75 }
    
    var body: some View {
        ZStack {
            // Harpy Eagle - top right in canopy (moved more center)
            AnimalImage(name: "harpy", width: harpyWidth)
                .position(x: size.width * 0.80, y: size.height * 0.08)
                .opacity(show ? 1 : 0)
                .modifier(AnimalRevealAnimation(delay: 0, fromDirection: .top))
                .modifier(IdleSwayAnimation(delay: 2.5, intensity: 1.5))
            
            // Scarlet Macaw - left side
            AnimalImage(name: "macaw", width: macawWidth)
                .position(x: size.width * 0.10, y: size.height * 0.30)
                .opacity(show ? 1 : 0)
                .modifier(AnimalRevealAnimation(delay: 0.4, fromDirection: .left))
                .modifier(IdleSwayAnimation(delay: 2.9, intensity: 1.5))
            
            // Jabiru - lower left by water
            AnimalImage(name: "jaburu", width: jabiruWidth)
                .position(x: size.width * 0.20, y: size.height * 0.72)
                .opacity(show ? 1 : 0)
                .modifier(AnimalRevealAnimation(delay: 0.8, fromDirection: .bottom))
                .modifier(IdleSwayAnimation(delay: 3.3, intensity: 1.0))
            
            // Jaguar - bottom right, partially camouflaged
            AnimalImage(name: "jaguar", width: jaguarWidth)
                .position(x: size.width * 0.86, y: size.height * 0.86)
                .opacity(show ? 0.92 : 0)
                .modifier(AnimalRevealAnimation(delay: 1.5, fromDirection: .right))
                .modifier(IdleLateralAnimation(delay: 4.5))
        }
    }
}

struct AnimalImage: View {
    let name: String
    let width: CGFloat
    
    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
            .shadow(color: .black.opacity(0.45), radius: 8, y: 3)
    }
}

enum RevealDirection {
    case top, bottom, left, right
}

struct AnimalRevealAnimation: ViewModifier {
    let delay: Double
    let fromDirection: RevealDirection
    
    @State private var revealed = false
    
    private var initialOffset: CGSize {
        switch fromDirection {
        case .top: return CGSize(width: 0, height: -8)
        case .bottom: return CGSize(width: 0, height: 8)
        case .left: return CGSize(width: -8, height: 0)
        case .right: return CGSize(width: 8, height: 0)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(revealed ? .zero : initialOffset)
            .scaleEffect(revealed ? 1 : 0.95)
            .onAppear {
                withAnimation(.easeOut(duration: 2.5).delay(delay)) {
                    revealed = true
                }
            }
    }
}

struct IdleSwayAnimation: ViewModifier {
    let delay: Double
    let intensity: CGFloat
    
    @State private var sway: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: sway)
            .rotationEffect(.degrees(sway * 0.4))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    sway = intensity
                }
            }
    }
}

struct IdleLateralAnimation: ViewModifier {
    let delay: Double
    
    @State private var shift: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: shift)
            .rotationEffect(.degrees(shift * 0.3))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 6)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    shift = 1
                }
            }
    }
}

// MARK: - Title Group

struct DawnTitleGroup: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("Echoes of the\nPantanal")
                .font(.pantanalTitle(38))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .shadow(color: .black.opacity(0.6), radius: 30, y: 2)
                .shadow(color: Color(hex: "0e2a28").opacity(0.9), radius: 80)
            
            Text("LISTEN TO NATURE")
                .font(.pantanalLabel(11))
                .foregroundStyle(Color.pantanalGold.opacity(0.7))
                .tracking(5)
        }
    }
}

// MARK: - Bottom Section (CTA)

struct DawnBottomSection: View {
    let onBegin: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onBegin) {
                HStack(spacing: 10) {
                    Image(systemName: "headphones")
                        .font(.system(size: 16, weight: .regular))
                        .opacity(0.7)
                    Text("Begin")
                        .font(.pantanalUI(15))
                        .fontWeight(.medium)
                        .tracking(0.5)
                }
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
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
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                )
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .blur(radius: 20)
                )
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 20)
                        .padding(.horizontal, 1)
                        .padding(.top, 1)
                }
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    DawnView(onBegin: {})
}
