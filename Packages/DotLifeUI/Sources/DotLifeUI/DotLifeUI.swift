import SwiftUI
import PhotosUI
import DotLifeDomain
import DotLifeDS

/// DotLifeUI module version.
public enum DotLifeUIModule {
    public static let version = "0.1.0"
}

/// The Capture screen for logging experiences.
public struct CaptureView: View {
    @ObservedObject private var viewModel: CaptureViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingSettings: Bool = false
    @StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    private var colors: ThemeColors { tokens.colors }
    private var typography: ThemeTypography { tokens.typography }
    private var spacing: ThemeSpacing { tokens.spacing }
    private var radii: ThemeRadii { tokens.radii }

    public init(viewModel: CaptureViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    public var body: some View {
        GeometryReader { _ in
            ZStack {
                VStack(spacing: 0) {
                    Spacer()

                    // Sentence template
                    sentenceView
                        .padding(.horizontal, spacing.xxl)

                    Spacer()
                        .frame(height: spacing.xxl + spacing.sm)

                    // Input area
                    inputArea
                        .padding(.horizontal, spacing.xxl)

                    Spacer()

                    // Debug footer (subtle)
                    if viewModel.savedCount > 0 {
                        debugFooter
                            .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(colors.textPrimary)

                // Settings button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .foregroundStyle(colors.textSecondary)
                                .padding(spacing.lg)
                        }
                        .accessibilityLabel("Settings")
                        .accessibilityIdentifier("capture.settingsButton")
                    }
                    Spacer()
                }
            }
            .background(colors.appBackground.ignoresSafeArea())
            .tint(colors.accent)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("capture.screen")
        }
        .onAppear {
            // Focus text field for note experience
            if viewModel.experienceType == .note, viewModel.isCaptureActive {
                isTextFieldFocused = true
            }
            Task {
                await viewModel.refreshSavedCount()
            }
        }
        .onChange(of: viewModel.experienceType) { _, newValue in
            if viewModel.isCaptureActive {
                isTextFieldFocused = newValue == .note
            }
        }
        .onChange(of: viewModel.isCaptureActive) { _, isActive in
            if isActive {
                isTextFieldFocused = viewModel.experienceType == .note
            } else {
                isTextFieldFocused = false
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: settingsViewModel)
        }
    }

    // MARK: - Sentence View

    private var sentenceView: some View {
        TemplateSentenceView(
            template: SettingsViewModel.currentTemplate(),
            experienceType: viewModel.experienceType,
            momentType: viewModel.momentType,
            onExperienceTap: { viewModel.cycleExperienceType() },
            onMomentTap: { viewModel.cycleMomentType() }
        )
    }

    private var experienceButton: some View {
        Button(action: { viewModel.cycleExperienceType() }) {
            Text(viewModel.experienceType.displayName)
                .font(typography.title)
                .foregroundStyle(colors.accent)
                .underline()
        }
        .accessibilityLabel("Experience type: \(viewModel.experienceType.displayName). Tap to change.")
    }

    private var momentButton: some View {
        Button(action: { viewModel.cycleMomentType() }) {
            Text(viewModel.momentType.displayName)
                .font(typography.title)
                .foregroundStyle(colors.accent)
                .underline()
        }
        .accessibilityLabel("Moment: \(viewModel.momentType.displayName). Tap to change.")
    }

    // MARK: - Input Area

    @ViewBuilder
    private var inputArea: some View {
        switch viewModel.experienceType {
        case .note:
            noteInput
        case .photo:
            photoInput
        case .link:
            linkInput
        case .dot:
            dotInput
        }
    }

    private var noteInput: some View {
        VStack(spacing: 16) {
            TextField("What are you appreciating?", text: $viewModel.noteText)
                .font(typography.body)
                .foregroundStyle(colors.textPrimary)
                .textFieldStyle(.plain)
                .padding()
                .background(colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: radii.md))
                .focused($isTextFieldFocused)
                .accessibilityIdentifier("capture.noteTextField")
                .submitLabel(.done)
                .onSubmit {
                    Task {
                        await viewModel.saveNote()
                    }
                }

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(colors.accent)
                    .accessibilityIdentifier("capture.noteSavingIndicator")
            }
        }
    }

    private var photoInput: some View {
        VStack(spacing: 16) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Choose Photo", systemImage: "photo")
                    .font(typography.body)
                    .foregroundStyle(colors.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: radii.md))
            }
            .accessibilityIdentifier("capture.photoPickerButton")
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await handlePhotoSelection(newItem)
                }
            }

            if viewModel.isSaving {
                ProgressView("Saving photo...")
                    .progressViewStyle(.circular)
                    .tint(colors.accent)
                    .accessibilityIdentifier("capture.photoSavingIndicator")
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(typography.caption)
                    .foregroundStyle(colors.accent)
                    .accessibilityIdentifier("capture.photoErrorLabel")
            }
        }
    }

    @MainActor
    private func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                viewModel.photoSelected(data)
                // Clear selection for next pick
                selectedPhotoItem = nil
            }
        } catch {
            viewModel.errorMessage = "Failed to load photo"
        }
    }

    private var linkInput: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("example.com", text: $viewModel.linkText)
                    .font(typography.body)
                    .foregroundStyle(colors.textPrimary)
                    .textFieldStyle(.plain)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("capture.linkTextField")
                    .submitLabel(.done)
                    .onSubmit {
                        if viewModel.canSave {
                            Task {
                                await viewModel.saveLink()
                            }
                        }
                    }

                // Validation indicator
                if !viewModel.linkText.isEmpty {
                    Image(systemName: viewModel.isValidLink ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isValidLink ? colors.textSecondary : colors.accent)
                        .accessibilityIdentifier("capture.linkValidationIcon")
                }
            }
            .padding()
            .background(colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: radii.md))

            Button(action: {
                Task {
                    await viewModel.saveLink()
                }
            }) {
                Text("Add Link")
                    .font(typography.body)
                    .foregroundStyle(colors.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canSave ? colors.accent : colors.textSecondary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: radii.md))
            }
            .accessibilityIdentifier("capture.linkAddButton")
            .disabled(!viewModel.canSave)

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(colors.accent)
                    .accessibilityIdentifier("capture.linkSavingIndicator")
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(typography.caption)
                    .foregroundStyle(colors.accent)
                    .accessibilityIdentifier("capture.linkErrorLabel")
            }
        }
    }

    private var dotInput: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await viewModel.saveDot()
                }
            }) {
                VStack(spacing: 12) {
                    Circle()
                        .fill(colors.dotBase)
                        .frame(width: 60, height: 60)

                    Text("Tap to add a dot")
                        .font(typography.body)
                        .foregroundStyle(colors.textSecondary)
                        .accessibilityIdentifier("capture.dotLabel")
                }
            }
            .accessibilityIdentifier("capture.dotAddButton")
            .disabled(viewModel.isSaving)

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(colors.accent)
                    .accessibilityIdentifier("capture.dotSavingIndicator")
            }
        }
    }

    // MARK: - Debug Footer

    private var debugFooter: some View {
        Text("\(viewModel.savedCount) moment\(viewModel.savedCount == 1 ? "" : "s") saved")
            .font(typography.caption)
            .foregroundStyle(colors.textSecondary.opacity(0.7))
            .accessibilityIdentifier("capture.savedCountLabel")
    }
}

/// Placeholder view for the Visualize screen.
public struct VisualizeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    public init() {}

    public var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        VStack(spacing: 20) {
            Image(systemName: "circle.grid.3x3")
                .font(.system(size: 60))
                .foregroundStyle(colors.textSecondary)

            Text("Visualize")
                .font(typography.title)
                .foregroundStyle(colors.textPrimary)

            Text("Your moments will appear here")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.appBackground.ignoresSafeArea())
        .accessibilityIdentifier("visualize.placeholder")
    }
}

// MARK: - Template Sentence View

/// Renders a template sentence with tappable placeholders.
struct TemplateSentenceView: View {
    let template: String
    let experienceType: ExperienceType
    let momentType: MomentType
    let onExperienceTap: () -> Void
    let onMomentTap: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        FlowLayout(spacing: 4) {
            ForEach(Array(parseTemplate().enumerated()), id: \.offset) { _, segment in
                segmentView(for: segment, colors: colors, typography: typography)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("capture.sentence")
    }

    @ViewBuilder
    private func segmentView(for segment: TemplateSegment, colors: ThemeColors, typography: ThemeTypography) -> some View {
        switch segment {
        case .text(let text):
            Text(text)
                .font(typography.title)
                .foregroundStyle(colors.textPrimary)
        case .experience:
            Button(action: onExperienceTap) {
                Text(experienceType.displayName)
                    .font(typography.title)
                    .foregroundStyle(colors.accent)
                    .underline()
            }
            .accessibilityLabel("Experience type: \(experienceType.displayName). Tap to change.")
            .accessibilityIdentifier("capture.experienceButton")
        case .moment:
            Button(action: onMomentTap) {
                Text(momentType.displayName)
                    .font(typography.title)
                    .foregroundStyle(colors.accent)
                    .underline()
            }
            .accessibilityLabel("Moment: \(momentType.displayName). Tap to change.")
            .accessibilityIdentifier("capture.momentButton")
        }
    }

    private enum TemplateSegment {
        case text(String)
        case experience
        case moment
    }

    private func parseTemplate() -> [TemplateSegment] {
        var result: [TemplateSegment] = []
        var remaining = template

        while !remaining.isEmpty {
            // Find the next placeholder
            let expRange = remaining.range(of: "[experience]")
            let momRange = remaining.range(of: "[moment]")

            // Determine which comes first
            if let expStart = expRange?.lowerBound, let momStart = momRange?.lowerBound {
                if expStart < momStart {
                    let before = String(remaining[..<expStart])
                    if !before.isEmpty { result.append(.text(before)) }
                    result.append(.experience)
                    remaining = String(remaining[expRange!.upperBound...])
                } else {
                    let before = String(remaining[..<momStart])
                    if !before.isEmpty { result.append(.text(before)) }
                    result.append(.moment)
                    remaining = String(remaining[momRange!.upperBound...])
                }
            } else if let expRange = expRange {
                let before = String(remaining[..<expRange.lowerBound])
                if !before.isEmpty { result.append(.text(before)) }
                result.append(.experience)
                remaining = String(remaining[expRange.upperBound...])
            } else if let momRange = momRange {
                let before = String(remaining[..<momRange.lowerBound])
                if !before.isEmpty { result.append(.text(before)) }
                result.append(.moment)
                remaining = String(remaining[momRange.upperBound...])
            } else {
                result.append(.text(remaining))
                break
            }
        }

        return result
    }
}

/// Simple horizontal flow layout for wrapping text
struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                // Wrap to next line
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, currentX)
        }

        return (CGSize(width: totalWidth, height: currentY + lineHeight), positions)
    }
}
