//
//  Round.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/12/2025.
//

// Game round configuration with challenge types and answer options.

import SwiftUI

struct GameRound: Identifiable {
    let id: Int
    let correctAnimal: Animal
    let challengeType: ChallengeType
    let options: [Animal]
    
    enum ChallengeType {
        case soundToName    // Hear sound, pick the animal name
        case soundToImage   // Hear sound, pick the animal image/emoji
        case imageToSound   // See image, pick which sound belongs to it
        
        var instruction: String {
            switch self {
            case .soundToName:
                return "Listen to the sound and identify the animal"
            case .soundToImage:
                return "Listen to the sound and find the animal"
            case .imageToSound:
                return "Which sound does this animal make?"
            }
        }
        
        var badge: String {
            switch self {
            case .soundToName: return "SOUND → NAME"
            case .soundToImage: return "SOUND → IMAGE"
            case .imageToSound: return "IMAGE → SOUND"
            }
        }
    }
}

// MARK: - Game Configuration

extension GameRound {
    /// All four game rounds as defined in CLAUDE.md
    static let allRounds: [GameRound] = [
        // Round 1: Harpy Eagle - Sound → Name
        GameRound(
            id: 1,
            correctAnimal: .harpyEagle,
            challengeType: .soundToName,
            options: [.harpyEagle, .toucan, .macaw, .jabiru].shuffled()
        ),
        
        // Round 2: Howler Monkey - Sound → Image
        GameRound(
            id: 2,
            correctAnimal: .howlerMonkey,
            challengeType: .soundToImage,
            options: [.howlerMonkey, .capybara, .giantOtter, .tapir].shuffled()
        ),
        
        // Round 3: Jabiru - Image → Sound
        GameRound(
            id: 3,
            correctAnimal: .jabiru,
            challengeType: .imageToSound,
            options: [.jabiru, .rhea, .harpyEagle, .toucan].shuffled()
        ),
        
        // Round 4: Jaguar - Sound → Name
        GameRound(
            id: 4,
            correctAnimal: .jaguar,
            challengeType: .soundToName,
            options: [.jaguar, .caiman, .anaconda, .tapir].shuffled()
        )
    ]
    
    static func round(for number: Int) -> GameRound? {
        allRounds.first { $0.id == number }
    }
}

// MARK: - Progress Tracking

struct GameProgress {
    var completedRounds: Set<Int> = []
    var currentRoundIndex: Int = 0
    
    var currentRound: GameRound? {
        guard currentRoundIndex < GameRound.allRounds.count else { return nil }
        return GameRound.allRounds[currentRoundIndex]
    }
    
    var isComplete: Bool {
        completedRounds.count == GameRound.allRounds.count
    }
    
    var completedAnimals: [Animal] {
        completedRounds.compactMap { roundId in
            GameRound.round(for: roundId)?.correctAnimal
        }
    }
    
    mutating func completeCurrentRound() {
        if let current = currentRound {
            completedRounds.insert(current.id)
        }
    }
    
    mutating func advanceToNextRound() {
        currentRoundIndex += 1
    }
}
