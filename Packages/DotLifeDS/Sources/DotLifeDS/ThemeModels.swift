import Foundation
import SwiftUI
import UIKit

public enum ThemeColorScheme: String, CaseIterable, Identifiable {
    case light
    case dark

    public var id: String { rawValue }
}

public enum ThemeAppearanceOverride: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

public struct ThemeRGBA: Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static func fromHex(_ hex: String) -> ThemeRGBA {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard cleaned.count == 6 || cleaned.count == 8 else {
            return ThemeRGBA(red: 0, green: 0, blue: 0, alpha: 1)
        }

        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if cleaned.count == 8 {
            red = Double((value & 0xFF00_0000) >> 24) / 255.0
            green = Double((value & 0x00FF_0000) >> 16) / 255.0
            blue = Double((value & 0x0000_FF00) >> 8) / 255.0
            alpha = Double(value & 0x0000_00FF) / 255.0
        } else {
            red = Double((value & 0xFF00_00) >> 16) / 255.0
            green = Double((value & 0x00FF_00) >> 8) / 255.0
            blue = Double(value & 0x0000_FF) / 255.0
            alpha = 1
        }

        return ThemeRGBA(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public struct ThemeColor: Hashable {
    public let light: ThemeRGBA
    public let dark: ThemeRGBA

    public init(lightHex: String, darkHex: String) {
        self.light = ThemeRGBA.fromHex(lightHex)
        self.dark = ThemeRGBA.fromHex(darkHex)
    }

    public func color(for scheme: ThemeColorScheme) -> Color {
        let rgba = scheme == .light ? light : dark
        return Color(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }

    public func uiColor(for scheme: ThemeColorScheme) -> UIColor {
        let rgba = scheme == .light ? light : dark
        return UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}

public struct ThemePalette: Hashable {
    public let appBackground: ThemeColor
    public let surface: ThemeColor
    public let textPrimary: ThemeColor
    public let textSecondary: ThemeColor
    public let accent: ThemeColor
    public let dotBase: ThemeColor

    public init(
        appBackground: ThemeColor,
        surface: ThemeColor,
        textPrimary: ThemeColor,
        textSecondary: ThemeColor,
        accent: ThemeColor,
        dotBase: ThemeColor
    ) {
        self.appBackground = appBackground
        self.surface = surface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.accent = accent
        self.dotBase = dotBase
    }

    public func colors(for scheme: ThemeColorScheme) -> ThemeColors {
        ThemeColors(
            appBackground: appBackground.color(for: scheme),
            surface: surface.color(for: scheme),
            textPrimary: textPrimary.color(for: scheme),
            textSecondary: textSecondary.color(for: scheme),
            accent: accent.color(for: scheme),
            dotBase: dotBase.color(for: scheme)
        )
    }

    public func uiColors(for scheme: ThemeColorScheme) -> ThemeUIColors {
        ThemeUIColors(
            appBackground: appBackground.uiColor(for: scheme),
            surface: surface.uiColor(for: scheme),
            textPrimary: textPrimary.uiColor(for: scheme),
            textSecondary: textSecondary.uiColor(for: scheme),
            accent: accent.uiColor(for: scheme),
            dotBase: dotBase.uiColor(for: scheme)
        )
    }
}

public struct ThemeColors: Hashable {
    public let appBackground: Color
    public let surface: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let accent: Color
    public let dotBase: Color

    public init(
        appBackground: Color,
        surface: Color,
        textPrimary: Color,
        textSecondary: Color,
        accent: Color,
        dotBase: Color
    ) {
        self.appBackground = appBackground
        self.surface = surface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.accent = accent
        self.dotBase = dotBase
    }
}

public struct ThemeUIColors: Hashable {
    public let appBackground: UIColor
    public let surface: UIColor
    public let textPrimary: UIColor
    public let textSecondary: UIColor
    public let accent: UIColor
    public let dotBase: UIColor

    public init(
        appBackground: UIColor,
        surface: UIColor,
        textPrimary: UIColor,
        textSecondary: UIColor,
        accent: UIColor,
        dotBase: UIColor
    ) {
        self.appBackground = appBackground
        self.surface = surface
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.accent = accent
        self.dotBase = dotBase
    }
}

public struct Theme: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let palette: ThemePalette

    public init(id: String, name: String, palette: ThemePalette) {
        self.id = id
        self.name = name
        self.palette = palette
    }
}

public extension Theme {
    static let morningMist = Theme(
        id: "morning-mist",
        name: "Morning Mist",
        palette: ThemePalette(
            appBackground: ThemeColor(lightHex: "#F5F7FA", darkHex: "#0F172A"),
            surface: ThemeColor(lightHex: "#FFFFFF", darkHex: "#1E293B"),
            textPrimary: ThemeColor(lightHex: "#1E293B", darkHex: "#E2E8F0"),
            textSecondary: ThemeColor(lightHex: "#94A3B8", darkHex: "#64748B"),
            accent: ThemeColor(lightHex: "#3B82F6", darkHex: "#60A5FA"),
            dotBase: ThemeColor(lightHex: "#3B82F6", darkHex: "#60A5FA")
        )
    )

    static let paperInk = Theme(
        id: "paper-ink",
        name: "Paper & Ink",
        palette: ThemePalette(
            appBackground: ThemeColor(lightHex: "#FDFBF7", darkHex: "#1C1C1E"),
            surface: ThemeColor(lightHex: "#FFFFFF", darkHex: "#2C2C2E"),
            textPrimary: ThemeColor(lightHex: "#2D2A26", darkHex: "#E5E5E0"),
            textSecondary: ThemeColor(lightHex: "#8E8B86", darkHex: "#8E8E93"),
            accent: ThemeColor(lightHex: "#4A4A4A", darkHex: "#A1A1AA"),
            dotBase: ThemeColor(lightHex: "#2D2A26", darkHex: "#E5E5E0")
        )
    )

    static let forestFloor = Theme(
        id: "forest-floor",
        name: "Forest Floor",
        palette: ThemePalette(
            appBackground: ThemeColor(lightHex: "#F2F5F3", darkHex: "#111C16"),
            surface: ThemeColor(lightHex: "#FFFFFF", darkHex: "#1A2621"),
            textPrimary: ThemeColor(lightHex: "#0F291E", darkHex: "#D1FAE5"),
            textSecondary: ThemeColor(lightHex: "#6B7280", darkHex: "#6EE7B7"),
            accent: ThemeColor(lightHex: "#10B981", darkHex: "#34D399"),
            dotBase: ThemeColor(lightHex: "#059669", darkHex: "#34D399")
        )
    )

    static let ceramic = Theme(
        id: "ceramic",
        name: "Ceramic",
        palette: ThemePalette(
            appBackground: ThemeColor(lightHex: "#FAFAF9", darkHex: "#282320"),
            surface: ThemeColor(lightHex: "#FFFFFF", darkHex: "#3F3733"),
            textPrimary: ThemeColor(lightHex: "#44403C", darkHex: "#E7E5E4"),
            textSecondary: ThemeColor(lightHex: "#A8A29E", darkHex: "#A8A29E"),
            accent: ThemeColor(lightHex: "#D97706", darkHex: "#F59E0B"),
            dotBase: ThemeColor(lightHex: "#D97706", darkHex: "#F59E0B")
        )
    )

    static let twilight = Theme(
        id: "twilight",
        name: "Twilight",
        palette: ThemePalette(
            appBackground: ThemeColor(lightHex: "#FAF5FF", darkHex: "#1E1B4B"),
            surface: ThemeColor(lightHex: "#FFFFFF", darkHex: "#312E81"),
            textPrimary: ThemeColor(lightHex: "#3B0764", darkHex: "#E9D5FF"),
            textSecondary: ThemeColor(lightHex: "#9333EA", darkHex: "#A78BFA"),
            accent: ThemeColor(lightHex: "#9333EA", darkHex: "#C084FC"),
            dotBase: ThemeColor(lightHex: "#7E22CE", darkHex: "#A78BFA")
        )
    )

    static let all: [Theme] = [
        .morningMist,
        .paperInk,
        .forestFloor,
        .ceramic,
        .twilight
    ]

    static let defaultTheme: Theme = .paperInk
}
