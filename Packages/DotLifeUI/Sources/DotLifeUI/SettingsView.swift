import SwiftUI
import DotLifeDomain

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

    public init(viewModel: SettingsViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    TemplateEditorView(viewModel: viewModel)
                } header: {
                    Text("Capture Sentence")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Customize how you express gratitude.")
                        Text("Must include [moment] and [experience] placeholders.")
                            .foregroundStyle(viewModel.isTemplateValid ? Color.secondary : Color.red)
                    }
                }

                Section {
                    Button("Reset to Default") {
                        viewModel.resetToDefault()
                    }
                    .foregroundStyle(.blue)
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
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

/// Template editor with live preview and validation
struct TemplateEditorView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Editor
            TextField("Template", text: $viewModel.templateText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(2...4)
                .focused($isFocused)

            // Validation status
            if let error = viewModel.validationError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text("Template is valid")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            // Preview
            Divider()

            Text("Preview")
                .font(.caption)
                .foregroundStyle(.secondary)

            TemplatePreview(template: viewModel.templateText)
        }
    }
}

/// Preview of the template with highlighted placeholders
struct TemplatePreview: View {
    let template: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(parseTemplate(), id: \.self) { segment in
                if segment == "[experience]" {
                    Text("note")
                        .foregroundStyle(.blue)
                        .underline()
                } else if segment == "[moment]" {
                    Text("now")
                        .foregroundStyle(.blue)
                        .underline()
                } else {
                    Text(segment)
                }
            }
        }
        .font(.body)
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
