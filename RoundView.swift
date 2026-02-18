//
//  RoundView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/12/2025.
//

// Interactive game round with spectrogram, hints, and answer options.

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
    
    private let soundPlayer = SoundPlayer.shared
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ProgressMapView(
                        currentRound: round.id,
                        completedRounds: completedRounds
                    )
                    
                    ChallengeBadge(type: round.challengeType)
                    
                    if round.challengeType == .imageToSound {
                        AnimalRevealCard(animal: round.correctAnimal)
                    }
                    
                    spectrogramSection
                    
                    HintSection(
                        hints: round.correctAnimal.hints,
                        revealed: hintsRevealed,
                        onRevealMore: revealNextHint
                    )
                    
                    AnswerOptionsView(
                        options: round.options,
                        challengeType: round.challengeType,
                        selectedAnswer: selectedAnswer,
                        correctAnswer: round.correctAnimal,
                        showResult: showResult,
                        onSelect: handleAnswerSelection
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .opacity(isVisible ? 1 : 0)
            
            if showResult && selectedAnswer == round.correctAnimal {
                CorrectAnswerOverlay(
                    animal: round.correctAnimal,
                    onContinue: onCorrectAnswer
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
                onButtonTap: handlePlaybackButtonTap
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
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...4, id: \.self) { roundNumber in
                let isCompleted = completedRounds.contains(roundNumber)
                let isCurrent = roundNumber == currentRound
                
                ProgressDot(
                    number: roundNumber,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent
                )
                
                if roundNumber < 4 {
                    Rectangle()
                        .fill(isCompleted ? Color.pantanalGold.opacity(0.5) : Color.white.opacity(0.1))
                        .frame(width: 20, height: 2)
                }
            }
        }
        .padding(.vertical, 12)
    }
}

struct ProgressDot: View {
    let number: Int
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.pantanalGold.opacity(0.2) : Color.white.opacity(0.05))
                .frame(width: 44, height: 44)
            
            Circle()
                .strokeBorder(
                    isCompleted ? Color.pantanalGold :
                    isCurrent ? Color.pantanalGold.opacity(0.6) :
                    Color.white.opacity(0.15),
                    lineWidth: isCurrent ? 2 : 1
                )
                .frame(width: 44, height: 44)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.pantanalGold)
            } else {
                Text("\(number)")
                    .font(.pantanalUI(16))
                    .foregroundStyle(isCurrent ? Color.pantanalGold : Color.textMuted)
            }
        }
        .shadow(color: isCurrent ? Color.pantanalGold.opacity(0.3) : .clear, radius: 8)
    }
}

// MARK: - Challenge Badge

struct ChallengeBadge: View {
    let type: GameRound.ChallengeType
    
    var body: some View {
        VStack(spacing: 6) {
            Text(type.badge)
                .font(.pantanalMono(9))
                .foregroundStyle(Color.textMuted)
                .tracking(2)
            
            Text(type.instruction)
                .font(.pantanalBody(15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }
}

// MARK: - Animal Reveal (for Image → Sound rounds)

struct AnimalRevealCard: View {
    let animal: Animal
    
    var body: some View {
        VStack(spacing: 8) {
            Text(animal.emoji)
                .font(.system(size: 48))
            
            Text(animal.name)
                .font(.pantanalHeading(20))
                .foregroundStyle(Color.textPrimary)
            
            Text(animal.scientificName)
                .font(.pantanalCaption())
                .foregroundStyle(Color.textMuted)
                .italic()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.pantanalGold.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Round Recorder Device (simplified for game)

struct RoundRecorderDevice: View {
    let soundFile: String
    let spectrogramHistory: [[Float]]
    let frequencyMagnitudes: [Float]
    let playbackState: SoundPlayer.PlaybackState
    let onButtonTap: () -> Void
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Mini header with status
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    
                    Text(statusText)
                        .font(.pantanalMono(8))
                        .foregroundStyle(Color.textMuted)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            // Spectrogram display
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 10/255, green: 13/255, blue: 11/255))
                
                LiveSpectrogramCanvas(history: spectrogramHistory)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(3)
            }
            .frame(height: 80)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // Controls row: VU meter + Playback button (on the right)
            HStack(spacing: 12) {
                // VU meter
                HStack(spacing: 2) {
                    ForEach(0..<12, id: \.self) { index in
                        let level = averageLevel * 3.0
                        let isActive = index < Int(level * 12)
                        
                        RoundedRectangle(cornerRadius: 1)
                            .fill(vuBarColor(for: index, isActive: isActive))
                            .frame(width: 10, height: 10)
                    }
                }
                
                Spacer()
                
                // Liquid Glass playback button (on the right)
                GlassPlaybackButton(
                    state: playbackState,
                    onTap: onButtonTap
                )
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(red: 26/255, green: 29/255, blue: 27/255))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
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
    
    // Off-white color for tinting the glass
    private let offWhite = Color(red: 245/255, green: 240/255, blue: 235/255)
    
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
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.pantanalDeep)
                .frame(width: 44, height: 44)
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
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<revealed, id: \.self) { index in
                HintCard(number: index + 1, text: hints[index])
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            if revealed < hints.count {
                Button(action: onRevealMore) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 12))
                        Text("Give me a hint")
                            .font(.pantanalSmall(13))
                    }
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
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
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.pantanalMono(10))
                .foregroundStyle(Color.pantanalGold)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.pantanalGold.opacity(0.15)))
            
            Text(text)
                .font(.pantanalSmall(13))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options) { animal in
                AnswerOptionButton(
                    animal: animal,
                    displayMode: challengeType == .soundToImage ? .emoji : .name,
                    isSelected: selectedAnswer?.id == animal.id,
                    isCorrect: showResult && animal.id == correctAnswer.id,
                    isWrong: showResult && selectedAnswer?.id == animal.id && animal.id != correctAnswer.id,
                    onTap: { onSelect(animal) }
                )
            }
        }
        .padding(.top, 8)
    }
}

struct AnswerOptionButton: View {
    let animal: Animal
    let displayMode: DisplayMode
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let onTap: () -> Void
    
    enum DisplayMode {
        case name
        case emoji
    }
    
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
            VStack(spacing: 8) {
                if displayMode == .emoji {
                    Text(animal.emoji)
                        .font(.system(size: 32))
                    
                    Text(animal.name)
                        .font(.pantanalCaption())
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text(animal.name)
                        .font(.pantanalUI(15))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text(animal.scientificName)
                        .font(.pantanalMono(9))
                        .foregroundStyle(Color.textMuted)
                        .italic()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: isSelected || isCorrect || isWrong ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Badge
                ZStack {
                    Circle()
                        .fill(Color.pantanalGold.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .strokeBorder(Color.pantanalGold, lineWidth: 3)
                        .frame(width: 100, height: 100)
                    
                    Text(animal.emoji)
                        .font(.system(size: 44))
                }
                .scaleEffect(isVisible ? 1 : 0.5)
                .opacity(isVisible ? 1 : 0)
                
                VStack(spacing: 8) {
                    Text("\(animal.name) identified!")
                        .font(.pantanalHeading(24))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text(animal.scientificName)
                        .font(.pantanalCaption())
                        .foregroundStyle(Color.textMuted)
                        .italic()
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
                
                Text(animal.conservationFact)
                    .font(.pantanalSmall(14))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
                
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Next Sound")
                            .font(.pantanalUI(15))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
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
            .padding(32)
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
