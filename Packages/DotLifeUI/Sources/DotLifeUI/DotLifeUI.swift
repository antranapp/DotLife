#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import PhotosUI
import DotLifeDomain

/// DotLifeUI module version.
public enum DotLifeUIModule {
    public static let version = "0.1.0"
}

// MARK: - Color Helpers

#if canImport(UIKit)
private let backgroundColor = Color(UIColor.systemBackground)
private let secondaryBackgroundColor = Color(UIColor.secondarySystemBackground)
#else
private let backgroundColor = Color.white
private let secondaryBackgroundColor = Color.gray.opacity(0.1)
#endif

/// The Capture screen for logging experiences.
public struct CaptureView: View {
    @ObservedObject private var viewModel: CaptureViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingSettings: Bool = false
    @StateObject private var settingsViewModel = SettingsViewModel()

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
                        .padding(.horizontal, 32)

                    Spacer()
                        .frame(height: 40)

                    // Input area
                    inputArea
                        .padding(.horizontal, 32)

                    Spacer()

                    // Debug footer (subtle)
                    if viewModel.savedCount > 0 {
                        debugFooter
                            .padding(.bottom, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Settings button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding()
                        }
                        .accessibilityLabel("Settings")
                    }
                    Spacer()
                }
            }
            .background(backgroundColor)
        }
        .onAppear {
            // Focus text field for note experience
            if viewModel.experienceType == .note {
                isTextFieldFocused = true
            }
            Task {
                await viewModel.refreshSavedCount()
            }
        }
        .onChange(of: viewModel.experienceType) { _, newValue in
            isTextFieldFocused = newValue == .note
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
                .font(.title2.weight(.medium))
                .foregroundStyle(.blue)
                .underline()
        }
        .accessibilityLabel("Experience type: \(viewModel.experienceType.displayName). Tap to change.")
    }

    private var momentButton: some View {
        Button(action: { viewModel.cycleMomentType() }) {
            Text(viewModel.momentType.displayName)
                .font(.title2.weight(.medium))
                .foregroundStyle(.blue)
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
                .font(.body)
                .textFieldStyle(.plain)
                .padding()
                .background(secondaryBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .focused($isTextFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    Task {
                        await viewModel.saveNote()
                    }
                }

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
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
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await handlePhotoSelection(newItem)
                }
            }

            if viewModel.isSaving {
                ProgressView("Saving photo...")
                    .progressViewStyle(.circular)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
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
                    .font(.body)
                    .textFieldStyle(.plain)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
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
                        .foregroundStyle(viewModel.isValidLink ? .green : .red)
                }
            }
            .padding()
            .background(secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: {
                Task {
                    await viewModel.saveLink()
                }
            }) {
                Text("Add Link")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canSave ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.canSave)

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
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
                        .fill(Color.primary)
                        .frame(width: 60, height: 60)

                    Text("Tap to add a dot")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(viewModel.isSaving)

            if viewModel.isSaving {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }

    // MARK: - Debug Footer

    private var debugFooter: some View {
        Text("\(viewModel.savedCount) moment\(viewModel.savedCount == 1 ? "" : "s") saved")
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }
}

/// Placeholder view for the Visualize screen.
public struct VisualizeView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "circle.grid.3x3")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Visualize")
                .font(.title)
                .fontWeight(.medium)

            Text("Your moments will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
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

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(Array(parseTemplate().enumerated()), id: \.offset) { _, segment in
                segmentView(for: segment)
            }
        }
    }

    @ViewBuilder
    private func segmentView(for segment: TemplateSegment) -> some View {
        switch segment {
        case .text(let text):
            Text(text)
                .font(.title2)
                .foregroundStyle(.primary)
        case .experience:
            Button(action: onExperienceTap) {
                Text(experienceType.displayName)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.blue)
                    .underline()
            }
            .accessibilityLabel("Experience type: \(experienceType.displayName). Tap to change.")
        case .moment:
            Button(action: onMomentTap) {
                Text(momentType.displayName)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.blue)
                    .underline()
            }
            .accessibilityLabel("Moment: \(momentType.displayName). Tap to change.")
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
