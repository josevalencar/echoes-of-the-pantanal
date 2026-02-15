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
            PlaceholderSceneView(
                sceneName: "Bioacoustics Education",
                sceneNumber: 3,
                description: "What is bioacoustics?",
                onNext: advanceToNextScene
            )
            
        case .roundHarpyEagle:
            PlaceholderSceneView(
                sceneName: "Round 1: Harpy Eagle",
                sceneNumber: 4,
                description: "Sound → Name",
                onNext: advanceToNextScene
            )
            
        case .roundHowlerMonkey:
            PlaceholderSceneView(
                sceneName: "Round 2: Howler Monkey",
                sceneNumber: 5,
                description: "Sound → Image",
                onNext: advanceToNextScene
            )
            
        case .roundJabiru:
            PlaceholderSceneView(
                sceneName: "Round 3: Jabiru",
                sceneNumber: 6,
                description: "Image → Sound",
                onNext: advanceToNextScene
            )
            
        case .roundJaguar:
            PlaceholderSceneView(
                sceneName: "Round 4: Jaguar",
                sceneNumber: 7,
                description: "Sound → Name",
                onNext: advanceToNextScene
            )
            
        case .closing:
            PlaceholderSceneView(
                sceneName: "Closing",
                sceneNumber: 8,
                description: "Conservation message & credits",
                onNext: nil
            )
        }
    }
    
    private func advanceToNextScene() {
        guard let nextScene = currentScene.next else { return }
        currentScene = nextScene
    }
    
    private func goToPreviousScene() {
        guard let previousScene = currentScene.previous else { return }
        currentScene = previousScene
    }
    
    private func goToScene(_ scene: AppScene) {
        currentScene = scene
    }
}

struct PlaceholderSceneView: View {
    let sceneName: String
    let sceneNumber: Int
    let description: String
    let onNext: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.verticalLarge) {
            Spacer()
            
            Text("SCENE \(sceneNumber)")
                .accentLabelStyle()
            
            Text(sceneName)
                .font(.pantanalTitle())
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.pantanalBody())
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            if let onNext {
                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Next Scene")
                            .font(.pantanalUI())
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(Color.pantanalGold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.pantanalGold.opacity(0.15))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.pantanalGold.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, Spacing.verticalXLarge)
            } else {
                Text("End of Experience")
                    .mutedHintStyle()
                    .padding(.bottom, Spacing.verticalXLarge)
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}

#Preview {
    ContentView()
}
