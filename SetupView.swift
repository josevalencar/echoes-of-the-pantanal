//
//  SetupView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Scene 0: Microphone permission request and headphones recommendation.

import SwiftUI
import AVFAudio

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
        Task { @MainActor in
            if #available(iOS 17.0, *) {
                // Use the modern async API from AVAudioApplication (iOS 17+)
                // This avoids the threading issues with the old completion handler API
                _ = await AVAudioApplication.requestRecordPermission()
            } else {
                // Fallback for iOS 16: use the old API but handle threading carefully
                await withCheckedContinuation { continuation in
                    AVAudioSession.sharedInstance().requestRecordPermission { _ in
                        continuation.resume()
                    }
                }
            }
            advanceToHeadphones()
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
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var maxContentWidth: CGFloat { isRegularWidth ? 520 : 420 }
    private var horizontalPadding: CGFloat { isRegularWidth ? 40 : 50 }
    private var verticalSpacing: CGFloat { isRegularWidth ? 32 : 24 }
    private var headingSize: CGFloat { isRegularWidth ? 34 : 28 }
    private var bodySize: CGFloat { isRegularWidth ? 17 : 15 }  // HIG: 17pt body text
    private var iconSize: CGFloat { isRegularWidth ? 100 : 88 }
    private var iconFontSize: CGFloat { isRegularWidth ? 42 : 36 }
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            microphoneIcon
            
            Text("Allow Microphone Access?")
                .font(.pantanalHeading(headingSize))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Echoes of the Pantanal uses your microphone to analyze environmental sounds in real time and create live spectrograms of your surroundings.")
                .font(.pantanalSmall(bodySize))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(isRegularWidth ? 6 : 4)
            
            VStack(spacing: isRegularWidth ? 14 : 10) {
                GlassButton(
                    title: "Allow Microphone",
                    tint: .gold,
                    isRegularWidth: isRegularWidth,
                    action: onAllow
                )
                
                Button(action: onSkip) {
                    Text("Not now")
                        .font(.pantanalCaption(isRegularWidth ? 15 : 13))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.top, isRegularWidth ? 12 : 8)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: maxContentWidth)
    }
    
    private var microphoneIcon: some View {
        RoundedRectangle(cornerRadius: isRegularWidth ? 28 : 24)
            .fill(Color.pantanalGold.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: isRegularWidth ? 28 : 24)
                    .strokeBorder(Color.pantanalGold.opacity(0.15), lineWidth: 1)
            )
            .frame(width: iconSize, height: iconSize)
            .overlay(
                Image(systemName: "mic.fill")
                    .font(.system(size: iconFontSize, weight: .light))
                    .foregroundStyle(Color.pantanalGold.opacity(0.7))
            )
    }
}

struct HeadphonesRecommendationCard: View {
    let onReady: () -> Void
    let onSkip: () -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var maxContentWidth: CGFloat { isRegularWidth ? 520 : 420 }
    private var horizontalPadding: CGFloat { isRegularWidth ? 40 : 50 }
    private var verticalSpacing: CGFloat { isRegularWidth ? 32 : 24 }
    private var headingSize: CGFloat { isRegularWidth ? 34 : 28 }
    private var bodySize: CGFloat { isRegularWidth ? 17 : 15 }  // HIG: 17pt body text
    private var circleSize: CGFloat { isRegularWidth ? 140 : 120 }
    private var visualFrameSize: CGFloat { isRegularWidth ? 180 : 160 }
    private var headphoneIconSize: CGFloat { isRegularWidth ? 48 : 40 }
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            headphonesVisual
            
            Text("For the best experience,\nuse headphones")
                .font(.pantanalHeading(headingSize))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(isRegularWidth ? 6 : 4)
            
            Text("This is an immersive bioacoustics experience. Headphones will help you perceive spatial direction, subtle frequencies, and feel the sounds of the Pantanal as researchers do in the field.")
                .font(.pantanalSmall(bodySize))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(isRegularWidth ? 6 : 4)
            
            VStack(spacing: isRegularWidth ? 14 : 10) {
                GlassButton(
                    title: "I'm ready",
                    tint: .green,
                    isRegularWidth: isRegularWidth,
                    action: onReady
                )
                
                Button(action: onSkip) {
                    Text("Continue without headphones")
                        .font(.pantanalCaption(isRegularWidth ? 15 : 13))
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.top, isRegularWidth ? 12 : 8)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: maxContentWidth)
    }
    
    private var headphonesVisual: some View {
        ZStack {
            PulsingRing(delay: 0, size: visualFrameSize)
            PulsingRing(delay: 0.8, size: visualFrameSize)
            
            Circle()
                .fill(Color.pantanalLight.opacity(0.06))
                .overlay(
                    Circle()
                        .strokeBorder(Color.pantanalLight.opacity(0.12), lineWidth: 1)
                )
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Image(systemName: "headphones")
                        .font(.system(size: headphoneIconSize, weight: .light))
                        .foregroundStyle(Color.pantanalLight.opacity(0.7))
                )
        }
        .frame(width: visualFrameSize, height: visualFrameSize)
    }
}

struct PulsingRing: View {
    let delay: Double
    var size: CGFloat = 160
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .strokeBorder(Color.pantanalLight.opacity(0.1), lineWidth: 1)
            .frame(width: size, height: size)
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
    var isRegularWidth: Bool = false
    let action: () -> Void
    
    private var fontSize: CGFloat { isRegularWidth ? 17 : 15 }
    private var verticalPadding: CGFloat { isRegularWidth ? 18 : 16 }
    private var horizontalPadding: CGFloat { isRegularWidth ? 40 : 32 }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.pantanalUI(fontSize))
                .fontWeight(.medium)
                .tracking(0.5)
                .foregroundStyle(tint.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
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
