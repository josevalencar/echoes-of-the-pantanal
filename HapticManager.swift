//
//  HapticManager.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 23/02/26.
//

// Core Haptics manager for real-time audio-reactive haptic feedback.
// Haptics continuously match the audio's frequency spectrum and amplitude.
// Low frequencies → deep rumble (low sharpness), High frequencies → sharp taps (high sharpness)
// Enhances both immersion for all users and accessibility for visually impaired users.

import CoreHaptics
import UIKit

/// Manages real-time haptic feedback synchronized with audio frequency data.
/// Uses CHHapticAdvancedPatternPlayer with dynamic parameters for continuous audio-reactive haptics.
final class HapticManager: @unchecked Sendable {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?
    private let hapticQueue = DispatchQueue(label: "com.pantanal.haptics", qos: .userInteractive)
    
    /// Whether the device supports haptics
    private(set) var supportsHaptics: Bool = false
    
    /// Track if continuous haptics are currently active
    private var isContinuousHapticActive: Bool = false
    
    /// Throttle for dynamic parameter updates (avoid overwhelming the haptic engine)
    private var lastUpdateTime: CFTimeInterval = 0
    private let updateInterval: CFTimeInterval = 0.05 // 20 updates per second
    
    private init() {
        setupEngine()
    }
    
    // MARK: - Engine Setup
    
    private func setupEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("HapticManager: Device does not support haptics")
            supportsHaptics = false
            return
        }
        
        supportsHaptics = true
        
        do {
            engine = try CHHapticEngine()
            
            engine?.resetHandler = { [weak self] in
                print("HapticManager: Engine reset, restarting...")
                do {
                    try self?.engine?.start()
                } catch {
                    print("HapticManager: Failed to restart engine: \(error)")
                }
            }
            
            engine?.stoppedHandler = { [weak self] reason in
                print("HapticManager: Engine stopped, reason: \(reason)")
                self?.isContinuousHapticActive = false
            }
            
            // Enable auto-shutdown when idle to save battery
            engine?.isAutoShutdownEnabled = true
            
            try engine?.start()
            print("HapticManager: Engine started successfully")
            
        } catch {
            print("HapticManager: Failed to create engine: \(error)")
            supportsHaptics = false
        }
    }
    
    private func ensureEngineRunning() {
        guard supportsHaptics else { return }
        
        do {
            try engine?.start()
        } catch {
            print("HapticManager: Failed to start engine: \(error)")
        }
    }
    
    // MARK: - Real-Time Audio-Reactive Haptics
    
    /// Start continuous haptic feedback that will be updated with audio data
    /// Call this when audio playback begins
    func startContinuousHaptic() {
        guard supportsHaptics, !isContinuousHapticActive else { return }
        
        hapticQueue.async { [weak self] in
            self?.createContinuousPlayer()
        }
    }
    
    /// Stop continuous haptic feedback
    /// Call this when audio playback stops
    func stopContinuousHaptic() {
        guard supportsHaptics else { return }
        
        hapticQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
            } catch {
                print("HapticManager: Failed to stop continuous player: \(error)")
            }
            
            self.continuousPlayer = nil
            self.isContinuousHapticActive = false
        }
    }
    
    /// Update haptics based on real-time frequency magnitude data from FFT
    /// - Parameter magnitudes: Array of frequency band magnitudes (0.0 to 1.0)
    /// Call this frequently (e.g., from audio buffer callback) while audio is playing
    func updateWithFrequencyData(_ magnitudes: [Float]) {
        guard supportsHaptics, isContinuousHapticActive else { return }
        
        // Throttle updates to avoid overwhelming the haptic engine
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastUpdateTime >= updateInterval else { return }
        lastUpdateTime = currentTime
        
        hapticQueue.async { [weak self] in
            self?.applyDynamicParameters(from: magnitudes)
        }
    }
    
    /// Create a continuous haptic player for real-time audio feedback
    private func createContinuousPlayer() {
        ensureEngineRunning()
        
        guard let engine = engine else { return }
        
        do {
            // Create a long continuous haptic event that we'll modulate in real-time
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            // Create a continuous haptic event with long duration
            // We'll dynamically adjust its parameters based on audio data
            let continuousEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 100 // Long duration - we'll stop it manually
            )
            
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            
            // Enable looping so it doesn't stop
            continuousPlayer?.loopEnabled = false
            
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
            isContinuousHapticActive = true
            
            print("HapticManager: Continuous haptic player started")
            
        } catch {
            print("HapticManager: Failed to create continuous player: \(error)")
            isContinuousHapticActive = false
        }
    }
    
    /// Apply dynamic parameters based on frequency magnitudes
    private func applyDynamicParameters(from magnitudes: [Float]) {
        guard let player = continuousPlayer, !magnitudes.isEmpty else { return }
        
        // Analyze frequency bands to determine haptic characteristics
        // Low frequencies (bass) → low sharpness (rumble)
        // High frequencies → high sharpness (crisp taps)
        
        let bandCount = magnitudes.count
        let lowBandEnd = bandCount / 4          // Bottom 25% = bass
        let midBandEnd = bandCount * 3 / 4      // Middle 50% = mids
        // Top 25% = highs
        
        // Calculate average magnitude for each frequency range
        let lowMagnitude = averageMagnitude(magnitudes, from: 0, to: lowBandEnd)
        let midMagnitude = averageMagnitude(magnitudes, from: lowBandEnd, to: midBandEnd)
        let highMagnitude = averageMagnitude(magnitudes, from: midBandEnd, to: bandCount)
        
        // Overall intensity based on total energy
        let overallIntensity = (lowMagnitude * 0.5 + midMagnitude * 0.3 + highMagnitude * 0.2)
        
        // Sharpness based on frequency balance
        // More high frequencies = sharper haptics
        // More low frequencies = deeper rumble
        let frequencyBalance = (highMagnitude * 0.6 + midMagnitude * 0.3) / max(lowMagnitude + midMagnitude + highMagnitude, 0.001)
        let sharpness = min(1.0, max(0.1, frequencyBalance))
        
        // Scale intensity to feel good (not too weak, not overwhelming)
        let scaledIntensity = min(1.0, max(0.1, overallIntensity * 1.5))
        
        do {
            // Create dynamic parameters to update the continuous haptic
            let intensityParam = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: scaledIntensity,
                relativeTime: 0
            )
            
            let sharpnessParam = CHHapticDynamicParameter(
                parameterID: .hapticSharpnessControl,
                value: sharpness,
                relativeTime: 0
            )
            
            try player.sendParameters([intensityParam, sharpnessParam], atTime: CHHapticTimeImmediate)
            
        } catch {
            // Silently fail - this happens frequently and shouldn't spam logs
        }
    }
    
    /// Calculate average magnitude for a range of frequency bands
    private func averageMagnitude(_ magnitudes: [Float], from start: Int, to end: Int) -> Float {
        guard start < end, end <= magnitudes.count else { return 0 }
        
        var sum: Float = 0
        for i in start..<end {
            sum += magnitudes[i]
        }
        return sum / Float(end - start)
    }
    
    // MARK: - One-Shot Haptic Patterns (for UI feedback)
    
    /// Play when user selects the correct answer — satisfying confirmation
    func playCorrectAnswerHaptic() {
        guard supportsHaptics else { return }
        
        hapticQueue.async { [weak self] in
            self?.ensureEngineRunning()
            
            var events: [CHHapticEvent] = []
            
            // Rising success pattern: two quick taps followed by a satisfying thud
            let taps: [(time: TimeInterval, intensity: Float, sharpness: Float)] = [
                (0.0, 0.5, 0.6),
                (0.08, 0.6, 0.7),
                (0.2, 0.9, 0.4)  // Final satisfying confirmation
            ]
            
            for tap in taps {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: tap.intensity)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: tap.sharpness)
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: tap.time
                )
                events.append(event)
            }
            
            self?.playPattern(events: events)
        }
    }
    
    /// Play when user selects wrong answer — gentle rejection
    func playWrongAnswerHaptic() {
        guard supportsHaptics else { return }
        
        hapticQueue.async { [weak self] in
            self?.ensureEngineRunning()
            
            var events: [CHHapticEvent] = []
            
            for i in 0..<2 {
                let time = Double(i) * 0.12
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: time
                )
                events.append(event)
            }
            
            self?.playPattern(events: events)
        }
    }
    
    /// Play when a badge is earned — celebratory pattern
    func playBadgeEarnedHaptic() {
        guard supportsHaptics else { return }
        
        hapticQueue.async { [weak self] in
            self?.ensureEngineRunning()
            
            var events: [CHHapticEvent] = []
            
            let celebration: [(time: TimeInterval, intensity: Float, sharpness: Float)] = [
                (0.0, 0.4, 0.3),
                (0.1, 0.5, 0.4),
                (0.2, 0.6, 0.5),
                (0.3, 0.75, 0.6),
                (0.45, 1.0, 0.8)
            ]
            
            for note in celebration {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: note.intensity)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: note.sharpness)
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: note.time
                )
                events.append(event)
            }
            
            self?.playPattern(events: events)
        }
    }
    
    /// Play a light tap for button presses and selections
    func playSelectionHaptic() {
        guard supportsHaptics else { return }
        
        hapticQueue.async { [weak self] in
            self?.ensureEngineRunning()
            
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: 0
            )
            
            self?.playPattern(events: [event])
        }
    }
    
    // MARK: - Legacy method (for backward compatibility)
    
    /// Play haptic pattern for a specific animal sound - now starts continuous haptics
    func playAnimalHaptic(for animalId: String) {
        // Start continuous haptics - actual feedback comes from frequency data
        startContinuousHaptic()
    }
    
    // MARK: - Pattern Playback
    
    private func playPattern(events: [CHHapticEvent]) {
        guard let engine = engine, supportsHaptics else { return }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("HapticManager: Failed to play pattern: \(error)")
        }
    }
    
    // MARK: - Stop All Haptics
    
    func stopAllHaptics() {
        stopContinuousHaptic()
    }
}
