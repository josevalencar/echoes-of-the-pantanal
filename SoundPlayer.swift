//
//  SoundPlayer.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/12/2025.
//

// Audio playback manager for bundled animal sounds with FFT analysis.

import AVFoundation
import Accelerate

final class SoundPlayer: ObservableObject, @unchecked Sendable {
    static let shared = SoundPlayer()
    
    @Published private(set) var isPlaying = false
    @Published private(set) var frequencyMagnitudes: [Float] = Array(repeating: 0, count: 64)
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
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
    
    func play(soundFile: String) {
        stop()
        
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "m4a") else {
            print("SoundPlayer: Could not find sound file: \(soundFile).m4a")
            return
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            let file = try AVAudioFile(forReading: url)
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
            
            player.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    self?.handlePlaybackComplete()
                }
            }
            
            player.play()
            
            audioEngine = engine
            playerNode = player
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
            
        } catch {
            print("SoundPlayer: Failed to play sound - \(error)")
        }
    }
    
    func stop() {
        playerNode?.stop()
        audioEngine?.mainMixerNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        audioFile = nil
        
        DispatchQueue.main.async {
            self.isPlaying = false
            self.frequencyMagnitudes = Array(repeating: 0, count: self.outputBands)
        }
    }
    
    func replay() {
        guard let file = audioFile, let player = playerNode, let engine = audioEngine else {
            return
        }
        
        player.stop()
        player.scheduleFile(file, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.handlePlaybackComplete()
            }
        }
        player.play()
        
        DispatchQueue.main.async {
            self.isPlaying = true
        }
    }
    
    private func handlePlaybackComplete() {
        isPlaying = false
        frequencyMagnitudes = Array(repeating: 0, count: outputBands)
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
        
        DispatchQueue.main.async { [weak self] in
            self?.frequencyMagnitudes = bandMagnitudes
        }
    }
}
