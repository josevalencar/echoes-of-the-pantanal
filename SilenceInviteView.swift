//
//  SilenceInviteView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Scene 1: Cinematic loading sequence — darkness invitation flowing into contextual transition.

import SwiftUI

enum SilencePhase {
    case darkness
    case entering
}

struct SilenceInviteView: View {
    let onComplete: () -> Void
    
    @State private var phase: SilencePhase = .darkness
    
    var body: some View {
        ZStack {
            Color.pantanalDeep
                .ignoresSafeArea()
            
            switch phase {
            case .darkness:
                DarknessPhaseView()
                    .transition(.opacity)
                    
            case .entering:
                EnteringPhaseView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.9), value: phase)
        .task {
            await runSequence()
        }
    }
    
    private func runSequence() async {
        try? await Task.sleep(for: .seconds(7))
        
        await MainActor.run {
            phase = .entering
        }
        
        try? await Task.sleep(for: .seconds(7))
        
        await MainActor.run {
            onComplete()
        }
    }
}

struct DarknessPhaseView: View {
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Close your eyes.\nNow, listen.")
                .font(.pantanalHeading(26))
                .italic()
                .foregroundStyle(.white)
                .opacity(textOpacity)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer()
        }
        .task {
            try? await Task.sleep(for: .seconds(1))
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 2.0)) {
                    textOpacity = 0.55
                }
            }
            
            // Start playing intro soundscape after 2 seconds (user reads text, closes eyes)
            try? await Task.sleep(for: .seconds(2))
            SoundPlayer.shared.play(soundFile: "intro", loop: true)
            
            try? await Task.sleep(for: .seconds(0.5))
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 1.5)) {
                    textOpacity = 0
                }
            }
        }
    }
}

struct EnteringPhaseView: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            SonarRingsView()
                .frame(width: 220, height: 220)
            
            VStack(spacing: 16) {
                Text("You are entering the Pantanal of Mato Grosso do Sul, Brazil.")
                    .font(.pantanalSubheading(18))
                    .italic()
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                Text("Every sound tells a story.")
                    .font(.pantanalSubheading(18))
                    .italic()
                    .foregroundStyle(Color.textSecondary)
                    .padding(.top, 4)
                
                RecordingBadge()
                    .padding(.top, 8)
            }
            .padding(.horizontal, 50)
            .frame(maxWidth: 400)
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isVisible = true
            }
        }
    }
}

struct SonarRingsView: View {
    var body: some View {
        ZStack {
            SonarRing(size: 50, delay: 0, color: .pantanalLight.opacity(0.2))
            SonarRing(size: 100, delay: 0.35, color: .pantanalGold.opacity(0.15))
            SonarRing(size: 150, delay: 0.7, color: .pantanalGold.opacity(0.08))
            SonarRing(size: 200, delay: 1.0, color: .pantanalGold.opacity(0.04))
            
            Circle()
                .fill(Color.pantanalGold)
                .frame(width: 12, height: 12)
                .opacity(0.6)
        }
    }
}

struct SonarRing: View {
    let size: CGFloat
    let delay: Double
    let color: Color
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .strokeBorder(color, lineWidth: 1.5)
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.25 : 0.85)
            .opacity(isAnimating ? 0 : 0.5)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 3)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

struct RecordingBadge: View {
    @State private var isBlinking = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.specRed)
                .frame(width: 7, height: 7)
                .opacity(isBlinking ? 0.3 : 1.0)
            
            Text("REAL FIELD RECORDINGS")
                .font(.pantanalCaption(10))
                .fontWeight(.medium)
                .foregroundStyle(Color.specRed.opacity(0.6))
                .tracking(1.5)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.specRed.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.specRed.opacity(0.12), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
            ) {
                isBlinking = true
            }
        }
    }
}

#Preview {
    SilenceInviteView(onComplete: {})
}

