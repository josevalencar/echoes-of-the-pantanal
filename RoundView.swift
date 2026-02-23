//
//  RoundView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 17/02/2026.
//

// Interactive game round with spectrogram, hints, and answer options.
// Responsive layout for iPad and iPhone in portrait orientation.

import SwiftUI

struct RoundView: View {
    let round: GameRound
    let completedRounds: Set<Int>
    let onCorrectAnswer: () -> Void
    
    @State private var selectedAnswer: Animal?
    @State private var showResult = false
    @State private var hintsRevealed = 0
    @State private var isVisible = false
    @State private var spectrogramHistory: [[Float]] = []
    @State private var frequencyMagnitudes: [Float] = []
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let soundPlayer = SoundPlayer.shared
    
    /// Adaptive layout values based on device size class
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var maxContentWidth: CGFloat { isRegularWidth ? 600 : .infinity }
    private var horizontalPadding: CGFloat { isRegularWidth ? 40 : 24 }
    private var verticalSpacing: CGFloat { isRegularWidth ? 28 : 20 }
    private var spectrogramHeight: CGFloat { isRegularWidth ? 120 : 80 }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: verticalSpacing) {
                    ProgressMapView(
                        currentRound: round.id,
                        completedRounds: completedRounds,
                        isRegularWidth: isRegularWidth
                    )
                    
                    ChallengeBadge(type: round.challengeType, isRegularWidth: isRegularWidth)
                    
                    if round.challengeType == .imageToSound {
                        AnimalRevealCard(animal: round.correctAnimal, isRegularWidth: isRegularWidth)
                    }
                    
                    spectrogramSection
                    
                    HintSection(
                        hints: round.correctAnimal.hints,
                        revealed: hintsRevealed,
                        onRevealMore: revealNextHint,
                        isRegularWidth: isRegularWidth
                    )
                    
                    AnswerOptionsView(
                        options: round.options,
                        challengeType: round.challengeType,
                        selectedAnswer: selectedAnswer,
                        correctAnswer: round.correctAnimal,
                        showResult: showResult,
                        onSelect: handleAnswerSelection,
                        isRegularWidth: isRegularWidth
                    )
                }
                .frame(maxWidth: maxContentWidth)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, isRegularWidth ? 32 : 20)
                .padding(.bottom, isRegularWidth ? 60 : 40)
                .frame(maxWidth: .infinity) // Center content on iPad
            }
            .opacity(isVisible ? 1 : 0)
            
            if showResult && selectedAnswer == round.correctAnimal {
                CorrectAnswerOverlay(
                    animal: round.correctAnimal,
                    onContinue: onCorrectAnswer,
                    isRegularWidth: isRegularWidth
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isVisible = true
            }
            // Auto-play the sound when the round appears
            // play() internally calls stop() first, so no need for onDisappear cleanup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                soundPlayer.play(soundFile: round.correctAnimal.soundFile)
            }
        }
        .onReceive(soundPlayer.$frequencyMagnitudes) { newValue in
            frequencyMagnitudes = newValue
            // Only update history when there's actual audio data
            if soundPlayer.isPlaying {
                updateSpectrogramHistory(newValue)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showResult)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.pantanalDeep,
                Color(red: 15/255, green: 35/255, blue: 25/255),
                Color.pantanalDark
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var spectrogramSection: some View {
        VStack(spacing: 8) {
            RoundRecorderDevice(
                soundFile: round.correctAnimal.soundFile,
                spectrogramHistory: spectrogramHistory,
                frequencyMagnitudes: frequencyMagnitudes,
                playbackState: soundPlayer.state,
                onButtonTap: handlePlaybackButtonTap,
                spectrogramHeight: spectrogramHeight,
                isRegularWidth: isRegularWidth
            )
        }
    }
    
    private func handlePlaybackButtonTap() {
        // If currently ended, clear spectrogram history before replaying
        if soundPlayer.hasEnded {
            spectrogramHistory = []
        }
        // Let SoundPlayer handle the state transition
        soundPlayer.handleButtonTap()
    }
    
    private func handleAnswerSelection(_ animal: Animal) {
        guard !showResult else { return }
        selectedAnswer = animal
        
        // Brief delay before showing result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showResult = true
            
            if animal == round.correctAnimal {
                // Stop the sound when correct
                soundPlayer.stop()
            } else {
                // If wrong, reset after a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showResult = false
                        selectedAnswer = nil
                    }
                }
            }
        }
    }
    
    private func revealNextHint() {
        if hintsRevealed < round.correctAnimal.hints.count {
            withAnimation {
                hintsRevealed += 1
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

// MARK: - Progress Map

struct ProgressMapView: View {
    let currentRound: Int
    let completedRounds: Set<Int>
    var isRegularWidth: Bool = false
    
    private var dotSize: CGFloat { isRegularWidth ? 52 : 44 }
    private var connectorWidth: CGFloat { isRegularWidth ? 32 : 20 }
    private var spacing: CGFloat { isRegularWidth ? 16 : 12 }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...4, id: \.self) { roundNumber in
                let isCompleted = completedRounds.contains(roundNumber)
                let isCurrent = roundNumber == currentRound
                
                ProgressDot(
                    number: roundNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    size: dotSize
                )
                
                if roundNumber < 4 {
                    Rectangle()
                        .fill(isCompleted ? Color.pantanalGold.opacity(0.5) : Color.white.opacity(0.1))
                        .frame(width: connectorWidth, height: 2)
                }
            }
        }
        .padding(.vertical, isRegularWidth ? 16 : 12)
    }
}

struct ProgressDot: View {
    let number: Int
    let isCompleted: Bool
    let isCurrent: Bool
    var size: CGFloat = 44
    
    private var fontSize: CGFloat { size > 48 ? 18 : 16 }
    private var checkmarkSize: CGFloat { size > 48 ? 16 : 14 }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.pantanalGold.opacity(0.2) : Color.white.opacity(0.05))
                .frame(width: size, height: size)
            
            Circle()
                .strokeBorder(
                    isCompleted ? Color.pantanalGold :
                    isCurrent ? Color.pantanalGold.opacity(0.6) :
                    Color.white.opacity(0.15),
                    lineWidth: isCurrent ? 2 : 1
                )
                .frame(width: size, height: size)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: checkmarkSize, weight: .bold))
                    .foregroundStyle(Color.pantanalGold)
            } else {
                Text("\(number)")
                    .font(.pantanalUI(fontSize))
                    .foregroundStyle(isCurrent ? Color.pantanalGold : Color.textMuted)
            }
        }
        .shadow(color: isCurrent ? Color.pantanalGold.opacity(0.3) : .clear, radius: 8)
    }
}

// MARK: - Challenge Badge

struct ChallengeBadge: View {
    let type: GameRound.ChallengeType
    var isRegularWidth: Bool = false
    
    private var badgeFontSize: CGFloat { isRegularWidth ? 11 : 9 }
    private var instructionFontSize: CGFloat { isRegularWidth ? 17 : 15 }
    
    var body: some View {
        VStack(spacing: isRegularWidth ? 8 : 6) {
            Text(type.badge)
                .font(.pantanalMono(badgeFontSize))
                .foregroundStyle(Color.textMuted)
                .tracking(2)
            
            Text(type.instruction)
                .font(.pantanalBody(instructionFontSize))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, isRegularWidth ? 8 : 4)
    }
}

// MARK: - Animal Reveal (for Image → Sound rounds)

struct AnimalRevealCard: View {
    let animal: Animal
    var isRegularWidth: Bool = false
    
    private var imageSize: CGFloat { isRegularWidth ? 80 : 64 }
    private var nameSize: CGFloat { isRegularWidth ? 24 : 20 }
    private var padding: CGFloat { isRegularWidth ? 28 : 20 }
    
    var body: some View {
        VStack(spacing: isRegularWidth ? 12 : 8) {
            if let imageName = animal.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            }
            
            Text(animal.name)
                .font(.pantanalHeading(nameSize))
                .foregroundStyle(Color.textPrimary)
            
            Text(animal.scientificName)
                .font(.pantanalCaption())
                .foregroundStyle(Color.textMuted)
                .italic()
        }
        .padding(padding)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: isRegularWidth ? 20 : 16)
                .strokeBorder(Color.pantanalGold.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: isRegularWidth ? 20 : 16))
    }
}

// MARK: - Round Recorder Device (simplified for game)

struct RoundRecorderDevice: View {
    let soundFile: String
    let spectrogramHistory: [[Float]]
    let frequencyMagnitudes: [Float]
    let playbackState: SoundPlayer.PlaybackState
    let onButtonTap: () -> Void
    var spectrogramHeight: CGFloat = 80
    var isRegularWidth: Bool = false
    
    /// Status text based on playback state
    private var statusText: String {
        switch playbackState {
        case .playing: return "PLAYING"
        case .paused: return "PAUSED"
        case .ended: return "STOPPED"
        }
    }
    
    /// Status indicator color
    private var statusColor: Color {
        switch playbackState {
        case .playing: return Color.specRed
        case .paused: return Color.pantanalGold
        case .ended: return Color.textMuted
        }
    }
    
    private var horizontalPadding: CGFloat { isRegularWidth ? 16 : 12 }
    private var cornerRadius: CGFloat { isRegularWidth ? 16 : 12 }
    private var vuBarSize: CGFloat { isRegularWidth ? 12 : 10 }
    private var statusFontSize: CGFloat { isRegularWidth ? 10 : 8 }
    
    var body: some View {
        VStack(spacing: 0) {
            // Mini header with status
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: isRegularWidth ? 8 : 6, height: isRegularWidth ? 8 : 6)
                    
                    Text(statusText)
                        .font(.pantanalMono(statusFontSize))
                        .foregroundStyle(Color.textMuted)
                }
                
                Spacer()
            }
            .padding(.horizontal, horizontalPadding + 4)
            .padding(.vertical, isRegularWidth ? 12 : 10)
            
            // Spectrogram display
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 10/255, green: 13/255, blue: 11/255))
                
                LiveSpectrogramCanvas(history: spectrogramHistory)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(3)
            }
            .frame(height: spectrogramHeight)
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, isRegularWidth ? 12 : 8)
            
            // Controls row: VU meter + Playback button (on the right)
            HStack(spacing: isRegularWidth ? 16 : 12) {
                // VU meter
                HStack(spacing: isRegularWidth ? 3 : 2) {
                    ForEach(0..<12, id: \.self) { index in
                        let level = averageLevel * 3.0
                        let isActive = index < Int(level * 12)
                        
                        RoundedRectangle(cornerRadius: 1)
                            .fill(vuBarColor(for: index, isActive: isActive))
                            .frame(width: vuBarSize, height: vuBarSize)
                    }
                }
                
                Spacer()
                
                // Liquid Glass playback button (on the right)
                GlassPlaybackButton(
                    state: playbackState,
                    onTap: onButtonTap,
                    isRegularWidth: isRegularWidth
                )
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, isRegularWidth ? 16 : 12)
        }
        .background(Color(red: 26/255, green: 29/255, blue: 27/255))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    private var averageLevel: Float {
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
}

// MARK: - Liquid Glass Playback Button (3-state: pause/play/replay)

struct GlassPlaybackButton: View {
    let state: SoundPlayer.PlaybackState
    let onTap: () -> Void
    var isRegularWidth: Bool = false
    
    // Off-white color for tinting the glass
    private let offWhite = Color(red: 245/255, green: 240/255, blue: 235/255)
    
    private var buttonSize: CGFloat { isRegularWidth ? 52 : 44 }
    private var iconSize: CGFloat { isRegularWidth ? 22 : 18 }
    
    /// Icon changes based on playback state
    private var iconName: String {
        switch state {
        case .playing: return "pause.fill"      // Show pause when playing
        case .paused: return "play.fill"        // Show play when paused
        case .ended: return "arrow.counterclockwise" // Show replay when ended
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color.pantanalDeep)
                .frame(width: buttonSize, height: buttonSize)
        }
        .buttonStyle(.plain)
        .modifier(OffWhiteGlassModifier(tintColor: offWhite))
    }
}

/// Applies off-white tinted Liquid Glass on iOS 26+, falls back to skeuomorphic style on older versions
struct OffWhiteGlassModifier: ViewModifier {
    let tintColor: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(tintColor).interactive(), in: .circle)
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
                )
        }
    }
}

// MARK: - Hint Section

struct HintSection: View {
    let hints: [String]
    let revealed: Int
    let onRevealMore: () -> Void
    var isRegularWidth: Bool = false
    
    private var spacing: CGFloat { isRegularWidth ? 14 : 10 }
    private var buttonFontSize: CGFloat { isRegularWidth ? 15 : 13 }
    private var iconSize: CGFloat { isRegularWidth ? 14 : 12 }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<revealed, id: \.self) { index in
                HintCard(number: index + 1, text: hints[index], isRegularWidth: isRegularWidth)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            if revealed < hints.count {
                Button(action: onRevealMore) {
                    HStack(spacing: isRegularWidth ? 8 : 6) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: iconSize))
                        Text("Give me a hint")
                            .font(.pantanalSmall(buttonFontSize))
                    }
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, isRegularWidth ? 20 : 16)
                    .padding(.vertical, isRegularWidth ? 12 : 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.04))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.easeOut(duration: 0.3), value: revealed)
    }
}

struct HintCard: View {
    let number: Int
    let text: String
    var isRegularWidth: Bool = false
    
    private var numberSize: CGFloat { isRegularWidth ? 24 : 20 }
    private var fontSize: CGFloat { isRegularWidth ? 15 : 13 }
    private var padding: CGFloat { isRegularWidth ? 16 : 12 }
    
    var body: some View {
        HStack(alignment: .top, spacing: isRegularWidth ? 14 : 10) {
            Text("\(number)")
                .font(.pantanalMono(isRegularWidth ? 12 : 10))
                .foregroundStyle(Color.pantanalGold)
                .frame(width: numberSize, height: numberSize)
                .background(Circle().fill(Color.pantanalGold.opacity(0.15)))
            
            Text(text)
                .font(.pantanalSmall(fontSize))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(isRegularWidth ? 6 : 4)
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: isRegularWidth ? 12 : 10))
    }
}

// MARK: - Answer Options

struct AnswerOptionsView: View {
    let options: [Animal]
    let challengeType: GameRound.ChallengeType
    let selectedAnswer: Animal?
    let correctAnswer: Animal
    let showResult: Bool
    let onSelect: (Animal) -> Void
    var isRegularWidth: Bool = false
    
    private var gridSpacing: CGFloat { isRegularWidth ? 16 : 12 }
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: gridSpacing),
            GridItem(.flexible(), spacing: gridSpacing)
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: gridSpacing) {
            ForEach(options) { animal in
                AnswerOptionButton(
                    animal: animal,
                    displayMode: challengeType == .soundToImage ? .image : .name,
                    isSelected: selectedAnswer?.id == animal.id,
                    isCorrect: showResult && animal.id == correctAnswer.id,
                    isWrong: showResult && selectedAnswer?.id == animal.id && animal.id != correctAnswer.id,
                    onTap: { onSelect(animal) },
                    isRegularWidth: isRegularWidth
                )
            }
        }
        .padding(.top, isRegularWidth ? 12 : 8)
    }
}

struct AnswerOptionButton: View {
    let animal: Animal
    let displayMode: DisplayMode
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let onTap: () -> Void
    var isRegularWidth: Bool = false
    
    enum DisplayMode {
        case name
        case image
    }
    
    private var imageSize: CGFloat { isRegularWidth ? 52 : 44 }
    private var nameSize: CGFloat { isRegularWidth ? 17 : 15 }
    private var captionSize: CGFloat { isRegularWidth ? 12 : 11 }
    private var monoSize: CGFloat { isRegularWidth ? 10 : 9 }
    private var verticalPadding: CGFloat { isRegularWidth ? 20 : 16 }
    private var cornerRadius: CGFloat { isRegularWidth ? 14 : 12 }
    
    private var borderColor: Color {
        if isCorrect { return Color.pantanalLight }
        if isWrong { return Color.specRed }
        if isSelected { return Color.pantanalGold }
        return Color.white.opacity(0.1)
    }
    
    private var backgroundColor: Color {
        if isCorrect { return Color.pantanalLight.opacity(0.15) }
        if isWrong { return Color.specRed.opacity(0.1) }
        if isSelected { return Color.pantanalGold.opacity(0.08) }
        return Color.white.opacity(0.03)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: isRegularWidth ? 10 : 8) {
                if displayMode == .image {
                    if let imageName = animal.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                    }
                    
                    Text(animal.name)
                        .font(.pantanalCaption(captionSize))
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text(animal.name)
                        .font(.pantanalUI(nameSize))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text(animal.scientificName)
                        .font(.pantanalMono(monoSize))
                        .foregroundStyle(Color.textMuted)
                        .italic()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: isSelected || isCorrect || isWrong ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.2), value: isSelected)
        .animation(.easeOut(duration: 0.2), value: isCorrect)
        .animation(.easeOut(duration: 0.2), value: isWrong)
    }
}

// MARK: - Correct Answer Overlay

struct CorrectAnswerOverlay: View {
    let animal: Animal
    let onContinue: () -> Void
    var isRegularWidth: Bool = false
    
    @State private var isVisible = false
    
    // Adaptive sizing
    private var badgeSize: CGFloat { isRegularWidth ? 120 : 100 }
    private var imageSize: CGFloat { isRegularWidth ? 72 : 60 }
    private var headingSize: CGFloat { isRegularWidth ? 28 : 24 }
    private var factSize: CGFloat { isRegularWidth ? 16 : 14 }
    private var buttonFontSize: CGFloat { isRegularWidth ? 17 : 15 }
    private var verticalSpacing: CGFloat { isRegularWidth ? 32 : 24 }
    private var contentPadding: CGFloat { isRegularWidth ? 48 : 32 }
    private var maxContentWidth: CGFloat { isRegularWidth ? 500 : .infinity }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: verticalSpacing) {
                // Badge
                ZStack {
                    Circle()
                        .fill(Color.pantanalGold.opacity(0.15))
                        .frame(width: badgeSize, height: badgeSize)
                    
                    Circle()
                        .strokeBorder(Color.pantanalGold, lineWidth: isRegularWidth ? 4 : 3)
                        .frame(width: badgeSize, height: badgeSize)
                    
                    if let imageName = animal.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                    }
                }
                .scaleEffect(isVisible ? 1 : 0.5)
                .opacity(isVisible ? 1 : 0)
                
                VStack(spacing: isRegularWidth ? 10 : 8) {
                    Text("\(animal.name) identified!")
                        .font(.pantanalHeading(headingSize))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text(animal.scientificName)
                        .font(.pantanalCaption(isRegularWidth ? 13 : 11))
                        .foregroundStyle(Color.textMuted)
                        .italic()
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
                
                Text(animal.conservationFact)
                    .font(.pantanalSmall(factSize))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(isRegularWidth ? 7 : 5)
                    .padding(.horizontal, isRegularWidth ? 32 : 24)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                
                Button(action: onContinue) {
                    HStack(spacing: isRegularWidth ? 10 : 8) {
                        Text("Next Sound")
                            .font(.pantanalUI(buttonFontSize))
                        Image(systemName: "arrow.right")
                            .font(.system(size: isRegularWidth ? 15 : 13))
                    }
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, isRegularWidth ? 36 : 28)
                    .padding(.vertical, isRegularWidth ? 18 : 14)
                    .background(
                        Capsule()
                            .fill(Color.pantanalGold.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.pantanalGold.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
            }
            .frame(maxWidth: maxContentWidth)
            .padding(contentPadding)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    RoundView(
        round: GameRound.allRounds[0],
        completedRounds: [],
        onCorrectAnswer: {}
    )
}
