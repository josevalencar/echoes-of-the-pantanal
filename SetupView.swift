//
//  SetupView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Scene 0: Microphone permission request and headphones recommendation.

import SwiftUI
import AVFoundation

enum SetupStep {
    case microphone
    case headphones
}

struct SetupView: View {
    let onComplete: () -> Void
    
    @State private var currentStep: SetupStep = .microphone
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            Color.pantanalDeep
                .ignoresSafeArea()
            
            Group {
                switch currentStep {
                case .microphone:
                    MicrophonePermissionCard(
                        onAllow: requestMicrophoneAccess,
                        onSkip: advanceToHeadphones
                    )
                    .transition(.opacity)
                    
                case .headphones:
                    HeadphonesRecommendationCard(
                        onReady: onComplete,
                        onSkip: onComplete
                    )
                    .transition(.opacity)
                }
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
        }
        .animation(.easeOut(duration: 0.8), value: currentStep)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                isVisible = true
            }
        }
    }
    
    private func requestMicrophoneAccess() {
        Task {
            await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { _ in
                    continuation.resume()
                }
            }
            await MainActor.run {
                advanceToHeadphones()
            }
        }
    }
    
    private func advanceToHeadphones() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isVisible = false
        }
        
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            await MainActor.run {
                currentStep = .headphones
                withAnimation(.easeOut(duration: 0.8)) {
                    isVisible = true
                }
            }
        }
    }
}

struct MicrophonePermissionCard: View {
    let onAllow: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            microphoneIcon
            
            Text("Allow Microphone Access?")
                .font(.pantanalHeading())
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Echoes of the Pantanal uses your microphone to analyze environmental sounds in real time and create live spectrograms of your surroundings.")
                .font(.pantanalSmall(14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            VStack(spacing: 10) {
                GlassButton(
                    title: "Allow Microphone",
                    tint: .gold,
                    action: onAllow
                )
                
                Button(action: onSkip) {
                    Text("Not now")
                        .font(.pantanalCaption())
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 50)
        .frame(maxWidth: 420)
    }
    
    private var microphoneIcon: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.pantanalGold.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color.pantanalGold.opacity(0.15), lineWidth: 1)
            )
            .frame(width: 88, height: 88)
            .overlay(
                Image(systemName: "mic.fill")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(Color.pantanalGold.opacity(0.7))
            )
    }
}

struct HeadphonesRecommendationCard: View {
    let onReady: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            headphonesVisual
            
            Text("For the best experience,\nuse headphones")
                .font(.pantanalHeading())
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Text("This is an immersive bioacoustics experience. Headphones will help you perceive spatial direction, subtle frequencies, and feel the sounds of the Pantanal as researchers do in the field.")
                .font(.pantanalSmall(14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            VStack(spacing: 10) {
                GlassButton(
                    title: "I'm ready",
                    tint: .green,
                    action: onReady
                )
                
                Button(action: onSkip) {
                    Text("Continue without headphones")
                        .font(.pantanalCaption())
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 50)
        .frame(maxWidth: 420)
    }
    
    private var headphonesVisual: some View {
        ZStack {
            PulsingRing(delay: 0)
            PulsingRing(delay: 0.8)
            
            Circle()
                .fill(Color.pantanalLight.opacity(0.06))
                .overlay(
                    Circle()
                        .strokeBorder(Color.pantanalLight.opacity(0.12), lineWidth: 1)
                )
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "headphones")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(Color.pantanalLight.opacity(0.7))
                )
        }
        .frame(width: 160, height: 160)
    }
}

struct PulsingRing: View {
    let delay: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .strokeBorder(Color.pantanalLight.opacity(0.1), lineWidth: 1)
            .frame(width: 160, height: 160)
            .scaleEffect(isAnimating ? 1.4 : 0.8)
            .opacity(isAnimating ? 0 : 0.5)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.5)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

enum GlassButtonTint {
    case gold
    case green
    
    var color: Color {
        switch self {
        case .gold: .pantanalGold
        case .green: .pantanalBright
        }
    }
}

struct GlassButton: View {
    let title: String
    let tint: GlassButtonTint
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.pantanalUI(15))
                .fontWeight(.medium)
                .tracking(0.5)
                .foregroundStyle(tint.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(glassBackground)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(.clear)
                .glassEffect(
                    .regular.tint(tint.color.opacity(0.15)).interactive(),
                    in: .capsule
                )
        } else {
            Capsule()
                .fill(tint.color.opacity(0.12))
                .overlay(
                    Capsule()
                        .strokeBorder(tint.color.opacity(0.25), lineWidth: 1)
                )
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.14), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 24)
                        .padding(.horizontal, 1)
                        .padding(.top, 1)
                }
        }
    }
}

#Preview {
    SetupView(onComplete: {})
}
