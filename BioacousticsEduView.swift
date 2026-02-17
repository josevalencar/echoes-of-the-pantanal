//
//  BioacousticsEduView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/02/26.
//

// Scene 3: Education screen teaching bioacoustics concepts before the interactive rounds.

import SwiftUI

struct BioacousticsEduView: View {
    let onContinue: () -> Void

    @State private var isVisible = false

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    headerSection

                    descriptionSection

                    RecorderDevice()

                    factsSection

                    continueButton
                }
                .padding(.horizontal, 32)
                .padding(.top, 40)
                .padding(.bottom, 30)
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isVisible = true
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.pantanalDeep,
                Color(red: 15/255, green: 42/255, blue: 28/255),
                Color.pantanalDark
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("BIOACOUSTICS")
                .font(.pantanalLabel(10))
                .foregroundStyle(Color.pantanalGold)
                .tracking(3)

            Text("The sounds that keep\nthe Pantanal alive")
                .font(.pantanalHeading(30))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    private var descriptionSection: some View {
        Text("Bioacoustics is the science that studies sounds of living beings and their environments. Researchers use recorders and spectrograms to monitor biodiversity — each species has a unique \"sound signature.\"")
            .font(.pantanalSmall(13))
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 10)
    }

    private var factsSection: some View {
        VStack(spacing: 10) {
            FactCard(
                emoji: "🎙",
                title: "Field Recorders",
                description: "Capture frequencies from bat ultrasound to jaguar infrasound that our ears cannot perceive.",
                tintColor: .pantanalLight
            )

            FactCard(
                emoji: "📊",
                title: "Spectrograms",
                description: "Turn sound into image. Warm colors mean high volume. Each frequency band reveals a species.",
                tintColor: .pantanalGold
            )

            FactCard(
                emoji: "🧠",
                title: "Natural Soundscapes",
                description: "Reduce cortisol and improve focus. Nature's \"silence\" is actually a concert of life.",
                tintColor: Color(red: 26/255, green: 153/255, blue: 214/255)
            )
        }
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            HStack(spacing: 8) {
                Text("Explore the Sounds")
                    .font(.pantanalUI(15))
                    .fontWeight(.medium)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(glassBackground)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 50)
                .fill(.ultraThinMaterial)
                .glassEffect()
        } else {
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.14), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                )
        }
    }
}

struct FactCard: View {
    let emoji: String
    let title: String
    let description: String
    let tintColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 16))
                .frame(width: 36, height: 36)
                .background(tintColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.pantanalUI(12))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Text(description)
                    .font(.pantanalSmall(11))
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.04), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    BioacousticsEduView(onContinue: {})
}
