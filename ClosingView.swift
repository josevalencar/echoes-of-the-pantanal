//
//  ClosingView.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/12/2025.
//

// Scene 8: Closing scene with conservation message and credits.

import SwiftUI

struct ClosingView: View {
    @State private var isVisible = false
    @State private var badgesVisible = false
    @State private var quoteVisible = false
    
    private let completedAnimals: [Animal] = [.harpyEagle, .scarletMacaw, .jabiru, .jaguar]
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    badgesRow
                        .opacity(badgesVisible ? 1 : 0)
                        .offset(y: badgesVisible ? 0 : 20)
                    
                    titleSection
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 15)
                    
                    statsSection
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 15)
                    
                    conservationMessage
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 15)
                    
                    quoteSection
                        .opacity(quoteVisible ? 1 : 0)
                        .offset(y: quoteVisible ? 0 : 10)
                    
                    creditsSection
                        .opacity(quoteVisible ? 1 : 0)
                }
                .padding(.horizontal, 32)
                .padding(.top, 60)
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            animateEntrance()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.pantanalDeep,
                    Color(red: 12/255, green: 28/255, blue: 18/255),
                    Color.pantanalDark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Subtle ambient glow
            RadialGradient(
                colors: [
                    Color.pantanalGold.opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Badges Row
    
    private var badgesRow: some View {
        HStack(spacing: 12) {
            ForEach(completedAnimals) { animal in
                CompletionBadge(imageName: animal.imageName)
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("EXPERIENCE COMPLETE")
                .font(.pantanalLabel(10))
                .foregroundStyle(Color.pantanalGold)
                .tracking(3)
            
            Text("You heard the Pantanal.")
                .font(.pantanalTitle(32))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 24) {
            StatItem(value: "4", label: "Species")
            
            Divider()
                .frame(height: 30)
                .background(Color.white.opacity(0.1))
            
            StatItem(value: "4", label: "Sounds")
            
            Divider()
                .frame(height: 30)
                .background(Color.white.opacity(0.1))
            
            StatItem(value: "100%", label: "Identified")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - Conservation Message
    
    private var conservationMessage: some View {
        VStack(spacing: 16) {
            Text("The Pantanal is the world's largest tropical wetland — home to extraordinary biodiversity.")
                .font(.pantanalBody(15))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
            
            HStack(spacing: 20) {
                BiodiversityStat(number: "2,000+", label: "Plant species")
                BiodiversityStat(number: "580", label: "Bird species")
                BiodiversityStat(number: "270", label: "Fish species")
            }
            
            Text("But deforestation, wildfires, and human noise pollution threaten this acoustic paradise. Each year, thousands of hectares are lost — and with them, the voices of countless species.")
                .font(.pantanalSmall(13))
                .foregroundStyle(Color.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.top, 4)
        }
        .padding(20)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Quote Section
    
    private var quoteSection: some View {
        VStack(spacing: 12) {
            Text("\u{201C}")
                .font(.system(size: 40, weight: .light, design: .serif))
                .foregroundStyle(Color.pantanalGold.opacity(0.4))
            
            Text("When the last sound goes silent,\nit will be too late to listen.")
                .font(.pantanalHeading(18))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .italic()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Credits Section
    
    private var creditsSection: some View {
        VStack(spacing: 16) {
            Divider()
                .background(Color.white.opacity(0.08))
                .padding(.horizontal, 40)
            
            VStack(spacing: 6) {
                Text("Echoes of the Pantanal")
                    .font(.pantanalUI(13))
                    .foregroundStyle(Color.textSecondary)
                
                Text("SAUÁ ENVIRONMENTAL CONSULTING")
                    .font(.pantanalLabel(9))
                    .foregroundStyle(Color.textMuted)
                    .tracking(2)
            }
            
            Text("Swift Student Challenge 2026")
                .font(.pantanalMono(9))
                .foregroundStyle(Color.textMuted.opacity(0.6))
        }
        .padding(.top, 12)
    }
    
    // MARK: - Animation
    
    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            badgesVisible = true
        }
        
        withAnimation(.easeOut(duration: 0.7).delay(0.5)) {
            isVisible = true
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(1.2)) {
            quoteVisible = true
        }
    }
}

// MARK: - Supporting Views

struct CompletionBadge: View {
    let imageName: String?
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.pantanalGold.opacity(0.12))
                .frame(width: 52, height: 52)
            
            Circle()
                .strokeBorder(Color.pantanalGold.opacity(0.5), lineWidth: 2)
                .frame(width: 52, height: 52)
            
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }
        }
        .shadow(color: Color.pantanalGold.opacity(0.2), radius: 8)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.pantanalHeading(20))
                .foregroundStyle(Color.pantanalGold)
            
            Text(label)
                .font(.pantanalMono(9))
                .foregroundStyle(Color.textMuted)
        }
    }
}

struct BiodiversityStat: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.pantanalUI(15))
                .foregroundStyle(Color.pantanalLight)
            
            Text(label)
                .font(.pantanalMono(8))
                .foregroundStyle(Color.textMuted)
        }
    }
}

#Preview {
    ClosingView()
}
