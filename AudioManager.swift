//
//  AudioManager.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/02/26.
//

// Audio engine for microphone input capture and FFT frequency analysis.

import AVFoundation
import Accelerate
import Combine

final class AudioManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioManager()

    @Published private(set) var frequencyMagnitudes: [Float] = Array(repeating: 0, count: 64)
    @Published private(set) var isRecording = false

    private var audioEngine: AVAudioEngine?
    private var fftSetup: vDSP_DFT_Setup?

    private let fftSize = 1024
    private let outputBands = 64
    private let processingQueue = DispatchQueue(label: "com.pantanal.audio.processing")

    private init() {
        fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            vDSP_Length(fftSize),
            .FORWARD
        )
    }

    func startRecording() {
        guard !isRecording else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)

            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            inputNode.installTap(onBus: 0, bufferSize: UInt32(fftSize), format: format) { [weak self] buffer, _ in
                self?.processingQueue.async {
                    self?.processAudioBuffer(buffer)
                }
            }

            try engine.start()
            audioEngine = engine
            DispatchQueue.main.async {
                self.isRecording = true
            }
        } catch {
            print("AudioManager: Failed to start recording - \(error)")
        }
    }

    func stopRecording() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        DispatchQueue.main.async {
            self.isRecording = false
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

        DispatchQueue.main.async { [weak self] in
            self?.frequencyMagnitudes = bandMagnitudes
        }
    }
}
