//
//  BioacousticsEduView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 23/02/26.
//

// Scene 3: Bioacoustics onboarding with 4-step guided tooltips.
// Shows the skeuomorphic field recorder with progressive education.

import SwiftUI

struct BioacousticsEduView: View {
    let onContinue: () -> Void
    
    @State private var currentStep = 0
    @State private var isVisible = false
    @State private var tooltipVisible = false
    @State private var step3TooltipHidden = false
    
    // Audio state - uses SoundPlayer.state like RoundView
    @State private var spectrogramHistory: [[Float]] = []
    @State private var frequencyMagnitudes: [Float] = []
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let soundPlayer = SoundPlayer.shared
    private let audioManager = AudioManager.shared
    
    private let totalSteps = 4
    
    /// Adaptive layout values based on device size class
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var maxContentWidth: CGFloat { isRegularWidth ? 600 : .infinity }
    private var horizontalPadding: CGFloat { isRegularWidth ? 40 : 24 }
    private var spectrogramHeight: CGFloat { isRegularWidth ? 140 : 120 }
    
    /// Whether we're in microphone mode (step 3)
    private var useMicrophone: Bool { currentStep == 3 }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                Spacer()
                
                // Recorder container with tooltips - centered
                recorderSection
                
                Spacer()
                
                // Bottom navigation
                bottomNavigation
                    .padding(.bottom, 32)
            }
            .opacity(isVisible ? 1 : 0)
        }
        .onAppear {
            // Reset player state (stops any sound and shows play button)
            soundPlayer.reset()
            
            withAnimation(.easeOut(duration: 0.6)) {
                isVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.4)) {
                    tooltipVisible = true
                }
            }
        }
        .onDisappear {
            soundPlayer.stop()
            audioManager.stopRecording()
        }
        .onReceive(soundPlayer.$frequencyMagnitudes) { newValue in
            frequencyMagnitudes = newValue
            // Only update history when actually playing (like RoundView)
            if soundPlayer.isPlaying {
                updateSpectrogramHistory(newValue)
            }
        }
        .onReceive(audioManager.$frequencyMagnitudes) { newValue in
            if useMicrophone {
                frequencyMagnitudes = newValue
                updateSpectrogramHistory(newValue)
            }
        }
    }
    
    // MARK: - Background
    
    /// Average audio level for reactive effects (0.0 to 1.0)
    private var audioLevel: Double {
        guard !frequencyMagnitudes.isEmpty else { return 0 }
        let sum = frequencyMagnitudes.reduce(0, +)
        let avg = Double(sum) / Double(frequencyMagnitudes.count)
        return min(1.0, avg * 3.0) // Boost for visibility
    }
    
    /// Low frequency level (bass) for warm colors
    private var bassLevel: Double {
        guard frequencyMagnitudes.count > 4 else { return 0 }
        let bassRange = frequencyMagnitudes.prefix(4)
        let sum = bassRange.reduce(0, +)
        return min(1.0, Double(sum) / 4.0 * 4.0)
    }
    
    /// High frequency level (treble) for bright accents
    private var trebleLevel: Double {
        guard frequencyMagnitudes.count > 8 else { return 0 }
        let trebleRange = frequencyMagnitudes.suffix(from: frequencyMagnitudes.count / 2)
        let sum = trebleRange.reduce(0, +)
        return min(1.0, Double(sum) / Double(trebleRange.count) * 4.0)
    }
    
    private var backgroundGradient: some View {
        ZStack {
            // Base green gradient
            LinearGradient(
                colors: [
                    Color.pantanalDeep,
                    Color(red: 15/255, green: 42/255, blue: 28/255),
                    Color.pantanalDark
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Reactive warm glow overlay - responds to audio
            reactiveGlowOverlay
        }
        .ignoresSafeArea()
    }
    
    private var reactiveGlowOverlay: some View {
        ZStack {
            // Center radial glow - gold/amber, pulses with overall level
            RadialGradient(
                colors: [
                    Color.pantanalGold.opacity(audioLevel * 0.125),
                    Color.pantanalAmber.opacity(audioLevel * 0.075),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            
            // Top accent - treble reactive (higher frequencies = brighter)
            RadialGradient(
                colors: [
                    Color.specYellow.opacity(trebleLevel * 0.1),
                    Color.clear
                ],
                center: UnitPoint(x: 0.7, y: 0.2),
                startRadius: 0,
                endRadius: 250
            )
            
            // Bottom accent - bass reactive (low frequencies = warmer)
            RadialGradient(
                colors: [
                    Color.specOrange.opacity(bassLevel * 0.09),
                    Color.specRed.opacity(bassLevel * 0.04),
                    Color.clear
                ],
                center: UnitPoint(x: 0.3, y: 0.8),
                startRadius: 0,
                endRadius: 300
            )
        }
        .animation(.easeOut(duration: 0.15), value: audioLevel)
    }
    
    // MARK: - Recorder Section
    
    private var recorderSection: some View {
        ZStack {
            // Use RoundRecorderDevice exactly like the challenges
            if useMicrophone {
                // Step 3: Microphone mode - custom card for mic input
                microphoneRecorderCard
                    .frame(maxWidth: maxContentWidth)
                    .padding(.horizontal, horizontalPadding)
            } else {
                // Steps 0-2: Sound playback using RoundRecorderDevice
                RoundRecorderDevice(
                    soundFile: "bemtevi",
                    spectrogramHistory: spectrogramHistory,
                    frequencyMagnitudes: frequencyMagnitudes,
                    playbackState: soundPlayer.state,
                    onButtonTap: handlePlaybackButtonTap,
                    spectrogramHeight: spectrogramHeight,
                    isRegularWidth: isRegularWidth,
                    highlightButton: currentStep == 0 && !soundPlayer.isPlaying
                )
                .frame(maxWidth: maxContentWidth)
                .padding(.horizontal, horizontalPadding)
            }
            
            // Tooltip cards
            tooltipCard
        }
    }
    
    /// Handle playback button tap - same logic as RoundView
    private func handlePlaybackButtonTap() {
        // If paused (initial state) or ended, we need to play/replay
        if soundPlayer.isPaused || soundPlayer.hasEnded {
            // Clear spectrogram history before playing
            spectrogramHistory = []
            // Play the bem-te-vi sound
            soundPlayer.play(soundFile: "bemtevi", animalId: "great_kiskadee")
        } else if soundPlayer.isPlaying {
            // Pause if currently playing
            soundPlayer.pause()
        }
    }
    
    /// Microphone recorder card for step 3
    private var microphoneRecorderCard: some View {
        let cardPadding: CGFloat = isRegularWidth ? 16 : 12
        let statusFontSize: CGFloat = isRegularWidth ? 10 : 8
        let vuBarSize: CGFloat = isRegularWidth ? 12 : 10
        let cornerRadius: CGFloat = isRegularWidth ? 16 : 12
        
        return VStack(spacing: 0) {
            // Mini header with status
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.pantanalGold)
                        .frame(width: isRegularWidth ? 8 : 6, height: isRegularWidth ? 8 : 6)
                        .shadow(color: Color.pantanalGold.opacity(0.5), radius: 4)
                    
                    Text("LISTENING")
                        .font(.pantanalMono(statusFontSize))
                        .foregroundStyle(Color.textMuted)
                }
                
                Spacer()
                
                Text("You")
                    .font(.pantanalMono(statusFontSize))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, cardPadding + 4)
            .padding(.vertical, isRegularWidth ? 14 : 12)
            
            // Spectrogram display
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 10/255, green: 13/255, blue: 11/255))
                
                LiveSpectrogramCanvas(history: spectrogramHistory)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(3)
            }
            .frame(height: spectrogramHeight)
            .padding(.horizontal, cardPadding)
            .padding(.bottom, isRegularWidth ? 12 : 8)
            
            // VU meter row
            HStack(spacing: isRegularWidth ? 3 : 2) {
                ForEach(0..<12, id: \.self) { index in
                    let level = micAverageLevel * 3.0
                    let isActive = index < Int(level * 12)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(vuBarColor(for: index, isActive: isActive))
                        .frame(width: vuBarSize, height: vuBarSize)
                }
                
                Spacer()
                
                // Mic icon (no button needed - always listening)
                Image(systemName: "mic.fill")
                    .font(.system(size: isRegularWidth ? 18 : 16))
                    .foregroundStyle(Color.pantanalGold)
                    .frame(width: isRegularWidth ? 52 : 44, height: isRegularWidth ? 52 : 44)
                    .background(
                        Circle()
                            .fill(Color.pantanalGold.opacity(0.15))
                    )
            }
            .padding(.horizontal, cardPadding)
            .padding(.bottom, isRegularWidth ? 16 : 12)
        }
        .background(Color(red: 26/255, green: 29/255, blue: 27/255))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    /// Average mic level for VU meter
    private var micAverageLevel: Float {
        guard !frequencyMagnitudes.isEmpty else { return 0 }
        return frequencyMagnitudes.reduce(0, +) / Float(frequencyMagnitudes.count)
    }
    
    private func vuBarColor(for index: Int, isActive: Bool) -> Color {
        guard isActive else { return Color.white.opacity(0.05) }
        
        switch index {
        case 0...4: return Color.pantanalLight.opacity(0.7)
        case 5...7: return Color.pantanalGold.opacity(0.6)
        case 8...9: return Color.pantanalAmber.opacity(0.5)
        default: return Color.specRed.opacity(0.5)
        }
    }
    
    // MARK: - Tooltip Cards
    
    @ViewBuilder
    private var tooltipCard: some View {
        if tooltipVisible {
            switch currentStep {
            case 0:
                TooltipCard(
                    step: 1,
                    totalSteps: 4,
                    heading: "This is a spectrogram",
                    bodyText: "Press play to hear a Great Kiskadee. Watch the screen as the sound becomes visible. Bird frequencies like these lower cortisol and sharpen focus.",
                    arrowDirection: .up,
                    arrowPosition: 0.7
                )
                .offset(y: 180)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                
            case 1:
                TooltipCard(
                    step: 2,
                    totalSteps: 4,
                    heading: "Warm means loud",
                    bodyText: "Bright colors are loud. Dark is silence. Each row is a different frequency.",
                    arrowDirection: .down,
                    arrowPosition: 0.3,
                    showColorSwatches: true
                )
                .offset(y: -180)
                .transition(.opacity.combined(with: .move(edge: .top)))
                
            case 2:
                TooltipCard(
                    step: 3,
                    totalSteps: 4,
                    heading: "Every species has a signature",
                    bodyText: "This sharp, high-pitched pattern belongs to the Kiskadee. A jaguar would sit low and wide. No two species look the same.",
                    arrowDirection: .up,
                    arrowPosition: 0.5
                )
                .offset(y: 180)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                
            case 3:
                if !step3TooltipHidden {
                    TooltipCard(
                        step: 4,
                        totalSteps: 4,
                        heading: "Now you try",
                        bodyText: "Talk, clap, or whistle.",
                        arrowDirection: .up,
                        arrowPosition: 0.5,
                        isCompact: true
                    )
                    .offset(y: 140)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .onAppear {
                        // Auto-fade after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                step3TooltipHidden = true
                            }
                        }
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        HStack {
            // Step dots
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    StepDot(
                        index: index,
                        currentStep: currentStep,
                        onTap: { goToStep(index) }
                    )
                }
            }
            
            Spacer()
            
            // Next button
            Button(action: handleNextTap) {
                Text(currentStep == 3 ? "Explore the Sounds" : "Next")
                    .font(.pantanalUI(13))
                    .fontWeight(.medium)
                    .tracking(0.3)
                    .foregroundStyle(currentStep == 3 ? Color.pantanalGold : Color.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(nextButtonBackground)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 28)
    }
    
    @ViewBuilder
    private var nextButtonBackground: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(.clear)
                .glassEffect(
                    .regular.tint(currentStep == 3 ? Color.pantanalGold.opacity(0.15) : Color.white.opacity(0.08)).interactive(),
                    in: .capsule
                )
        } else {
            Capsule()
                .fill(currentStep == 3 ? Color.pantanalGold.opacity(0.1) : Color.white.opacity(0.06))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            currentStep == 3 ? Color.pantanalGold.opacity(0.2) : Color.white.opacity(0.12),
                            lineWidth: 1
                        )
                )
        }
    }
    
    // MARK: - Actions
    
    private func handleNextTap() {
        if currentStep < totalSteps - 1 {
            goToStep(currentStep + 1)
        } else {
            onContinue()
        }
    }
    
    private func goToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps && step != currentStep else { return }
        
        withAnimation(.easeInOut(duration: 0.4)) {
            tooltipVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            currentStep = step
            
            // Handle audio state based on step
            // Note: useMicrophone is computed from currentStep, so just handle audio controls
            switch step {
            case 0:
                // First step: stop everything, reset spectrogram
                soundPlayer.stop()
                audioManager.stopRecording()
                spectrogramHistory = []
                
            case 1, 2:
                // Sound playback steps: stop mic, ensure sound is playing
                audioManager.stopRecording()
                if !soundPlayer.isPlaying {
                    soundPlayer.play(soundFile: "bemtevi", animalId: "great_kiskadee")
                }
                
            case 3:
                // Microphone step: stop playback, start mic recording
                soundPlayer.stop()
                spectrogramHistory = []
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    audioManager.startRecording()
                }
                
            default:
                break
            }
            
            withAnimation(.easeOut(duration: 0.4)) {
                tooltipVisible = true
            }
        }
    }
    
    private func updateSpectrogramHistory(_ magnitudes: [Float]) {
        spectrogramHistory.append(magnitudes)
        if spectrogramHistory.count > 60 {
            spectrogramHistory.removeFirst()
        }
    }
}

// MARK: - Step Dot

struct StepDot: View {
    let index: Int
    let currentStep: Int
    let onTap: () -> Void
    
    private var isActive: Bool { index == currentStep }
    private var isDone: Bool { index < currentStep }
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: isActive ? 4 : 4)
                .fill(dotColor)
                .frame(width: isActive ? 22 : 8, height: 8)
                .shadow(color: isActive ? Color.pantanalGold.opacity(0.2) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.3), value: currentStep)
    }
    
    private var dotColor: Color {
        if isActive {
            return Color.pantanalGold
        } else if isDone {
            return Color.pantanalLight.opacity(0.4)
        } else {
            return Color.white.opacity(0.08)
        }
    }
}

// MARK: - Tooltip Card

struct TooltipCard: View {
    let step: Int
    let totalSteps: Int
    let heading: String
    let bodyText: String
    var arrowDirection: ArrowDirection = .up
    var arrowPosition: CGFloat = 0.5 // 0.0 = left, 1.0 = right
    var showColorSwatches: Bool = false
    var isCompact: Bool = false
    
    enum ArrowDirection {
        case up, down, left
    }
    
    var body: some View {
        ZStack {
            // Arrow nub
            TooltipArrow(direction: arrowDirection)
                .fill(Color.pantanalDark)
                .frame(width: 12, height: 12)
                .overlay(
                    TooltipArrow(direction: arrowDirection)
                        .stroke(Color.pantanalGold.opacity(0.25), lineWidth: 1)
                )
                .offset(arrowOffset)
            
            // Card content
            VStack(alignment: .leading, spacing: isCompact ? 4 : 6) {
                if !isCompact {
                    // Step indicator
                    HStack(spacing: 6) {
                        Text("STEP \(step) OF \(totalSteps)")
                            .font(.pantanalMono(8))
                            .foregroundStyle(Color.pantanalGold)
                            .tracking(2)
                        
                        Rectangle()
                            .fill(Color.pantanalGold.opacity(0.15))
                            .frame(height: 1)
                    }
                }
                
                Text(heading)
                    .font(.system(size: isCompact ? 15 : 17, weight: .regular, design: .serif))
                    .foregroundStyle(Color.textPrimary)
                
                Text(bodyText)
                    .font(.pantanalSmall(11.5))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                if showColorSwatches {
                    colorSwatchesRow
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(width: isCompact ? 200 : 280)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.pantanalDark)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.pantanalGold.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.6), radius: 20, y: 10)
        }
    }
    
    private var arrowOffset: CGSize {
        let cardWidth: CGFloat = isCompact ? 200 : 280
        let horizontalOffset = (arrowPosition - 0.5) * cardWidth
        
        switch arrowDirection {
        case .up:
            return CGSize(width: horizontalOffset, height: -28)
        case .down:
            return CGSize(width: horizontalOffset, height: 28)
        case .left:
            return CGSize(width: -126, height: 0)
        }
    }
    
    private var colorSwatchesRow: some View {
        HStack(spacing: 4) {
            ColorSwatch(color: Color(red: 26/255, green: 26/255, blue: 20/255), label: "Silence")
            ColorSwatch(color: Color.pantanalGold, label: "Soft")
            ColorSwatch(color: Color.specOrange, label: "Moderate")
            ColorSwatch(color: Color.specRed, label: "Loud")
        }
        .padding(.top, 4)
    }
}

// MARK: - Tooltip Arrow Shape

struct TooltipArrow: Shape {
    let direction: TooltipCard.ArrowDirection
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch direction {
        case .up:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .down:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        case .left:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Color Swatch

struct ColorSwatch: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.pantanalMono(8))
                .foregroundStyle(Color.textMuted)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.02))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.white.opacity(0.04), lineWidth: 1)
                )
        )
    }
}

// MARK: - Onboarding Glass Button Modifier

/// Liquid Glass button with highlight support for onboarding
struct OnboardingGlassButtonModifier: ViewModifier {
    let isHighlighted: Bool
    
    // Off-white tint for the glass
    private let offWhite = Color(red: 245/255, green: 240/255, blue: 235/255)
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(offWhite).interactive(), in: .circle)
                .shadow(
                    color: isHighlighted ? Color.pantanalGold.opacity(0.4) : .clear,
                    radius: isHighlighted ? 12 : 0
                )
        } else {
            // Fallback for iOS 16-25: off-white skeuomorphic circle button
            content
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 235/255, green: 230/255, blue: 223/255),
                                    Color(red: 205/255, green: 200/255, blue: 193/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                        .shadow(
                            color: isHighlighted ? Color.pantanalGold.opacity(0.4) : .clear,
                            radius: isHighlighted ? 12 : 0
                        )
                )
        }
    }
}

#Preview {
    BioacousticsEduView(onContinue: {})
}
