import SwiftUI
import DotLifeDS

/// Default template string
public let defaultTemplate = "I appreciate [experience] for [moment]"

/// Keys for UserDefaults storage
private enum SettingsKeys {
    static let sentenceTemplate = "dotlife.sentence.template"
}

/// View model for settings
@MainActor
public final class SettingsViewModel: ObservableObject {
    /// The current template string
    @Published public var templateText: String {
        didSet {
            // Persist to UserDefaults when changed
            UserDefaults.standard.set(templateText, forKey: SettingsKeys.sentenceTemplate)
        }
    }

    /// Whether the current template is valid
    public var isTemplateValid: Bool {
        templateText.contains("[moment]") && templateText.contains("[experience]")
    }

    /// Validation error message
    public var validationError: String? {
        if !templateText.contains("[moment]") && !templateText.contains("[experience]") {
            return "Template must include [moment] and [experience]"
        } else if !templateText.contains("[moment]") {
            return "Template must include [moment]"
        } else if !templateText.contains("[experience]") {
            return "Template must include [experience]"
        }
        return nil
    }

    public init() {
        // Load from UserDefaults or use default
        self.templateText = UserDefaults.standard.string(forKey: SettingsKeys.sentenceTemplate) ?? defaultTemplate
    }

    /// Resets template to default
    public func resetToDefault() {
        templateText = defaultTemplate
    }

    /// Static method to get the current template
    public static func currentTemplate() -> String {
        UserDefaults.standard.string(forKey: SettingsKeys.sentenceTemplate) ?? defaultTemplate
    }
}

/// Settings screen with template editor
public struct SettingsView: View {
    @ObservedObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    public init(viewModel: SettingsViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography
        let spacing = tokens.spacing

        NavigationView {
            Form {
                Section {
                    ForEach(themeManager.themes) { theme in
                        Button(action: { themeManager.selectTheme(theme) }) {
                            ThemeRow(
                                theme: theme,
                                isSelected: theme.id == themeManager.selectedTheme.id,
                                previewScheme: themeManager.resolvedScheme(system: colorScheme),
                                textColors: colors,
                                spacing: spacing,
                                radii: tokens.radii
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, spacing.xs)
                    }
                } header: {
                    Text("Theme")
                        .font(typography.caption)
                } footer: {
                    Text("Default: Paper & Ink")
                        .font(typography.caption)
                        .foregroundStyle(colors.textSecondary)
                }

                Section {
                    Picker("Appearance", selection: $themeManager.appearanceOverride) {
                        ForEach(ThemeAppearanceOverride.allCases) { override in
                            Text(override.displayName).tag(override)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                        .font(typography.caption)
                }

                Section {
                    TemplateEditorView(viewModel: viewModel)
                } header: {
                    Text("Capture Sentence")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Customize how you express gratitude.")
                        Text("Must include [moment] and [experience] placeholders.")
                            .foregroundStyle(viewModel.isTemplateValid ? colors.textSecondary : colors.accent)
                    }
                }

                Section {
                    Button("Reset to Default") {
                        viewModel.resetToDefault()
                    }
                    .foregroundStyle(colors.accent)
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(colors.textSecondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .tint(colors.accent)
            .foregroundStyle(colors.textPrimary)
            .scrollContentBackground(.hidden)
            .background(colors.appBackground.ignoresSafeArea())
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

private struct ThemeRow: View {
    let theme: Theme
    let isSelected: Bool
    let previewScheme: ThemeColorScheme
    let textColors: ThemeColors
    let spacing: ThemeSpacing
    let radii: ThemeRadii

    var body: some View {
        let previewColors = theme.palette.colors(for: previewScheme)

        HStack(spacing: spacing.md) {
            ThemePalettePreview(colors: previewColors, radii: radii)

            Text(theme.name)
                .foregroundStyle(textColors.textPrimary)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(textColors.accent)
            }
        }
        .padding(.vertical, spacing.xs)
    }
}

private struct ThemePalettePreview: View {
    let colors: ThemeColors
    let radii: ThemeRadii

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colors.appBackground)
                .frame(width: 12, height: 12)
            Circle()
                .fill(colors.surface)
                .frame(width: 12, height: 12)
            Circle()
                .fill(colors.accent)
                .frame(width: 12, height: 12)
            Circle()
                .fill(colors.dotBase)
                .frame(width: 12, height: 12)
        }
        .padding(4)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: radii.sm))
        .overlay(
            RoundedRectangle(cornerRadius: radii.sm)
                .stroke(colors.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

/// Template editor with live preview and validation
struct TemplateEditorView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @FocusState private var isFocused: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        VStack(alignment: .leading, spacing: 12) {
            // Editor
            TextField("Template", text: $viewModel.templateText, axis: .vertical)
                .textFieldStyle(.plain)
                .font(typography.body)
                .foregroundStyle(colors.textPrimary)
                .lineLimit(2...4)
                .focused($isFocused)

            // Validation status
            if let error = viewModel.validationError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(colors.accent)
                        .font(typography.caption)
                    Text(error)
                        .font(typography.caption)
                        .foregroundStyle(colors.accent)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(colors.textSecondary)
                        .font(typography.caption)
                    Text("Template is valid")
                        .font(typography.caption)
                        .foregroundStyle(colors.textSecondary)
                }
            }

            // Preview
            Divider()

            Text("Preview")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary)

            TemplatePreview(template: viewModel.templateText)
        }
    }
}

/// Preview of the template with highlighted placeholders
struct TemplatePreview: View {
    let template: String
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        HStack(spacing: 4) {
            ForEach(parseTemplate(), id: \.self) { segment in
                if segment == "[experience]" {
                    Text("note")
                        .foregroundStyle(colors.accent)
                        .underline()
                } else if segment == "[moment]" {
                    Text("now")
                        .foregroundStyle(colors.accent)
                        .underline()
                } else {
                    Text(segment)
                        .foregroundStyle(colors.textPrimary)
                }
            }
        }
        .font(typography.body)
    }

    private func parseTemplate() -> [String] {
        var result: [String] = []
        var remaining = template

        while !remaining.isEmpty {
            if let expRange = remaining.range(of: "[experience]") {
                let before = String(remaining[..<expRange.lowerBound])
                if !before.isEmpty {
                    result.append(before)
                }
                result.append("[experience]")
                remaining = String(remaining[expRange.upperBound...])
            } else if let momRange = remaining.range(of: "[moment]") {
                let before = String(remaining[..<momRange.lowerBound])
                if !before.isEmpty {
                    result.append(before)
                }
                result.append("[moment]")
                remaining = String(remaining[momRange.upperBound...])
            } else {
                result.append(remaining)
                break
            }
        }

        return result
    }
}
