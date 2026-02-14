//
//  Theme.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 14/02/26.
//

// Design system: colors, typography, animations, and spacing.

import SwiftUI

extension Color {
    static let pantanalDeep = Color(red: 13/255, green: 26/255, blue: 20/255)
    static let pantanalDark = Color(red: 21/255, green: 46/255, blue: 32/255)
    static let pantanalMid = Color(red: 30/255, green: 80/255, blue: 56/255)
    static let pantanalWater = Color(red: 26/255, green: 122/255, blue: 90/255)
    static let pantanalLight = Color(red: 58/255, green: 173/255, blue: 114/255)
    static let pantanalBright = Color(red: 92/255, green: 200/255, blue: 138/255)
    
    static let pantanalGold = Color(red: 234/255, green: 188/255, blue: 82/255)
    static let pantanalAmber = Color(red: 212/255, green: 144/255, blue: 58/255)
    static let pantanalDawn = Color(red: 240/255, green: 200/255, blue: 98/255)
    
    static let specRed = Color(red: 239/255, green: 85/255, blue: 64/255)
    static let specOrange = Color(red: 232/255, green: 148/255, blue: 42/255)
    static let specYellow = Color(red: 232/255, green: 200/255, blue: 58/255)
    
    static let textPrimary = Color.white.opacity(0.92)
    static let textSecondary = Color.white.opacity(0.55)
    static let textMuted = Color.white.opacity(0.30)
    
    static let recordingRed = Color(red: 239/255, green: 68/255, blue: 68/255)
    static let pureBlack = Color.black
    static let dawnSkyDark = Color(red: 14/255, green: 30/255, blue: 40/255)
}

extension Font {
    static func pantanalTitle(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    
    static func pantanalHeading(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    
    static func pantanalSubheading(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    
    static func pantanalBody(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .light, design: .default)
    }
    
    static func pantanalUI(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func pantanalSmall(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .light, design: .default)
    }
    
    static func pantanalCaption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func pantanalMono(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
    
    static func pantanalLabel(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}

extension View {
    func accentLabelStyle() -> some View {
        self
            .font(.pantanalLabel())
            .foregroundStyle(Color.pantanalGold)
            .textCase(.uppercase)
            .tracking(2)
    }
    
    func secondaryTextStyle() -> some View {
        self
            .font(.pantanalSmall())
            .foregroundStyle(Color.textSecondary)
    }
    
    func mutedHintStyle() -> some View {
        self
            .font(.pantanalCaption())
            .foregroundStyle(Color.textMuted)
            .textCase(.uppercase)
            .tracking(1.5)
    }
}

extension Animation {
    static let sceneTransition = Animation.easeInOut(duration: 0.9)
    static let slowReveal = Animation.easeInOut(duration: 3.0)
    static let breathingPulse = Animation.easeInOut(duration: 4.5)
    static let organicFloat = Animation.easeInOut(duration: 5.0)
    static let ringPulse = Animation.easeOut(duration: 2.5)
}

struct Timing {
    static let sceneCrossfade: Double = 0.9
    static let slowReveal: Double = 3.0
    static let breathingPulse: Double = 4.5
    static let ringPulse: Double = 2.5
    static let staggerDelay: Double = 0.35
}

struct Spacing {
    static let horizontal: CGFloat = 24
    static let horizontalLarge: CGFloat = 40
    static let vertical: CGFloat = 16
    static let verticalLarge: CGFloat = 32
    static let verticalXLarge: CGFloat = 48
}
