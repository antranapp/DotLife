import SwiftUI
import UIKit

/// Font design style for the app typography
public enum FontDesign: String, CaseIterable, Hashable {
    case standard
    case monospaced
    case rounded
    case serif

    var swiftUIDesign: Font.Design {
        switch self {
        case .standard: return .default
        case .monospaced: return .monospaced
        case .rounded: return .rounded
        case .serif: return .serif
        }
    }
}

public struct ThemeTypography: Hashable {
    public let title: Font
    public let body: Font
    public let caption: Font
    public let monoLabel: Font

    public let uiTitle: UIFont
    public let uiBody: UIFont
    public let uiCaption: UIFont
    public let uiMonoLabel: UIFont

    /// The font design used for this typography configuration
    public let fontDesign: FontDesign

    public init(
        title: Font,
        body: Font,
        caption: Font,
        monoLabel: Font,
        uiTitle: UIFont,
        uiBody: UIFont,
        uiCaption: UIFont,
        uiMonoLabel: UIFont,
        fontDesign: FontDesign = .standard
    ) {
        self.title = title
        self.body = body
        self.caption = caption
        self.monoLabel = monoLabel
        self.uiTitle = uiTitle
        self.uiBody = uiBody
        self.uiCaption = uiCaption
        self.uiMonoLabel = uiMonoLabel
        self.fontDesign = fontDesign
    }

    /// Creates typography with the specified font design
    public static func withDesign(_ design: FontDesign) -> ThemeTypography {
        switch design {
        case .monospaced:
            return monospaced
        case .rounded:
            return rounded
        case .serif:
            return serif
        case .standard:
            return standard
        }
    }

    /// Standard system font typography
    public static let standard = ThemeTypography(
        title: .system(size: 22, weight: .semibold, design: .default),
        body: .system(.body, design: .default),
        caption: .system(.caption, design: .default),
        monoLabel: .system(size: 12, weight: .medium, design: .monospaced),
        uiTitle: UIFont.systemFont(ofSize: 22, weight: .semibold),
        uiBody: UIFont.preferredFont(forTextStyle: .body),
        uiCaption: UIFont.preferredFont(forTextStyle: .caption1),
        uiMonoLabel: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
        fontDesign: .standard
    )

    /// Monospaced font typography (default for DotLife)
    public static let monospaced = ThemeTypography(
        title: .system(size: 22, weight: .semibold, design: .monospaced),
        body: .system(.body, design: .monospaced),
        caption: .system(.caption, design: .monospaced),
        monoLabel: .system(size: 12, weight: .medium, design: .monospaced),
        uiTitle: UIFont.monospacedSystemFont(ofSize: 22, weight: .semibold),
        uiBody: UIFont.monospacedSystemFont(ofSize: 17, weight: .regular),
        uiCaption: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
        uiMonoLabel: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
        fontDesign: .monospaced
    )

    /// Rounded font typography
    public static let rounded = ThemeTypography(
        title: .system(size: 22, weight: .semibold, design: .rounded),
        body: .system(.body, design: .rounded),
        caption: .system(.caption, design: .rounded),
        monoLabel: .system(size: 12, weight: .medium, design: .monospaced),
        uiTitle: UIFont.systemFont(ofSize: 22, weight: .semibold),
        uiBody: UIFont.preferredFont(forTextStyle: .body),
        uiCaption: UIFont.preferredFont(forTextStyle: .caption1),
        uiMonoLabel: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
        fontDesign: .rounded
    )

    /// Serif font typography
    public static let serif = ThemeTypography(
        title: .system(size: 22, weight: .semibold, design: .serif),
        body: .system(.body, design: .serif),
        caption: .system(.caption, design: .serif),
        monoLabel: .system(size: 12, weight: .medium, design: .monospaced),
        uiTitle: UIFont.systemFont(ofSize: 22, weight: .semibold),
        uiBody: UIFont.preferredFont(forTextStyle: .body),
        uiCaption: UIFont.preferredFont(forTextStyle: .caption1),
        uiMonoLabel: UIFont.monospacedSystemFont(ofSize: 12, weight: .medium),
        fontDesign: .serif
    )
}

public struct ThemeSpacing: Hashable {
    public let xs: CGFloat
    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat
    public let xl: CGFloat
    public let xxl: CGFloat

    public init(xs: CGFloat, sm: CGFloat, md: CGFloat, lg: CGFloat, xl: CGFloat, xxl: CGFloat) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
    }

    public static let standard = ThemeSpacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32)
}

public struct ThemeRadii: Hashable {
    public let sm: CGFloat
    public let md: CGFloat
    public let lg: CGFloat

    public init(sm: CGFloat, md: CGFloat, lg: CGFloat) {
        self.sm = sm
        self.md = md
        self.lg = lg
    }

    public static let standard = ThemeRadii(sm: 6, md: 10, lg: 16)
}

public struct ThemeTokens: Hashable {
    public let colors: ThemeColors
    public let typography: ThemeTypography
    public let spacing: ThemeSpacing
    public let radii: ThemeRadii

    public init(colors: ThemeColors, typography: ThemeTypography, spacing: ThemeSpacing, radii: ThemeRadii) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
    }
}
