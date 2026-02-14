//
//  AppScene.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Defines the app's scene flow and navigation state.

import SwiftUI

enum AppScene: Int, CaseIterable, Identifiable {
    case setup = 0
    case silenceInvite = 1
    case dawn = 2
    case bioacousticsEducation = 3
    case roundHarpyEagle = 4
    case roundHowlerMonkey = 5
    case roundJabiru = 6
    case roundJaguar = 7
    case closing = 8
    
    var id: Int { rawValue }
    
    var next: AppScene? {
        AppScene(rawValue: rawValue + 1)
    }
    
    var previous: AppScene? {
        guard rawValue > 0 else { return nil }
        return AppScene(rawValue: rawValue - 1)
    }
    
    var isGameRound: Bool {
        switch self {
        case .roundHarpyEagle, .roundHowlerMonkey, .roundJabiru, .roundJaguar:
            true
        default:
            false
        }
    }
    
    var roundNumber: Int? {
        switch self {
        case .roundHarpyEagle: 1
        case .roundHowlerMonkey: 2
        case .roundJabiru: 3
        case .roundJaguar: 4
        default: nil
        }
    }
    
    static let totalRounds = 4
}

enum SceneTransitionDirection {
    case forward
    case backward
}
