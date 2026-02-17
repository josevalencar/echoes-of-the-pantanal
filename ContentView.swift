//
//  ContentView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Scene router with 0.9-second opacity crossfade transitions.

import SwiftUI

struct ContentView: View {
    @State private var currentScene: AppScene = .setup
    @State private var completedRounds: Set<Int> = []
    
    var body: some View {
        ZStack {
            Color.pantanalDeep
                .ignoresSafeArea()
            
            sceneContent
                .transition(.opacity)
                .id(currentScene)
        }
        .animation(.sceneTransition, value: currentScene)
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var sceneContent: some View {
        switch currentScene {
        case .setup:
            SetupView(onComplete: advanceToNextScene)
            
        case .silenceInvite:
            SilenceInviteView(onComplete: advanceToNextScene)
            
        case .dawn:
            DawnView(onBegin: advanceToNextScene)
            
        case .bioacousticsEducation:
            BioacousticsEduView(onContinue: advanceToNextScene)
            
        case .roundHarpyEagle:
            if let round = GameRound.round(for: 1) {
                RoundView(
                    round: round,
                    completedRounds: completedRounds,
                    onCorrectAnswer: { completeRoundAndAdvance(1) }
                )
            }
            
        case .roundHowlerMonkey:
            if let round = GameRound.round(for: 2) {
                RoundView(
                    round: round,
                    completedRounds: completedRounds,
                    onCorrectAnswer: { completeRoundAndAdvance(2) }
                )
            }
            
        case .roundJabiru:
            if let round = GameRound.round(for: 3) {
                RoundView(
                    round: round,
                    completedRounds: completedRounds,
                    onCorrectAnswer: { completeRoundAndAdvance(3) }
                )
            }
            
        case .roundJaguar:
            if let round = GameRound.round(for: 4) {
                RoundView(
                    round: round,
                    completedRounds: completedRounds,
                    onCorrectAnswer: { completeRoundAndAdvance(4) }
                )
            }
            
        case .closing:
            ClosingView()
        }
    }
    
    private func advanceToNextScene() {
        guard let nextScene = currentScene.next else { return }
        currentScene = nextScene
    }
    
    private func completeRoundAndAdvance(_ roundNumber: Int) {
        completedRounds.insert(roundNumber)
        advanceToNextScene()
    }
    
    private func goToPreviousScene() {
        guard let previousScene = currentScene.previous else { return }
        currentScene = previousScene
    }
    
    private func goToScene(_ scene: AppScene) {
        currentScene = scene
    }
}

#Preview {
    ContentView()
}
