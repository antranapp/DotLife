import SwiftUI
import UIKit

@MainActor
public final class ThemeManager: ObservableObject {
    private enum StorageKeys {
        static let selectedThemeId = "dotlife.theme.selected"
        static let appearanceOverride = "dotlife.theme.appearanceOverride"
        static let fontDesign = "dotlife.theme.fontDesign"
    }

    @Published public var selectedThemeId: String {
        didSet {
            persistSelectedTheme()
        }
    }

    @Published public var appearanceOverride: ThemeAppearanceOverride {
        didSet {
            persistAppearanceOverride()
        }
    }

    @Published public private(set) var fontDesign: FontDesign {
        didSet {
            _typography = ThemeTypography.withDesign(fontDesign)
            persistFontDesign()
        }
    }

    private var _typography: ThemeTypography
    public var typography: ThemeTypography { _typography }

    public let spacing: ThemeSpacing
    public let radii: ThemeRadii

    private let userDefaults: UserDefaults

    public init(
        userDefaults: UserDefaults = .standard,
        defaultFontDesign: FontDesign = .monospaced,
        spacing: ThemeSpacing = .standard,
        radii: ThemeRadii = .standard
    ) {
        self.userDefaults = userDefaults
        self.spacing = spacing
        self.radii = radii

        // Load font design from storage or use default (monospaced)
        let storedFontDesign = userDefaults.string(forKey: StorageKeys.fontDesign)
        let loadedFontDesign = FontDesign(rawValue: storedFontDesign ?? "") ?? defaultFontDesign
        self.fontDesign = loadedFontDesign
        self._typography = ThemeTypography.withDesign(loadedFontDesign)

        let storedThemeId = userDefaults.string(forKey: StorageKeys.selectedThemeId)
        self.selectedThemeId = storedThemeId ?? Theme.defaultTheme.id

        let storedOverride = userDefaults.string(forKey: StorageKeys.appearanceOverride)
        self.appearanceOverride = ThemeAppearanceOverride(rawValue: storedOverride ?? "") ?? .system
    }

    /// Changes the font design for the app
    public func setFontDesign(_ design: FontDesign) {
        fontDesign = design
    }

    public var themes: [Theme] {
        Theme.all
    }

    public var selectedTheme: Theme {
        themes.first(where: { $0.id == selectedThemeId }) ?? Theme.defaultTheme
    }

    public func selectTheme(_ theme: Theme) {
        selectedThemeId = theme.id
    }

    public func resolvedScheme(system colorScheme: ColorScheme) -> ThemeColorScheme {
        switch appearanceOverride {
        case .system:
            return colorScheme == .dark ? .dark : .light
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    public func colors(for colorScheme: ColorScheme) -> ThemeColors {
        let scheme = resolvedScheme(system: colorScheme)
        return selectedTheme.palette.colors(for: scheme)
    }

    public func tokens(for colorScheme: ColorScheme) -> ThemeTokens {
        ThemeTokens(
            colors: colors(for: colorScheme),
            typography: typography,
            spacing: spacing,
            radii: radii
        )
    }

    public var preferredColorScheme: ColorScheme? {
        switch appearanceOverride {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    public func resolvedScheme(userInterfaceStyle: UIUserInterfaceStyle) -> ThemeColorScheme {
        switch appearanceOverride {
        case .system:
            return userInterfaceStyle == .dark ? .dark : .light
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    public func uiColors(for userInterfaceStyle: UIUserInterfaceStyle) -> ThemeUIColors {
        let scheme = resolvedScheme(userInterfaceStyle: userInterfaceStyle)
        return selectedTheme.palette.uiColors(for: scheme)
    }

    public var interfaceStyleOverride: UIUserInterfaceStyle {
        switch appearanceOverride {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    private func persistSelectedTheme() {
        userDefaults.set(selectedThemeId, forKey: StorageKeys.selectedThemeId)
    }

    private func persistAppearanceOverride() {
        userDefaults.set(appearanceOverride.rawValue, forKey: StorageKeys.appearanceOverride)
    }

    private func persistFontDesign() {
        userDefaults.set(fontDesign.rawValue, forKey: StorageKeys.fontDesign)
    }
}
