//
//  SoundPlayer.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 23/02/26.
//

// Audio playback manager for bundled animal sounds with FFT analysis.
// Integrates with HapticManager for synchronized tactile feedback.

import AVFoundation
import Accelerate

final class SoundPlayer: ObservableObject, @unchecked Sendable {
    static let shared = SoundPlayer()
    
    /// Playback state for UI
    enum PlaybackState {
        case playing
        case paused
        case ended
    }
    
    @Published private(set) var state: PlaybackState = .ended
    @Published private(set) var frequencyMagnitudes: [Float] = Array(repeating: 0, count: 64)
    
    /// Convenience computed properties
    var isPlaying: Bool { state == .playing }
    var isPaused: Bool { state == .paused }
    var hasEnded: Bool { state == .ended }
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    private var currentSoundFile: String?
    private var currentAnimalId: String?
    private var isLooping: Bool = false
    private var fftSetup: vDSP_DFT_Setup?
    
    private let fftSize = 1024
    private let outputBands = 64
    private let processingQueue = DispatchQueue(label: "com.pantanal.sound.processing")
    
    private init() {
        fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            vDSP_Length(fftSize),
            .FORWARD
        )
    }
    
    deinit {
        stop()
        if let setup = fftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }
    
    func play(soundFile: String, loop: Bool = false, animalId: String? = nil) {
        stop()
        
        currentSoundFile = soundFile
        isLooping = loop
        currentAnimalId = animalId
        
        // Try multiple locations for the sound file
        var url: URL?
        
        // First try: root of bundle
        url = Bundle.main.url(forResource: soundFile, withExtension: "m4a")
        
        // Second try: Sounds subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: soundFile, withExtension: "m4a", subdirectory: "Sounds")
        }
        
        // Third try: direct path construction for Swift Playgrounds
        if url == nil {
            if let bundlePath = Bundle.main.resourcePath {
                let directPath = URL(fileURLWithPath: bundlePath)
                    .appendingPathComponent("Sounds")
                    .appendingPathComponent("\(soundFile).m4a")
                if FileManager.default.fileExists(atPath: directPath.path) {
                    url = directPath
                }
            }
        }
        
        guard let soundURL = url else {
            print("SoundPlayer: Could not find sound file: \(soundFile).m4a")
            print("SoundPlayer: Bundle path: \(Bundle.main.resourcePath ?? "nil")")
            return
        }
        
        print("SoundPlayer: Playing \(soundURL.lastPathComponent)\(loop ? " (looping)" : "")")
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            let file = try AVAudioFile(forReading: soundURL)
            audioFile = file
            
            let engine = AVAudioEngine()
            let player = AVAudioPlayerNode()
            
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
            
            // Install tap for FFT analysis
            let format = engine.mainMixerNode.outputFormat(forBus: 0)
            engine.mainMixerNode.installTap(onBus: 0, bufferSize: UInt32(fftSize), format: format) { [weak self] buffer, _ in
                self?.processingQueue.async {
                    self?.processAudioBuffer(buffer)
                }
            }
            
            try engine.start()
            
            if loop {
                // For looping, read the entire file into a buffer and schedule with .loops option
                let frameCount = AVAudioFrameCount(file.length)
                guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
                    print("SoundPlayer: Failed to create buffer for looping")
                    return
                }
                try file.read(into: buffer)
                player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            } else {
                player.scheduleFile(file, at: nil) { [weak self] in
                    DispatchQueue.main.async {
                        self?.handlePlaybackComplete()
                    }
                }
            }
            
            player.play()
            
            audioEngine = engine
            playerNode = player
            state = .playing
            
            // Start continuous haptic feedback synchronized with audio playback
            HapticManager.shared.startContinuousHaptic()
            
        } catch {
            print("SoundPlayer: Failed to play sound - \(error)")
        }
    }
    
    /// Pause playback - can be resumed
    func pause() {
        guard state == .playing else { return }
        playerNode?.pause()
        state = .paused
    }
    
    /// Resume from paused state
    func resume() {
        guard state == .paused, playerNode != nil else { return }
        playerNode?.play()
        state = .playing
    }
    
    /// Stop playback completely (used when user gets correct answer)
    func stop() {
        playerNode?.stop()
        
        if let engine = audioEngine {
            engine.mainMixerNode.removeTap(onBus: 0)
            engine.stop()
        }
        
        // Stop haptic feedback
        HapticManager.shared.stopContinuousHaptic()
        
        audioEngine = nil
        playerNode = nil
        audioFile = nil
        // Keep currentSoundFile so replay can work
        
        state = .ended
        frequencyMagnitudes = Array(repeating: 0, count: outputBands)
    }
    
    /// Replay the sound from the beginning (clears spectrogram)
    func replay() {
        guard let soundFile = currentSoundFile else { return }
        play(soundFile: soundFile, animalId: currentAnimalId)
    }
    
    /// Handle button tap based on current state
    func handleButtonTap() {
        switch state {
        case .playing:
            pause()
        case .paused:
            resume()
        case .ended:
            replay()
        }
    }
    
    private func handlePlaybackComplete() {
        // Stop haptic feedback when audio ends
        HapticManager.shared.stopContinuousHaptic()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .ended
            self.frequencyMagnitudes = Array(repeating: 0, count: self.outputBands)
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0],
              let setup = fftSetup else { return }
        
        let frameCount = Int(buffer.frameLength)
        guard frameCount >= fftSize else { return }
        
        var realInput = [Float](repeating: 0, count: fftSize)
        var imagInput = [Float](repeating: 0, count: fftSize)
        var realOutput = [Float](repeating: 0, count: fftSize)
        var imagOutput = [Float](repeating: 0, count: fftSize)
        
        for i in 0..<fftSize {
            realInput[i] = channelData[i]
        }
        
        vDSP_DFT_Execute(setup, &realInput, &imagInput, &realOutput, &imagOutput)
        
        var magnitudes = [Float](repeating: 0, count: fftSize / 2)
        for i in 0..<(fftSize / 2) {
            magnitudes[i] = sqrt(realOutput[i] * realOutput[i] + imagOutput[i] * imagOutput[i])
        }
        
        let bandSize = (fftSize / 2) / outputBands
        var bandMagnitudes = [Float](repeating: 0, count: outputBands)
        
        for band in 0..<outputBands {
            let startIndex = band * bandSize
            let endIndex = min(startIndex + bandSize, fftSize / 2)
            var sum: Float = 0
            for i in startIndex..<endIndex {
                sum += magnitudes[i]
            }
            bandMagnitudes[band] = sum / Float(endIndex - startIndex)
        }
        
        var maxMagnitude: Float = 0
        vDSP_maxv(bandMagnitudes, 1, &maxMagnitude, vDSP_Length(outputBands))
        
        if maxMagnitude > 0 {
            var scale = 1.0 / maxMagnitude
            vDSP_vsmul(bandMagnitudes, 1, &scale, &bandMagnitudes, 1, vDSP_Length(outputBands))
        }
        
        // Feed frequency data to haptic manager for real-time audio-reactive haptics
        HapticManager.shared.updateWithFrequencyData(bandMagnitudes)
        
        DispatchQueue.main.async { [weak self] in
            self?.frequencyMagnitudes = bandMagnitudes
        }
    }
}
