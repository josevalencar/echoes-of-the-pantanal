//
//  RecorderDevice.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 25/02/26.
//

// Skeuomorphic field recorder device with spectrogram display, VU meters, and control knobs.
// Supports both microphone input and external audio data for unified usage across scenes.

import SwiftUI
import Combine

// MARK: - Audio Source

/// Defines the audio source for the recorder device.
enum RecorderAudioSource {
    /// Uses live microphone input (default behavior).
    case microphone
    /// Uses externally provided audio data (for file playback integration).
    case external
    /// No audio - static display.
    case none
}

// MARK: - RecorderDevice

struct RecorderDevice: View {
    // MARK: Configuration
    
    /// The audio source to use.
    var audioSource: RecorderAudioSource = .microphone
    
    /// External spectrogram history (used when audioSource is .external).
    var externalSpectrogramHistory: [[Float]] = []
    
    /// External frequency magnitudes (used when audioSource is .external).
    var externalFrequencyMagnitudes: [Float] = []
    
    /// Whether to highlight the play button (for onboarding).
    var highlightPlayButton: Bool = false
    
    /// Whether to highlight the spectrogram area (for onboarding).
    var highlightSpectrogram: Bool = false
    
    /// Custom status text override.
    var statusText: String? = nil
    
    /// Custom label text (right side of header).
    var labelText: String? = nil
    
    /// Whether the device is in playing state (for external control).
    var isPlaying: Bool = false
    
    /// Callback when play button is tapped.
    var onPlayTap: (() -> Void)? = nil
    
    // MARK: Internal State
    
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var spectrogramHistory: [[Float]] = []
    @State private var frequencyMagnitudes: [Float] = []

    private let historyColumns = 60
    private let audioManager = AudioManager.shared
    
    // MARK: Computed Properties
    
    private var effectiveSpectrogramHistory: [[Float]] {
        audioSource == .external ? externalSpectrogramHistory : spectrogramHistory
    }
    
    private var effectiveFrequencyMagnitudes: [Float] {
        audioSource == .external ? externalFrequencyMagnitudes : frequencyMagnitudes
    }
    
    private var effectiveIsActive: Bool {
        audioSource == .external ? isPlaying : isRecording
    }
    
    private var effectiveStatusText: String {
        if let custom = statusText {
            return custom
        }
        switch audioSource {
        case .microphone:
            return isRecording ? "RECORDING" : "PAUSED"
        case .external:
            return isPlaying ? "PLAYING" : "READY"
        case .none:
            return "READY"
        }
    }

    // MARK: Body
    
    var body: some View {
        VStack(spacing: 0) {
            RecorderHeader(
                timestamp: formattedTime,
                isRecording: effectiveIsActive,
                statusText: effectiveStatusText,
                labelText: labelText
            )

            LiveSpectrogramDisplay(
                history: effectiveSpectrogramHistory,
                isRecording: effectiveIsActive,
                onToggle: handleToggle,
                highlightPlayButton: highlightPlayButton,
                highlightSpectrogram: highlightSpectrogram
            )

            TimeMarkersRow()

            LiveVUMeterRow(magnitudes: effectiveFrequencyMagnitudes)

            KnobsRow()

            HapticIndicator()

            DeviceLabel()
        }
        .background(Color(red: 26/255, green: 29/255, blue: 27/255))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 30, y: 20)
        .task {
            if audioSource == .microphone {
                startRecording()
            }
        }
        .onDisappear {
            if audioSource == .microphone {
                stopRecording()
            }
        }
        .onReceive(audioManager.$frequencyMagnitudes) { newValue in
            guard audioSource == .microphone else { return }
            frequencyMagnitudes = newValue
            updateSpectrogramHistory(newValue)
        }
    }

    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let hundredths = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, hundredths)
    }
    
    private func handleToggle() {
        if let onPlayTap {
            onPlayTap()
        } else if audioSource == .microphone {
            toggleRecording()
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        audioManager.startRecording()
        isRecording = true
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            elapsedTime += 0.01
        }
    }

    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        audioManager.stopRecording()
        isRecording = false
    }

    private func updateSpectrogramHistory(_ magnitudes: [Float]) {
        spectrogramHistory.append(magnitudes)
        if spectrogramHistory.count > historyColumns {
            spectrogramHistory.removeFirst()
        }
    }
}

struct RecorderHeader: View {
    let timestamp: String
    var isRecording: Bool = true
    var statusText: String? = nil
    var labelText: String? = nil
    
    @State private var isBlinking = false
    
    private var displayStatusText: String {
        statusText ?? (isRecording ? "RECORDING" : "PAUSED")
    }

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(isRecording ? Color.specRed : Color.textMuted)
                    .frame(width: 8, height: 8)
                    .shadow(color: isRecording ? Color.specRed.opacity(0.5) : .clear, radius: 4)
                    .opacity(isRecording ? (isBlinking ? 0.3 : 1.0) : 0.5)

                Text(displayStatusText)
                    .font(.pantanalMono(9))
                    .foregroundStyle(Color.textMuted)
                    .tracking(2)
            }

            Spacer()
            
            if let labelText {
                Text(labelText)
                    .font(.pantanalMono(9))
                    .foregroundStyle(Color.textMuted)
            } else {
                Text(timestamp)
                    .font(.pantanalMono(12))
                    .foregroundStyle(Color.pantanalGold)
                    .tracking(1)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        }
    }
}

struct LiveSpectrogramDisplay: View {
    let history: [[Float]]
    var isRecording: Bool
    var onToggle: (() -> Void)?
    var highlightPlayButton: Bool = false
    var highlightSpectrogram: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 10/255, green: 13/255, blue: 11/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            highlightSpectrogram ? Color.pantanalGold.opacity(0.3) : Color.white.opacity(0.04),
                            lineWidth: highlightSpectrogram ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                .shadow(
                    color: highlightSpectrogram ? Color.pantanalGold.opacity(0.08) : .clear,
                    radius: 20
                )

            LiveSpectrogramCanvas(history: history)

            FrequencyLabels()

            PlayButton(isPlaying: isRecording, onTap: onToggle, isHighlighted: highlightPlayButton)
        }
        .frame(height: 120)
        .padding(.horizontal, 16)
    }
}

struct LiveSpectrogramCanvas: View {
    let history: [[Float]]

    private let displayRows = 32

    var body: some View {
        Canvas { context, size in
            drawLiveSpectrogram(context: context, size: size)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(4)
    }

    private func drawLiveSpectrogram(context: GraphicsContext, size: CGSize) {
        guard !history.isEmpty else {
            drawEmptyState(context: context, size: size)
            return
        }

        let columns = history.count
        let colWidth = size.width / CGFloat(60)
        let rowHeight = size.height / CGFloat(displayRows)

        for (colIndex, magnitudes) in history.enumerated() {
            let x = CGFloat(colIndex) * colWidth

            let bandsToDisplay = min(magnitudes.count, displayRows)
            for row in 0..<bandsToDisplay {
                let invertedRow = displayRows - 1 - row
                let y = CGFloat(invertedRow) * rowHeight

                let amplitude = Double(magnitudes[row])
                let boostedAmplitude = min(1.0, amplitude * 2.5)
                let color = spectrogramColor(for: boostedAmplitude)

                let rect = CGRect(x: x + 0.5, y: y + 0.5, width: colWidth - 1, height: rowHeight - 1)
                context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(color))
            }
        }
    }

    private func drawEmptyState(context: GraphicsContext, size: CGSize) {
        let columns = 60
        let rows = displayRows
        let colWidth = size.width / CGFloat(columns)
        let rowHeight = size.height / CGFloat(rows)

        for col in 0..<columns {
            for row in 0..<rows {
                let x = CGFloat(col) * colWidth
                let y = CGFloat(row) * rowHeight
                let rect = CGRect(x: x + 0.5, y: y + 0.5, width: colWidth - 1, height: rowHeight - 1)
                context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(Color.pantanalGold.opacity(0.03)))
            }
        }
    }

    private func spectrogramColor(for amplitude: Double) -> Color {
        if amplitude < 0.1 {
            return Color.pantanalGold.opacity(0.03)
        } else if amplitude < 0.25 {
            return Color.pantanalGold.opacity(amplitude * 1.2)
        } else if amplitude < 0.5 {
            return Color.specYellow.opacity(amplitude * 1.1)
        } else if amplitude < 0.75 {
            return Color.specOrange.opacity(min(1.0, amplitude * 1.2))
        } else {
            return Color.specRed.opacity(min(1.0, amplitude * 1.1))
        }
    }
}

struct FrequencyLabels: View {
    private let frequencies = ["8kHz", "4kHz", "2kHz", "200Hz"]
    
    var body: some View {
        VStack {
            ForEach(frequencies, id: \.self) { freq in
                Text(freq)
                    .font(.pantanalMono(7))
                    .foregroundStyle(Color.white.opacity(0.15))
                if freq != frequencies.last {
                    Spacer()
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct PlayButton: View {
    var isPlaying: Bool
    var onTap: (() -> Void)?
    var isHighlighted: Bool = false
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: { onTap?() }) {
            ZStack {
                // Pulsing highlight ring
                if isHighlighted {
                    Circle()
                        .strokeBorder(Color.pantanalGold.opacity(isPulsing ? 0.4 : 0.15), lineWidth: 3)
                        .frame(width: 56, height: 56)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)
                }
                
                Circle()
                    .fill(Color.pantanalGold.opacity(isHighlighted ? 0.18 : 0.12))
                    .frame(width: 44, height: 44)
                
                Circle()
                    .strokeBorder(Color.pantanalGold.opacity(isHighlighted ? 0.5 : 0.3), lineWidth: 1.5)
                    .frame(width: 44, height: 44)
                
                if isPlaying {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.pantanalGold.opacity(0.8))
                            .frame(width: 4, height: 14)
                        Rectangle()
                            .fill(Color.pantanalGold.opacity(0.8))
                            .frame(width: 4, height: 14)
                    }
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.pantanalGold.opacity(0.8))
                        .offset(x: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .shadow(color: isHighlighted ? Color.pantanalGold.opacity(0.3) : .black.opacity(0.3), radius: isHighlighted ? 12 : 8, y: 4)
        .onAppear {
            updatePulseState()
        }
        .onReceive(Just(isHighlighted)) { _ in
            updatePulseState()
        }
    }
    
    private func updatePulseState() {
        if isHighlighted && !isPulsing {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        } else if !isHighlighted && isPulsing {
            isPulsing = false
        }
    }
}

struct TimeMarkersRow: View {
    private let markers = ["0:00", "0:15", "0:30", "0:45"]
    
    var body: some View {
        HStack {
            ForEach(markers, id: \.self) { marker in
                Text(marker)
                    .font(.pantanalMono(6))
                    .foregroundStyle(Color.white.opacity(0.08))
                if marker != markers.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

struct LiveVUMeterRow: View {
    let magnitudes: [Float]

    private var averageLevel: Float {
        guard !magnitudes.isEmpty else { return 0 }
        let sum = magnitudes.reduce(0, +)
        return sum / Float(magnitudes.count)
    }

    private var activeBars: Int {
        let level = averageLevel * 3.0
        return min(14, Int(level * 14))
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<14, id: \.self) { index in
                LiveVUBar(index: index, isActive: index < activeBars)
            }

            Spacer()

            Text(decibelString)
                .font(.pantanalMono(8))
                .foregroundStyle(Color.white.opacity(0.15))
                .tracking(0.5)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .animation(.easeOut(duration: 0.05), value: activeBars)
    }

    private var decibelString: String {
        let db = 20 * log10(max(averageLevel, 0.0001))
        return String(format: "%.0f dB", max(-60, db))
    }
}

struct LiveVUBar: View {
    let index: Int
    let isActive: Bool

    private var activeColor: Color {
        switch index {
        case 0...5: return .pantanalLight
        case 6...8: return .pantanalGold
        case 9...11: return .pantanalAmber
        default: return .specRed
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isActive ? activeColor : Color.white.opacity(0.04))
            .opacity(isActive ? activeOpacity : 1.0)
            .frame(width: 12, height: 16)
    }

    private var activeOpacity: Double {
        switch index {
        case 0...5: return 0.7
        case 6...8: return 0.6
        case 9...11: return 0.5
        default: return 0.45
        }
    }
}

struct KnobsRow: View {
    var body: some View {
        HStack(spacing: 0) {
            KnobControl(label: "GAIN", rotation: -30)
            Spacer()
            KnobControl(label: "LOW CUT", rotation: 25)
            Spacer()
            KnobControl(label: "VOLUME", rotation: -15)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

struct KnobControl: View {
    let label: String
    let rotation: Double
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.03), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                    .frame(width: 48, height: 48)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 42/255, green: 45/255, blue: 43/255),
                                Color(red: 26/255, green: 29/255, blue: 27/255)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 5, y: 3)
                
                KnobIndicator()
                    .rotationEffect(.degrees(rotation))
            }
            
            Text(label)
                .font(.pantanalMono(7))
                .foregroundStyle(Color.textMuted)
                .tracking(1.5)
        }
    }
}

struct KnobIndicator: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.pantanalGold)
                .frame(width: 2.5, height: 12)
                .shadow(color: Color.pantanalGold.opacity(0.3), radius: 2)
            Spacer()
        }
        .frame(height: 40)
        .padding(.top, 6)
    }
}

struct HapticIndicator: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "waveform")
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.15))
            
            Text("HAPTIC FEEDBACK ACTIVE")
                .font(.pantanalMono(7))
                .foregroundStyle(Color.white.opacity(0.1))
                .tracking(1)
        }
        .padding(.bottom, 10)
    }
}

struct DeviceLabel: View {
    var body: some View {
        Text("SAUÁ FIELD RECORDER · MODEL PT-26")
            .font(.pantanalMono(7))
            .foregroundStyle(Color.white.opacity(0.1))
            .tracking(3)
            .padding(.bottom, 14)
    }
}

#Preview {
    ZStack {
        Color.pantanalDeep
            .ignoresSafeArea()
        
        RecorderDevice()
            .padding(.horizontal, 24)
    }
}
