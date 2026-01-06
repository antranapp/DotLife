import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import DotLifeDomain
import DotLifeDS

/// Detail view showing experiences for a specific time bucket.
public struct DetailView: View {
    @ObservedObject private var viewModel: DetailViewModel
    let onDismiss: () -> Void

    @State private var newNoteText: String = ""
    @State private var selectedMomentType: MomentType = .now
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    public init(
        viewModel: DetailViewModel,
        onDismiss: @escaping () -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }

    public var body: some View {
        let colors = tokens.colors

        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.experiences.isEmpty {
                    loadingView
                } else if viewModel.experiences.isEmpty {
                    emptyState
                } else {
                    experienceList
                }
            }
            .background(colors.appBackground.ignoresSafeArea())
            .foregroundStyle(colors.textPrimary)
            .navigationTitle(viewModel.bucket.extendedLabel())
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
            #endif
            .sheet(isPresented: $viewModel.showingAddSheet) {
                addExperienceSheet
            }
            .tint(colors.accent)
        }
        .task {
            await viewModel.loadExperiences()
        }
    }

    // MARK: - Experience List

    private var experienceList: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return List {
            ForEach(viewModel.experiences) { experience in
                ExperienceRow(experience: experience)
            }

            // Add button at bottom
            Section {
                Button(action: { viewModel.showAdd() }) {
                    Label("Add an experience", systemImage: "plus.circle")
                        .foregroundStyle(colors.accent)
                        .font(typography.body)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(colors.appBackground)
        .refreshable {
            await viewModel.loadExperiences()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return VStack(spacing: 24) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 60))
                .foregroundStyle(colors.textSecondary)

            Text("No experiences yet")
                .font(typography.title)
                .foregroundStyle(colors.textSecondary)

            Text("Add something to remember this moment")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: { viewModel.showAdd() }) {
                Label("Add an experience", systemImage: "plus.circle.fill")
                    .font(typography.body)
                    .foregroundStyle(colors.appBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(colors.accent)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading

    private var loadingView: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return VStack(spacing: 12) {
            ProgressView()
                .tint(colors.accent)
            Text("Loading...")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Add Sheet

    private var addExperienceSheet: some View {
        let colors = tokens.colors
        let typography = tokens.typography
        let spacing = tokens.spacing
        let radii = tokens.radii

        return NavigationView {
            VStack(spacing: 24) {
                // Moment type picker
                Picker("Moment", selection: $selectedMomentType) {
                    ForEach(MomentType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, spacing.lg)

                // Note input
                TextField("What are you appreciating?", text: $newNoteText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(typography.body)
                    .foregroundStyle(colors.textPrimary)
                    .padding(spacing.lg)
                    .background(colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: radii.md))
                    .padding(.horizontal, spacing.lg)
                    .lineLimit(3...6)

                // Action buttons
                HStack(spacing: 16) {
                    // Quick dot button
                    Button(action: {
                        Task {
                            await viewModel.addDot(momentType: selectedMomentType)
                            viewModel.hideAdd()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(colors.dotBase)
                                .frame(width: 40, height: 40)
                            Text("Just a dot")
                                .font(typography.caption)
                                .foregroundStyle(colors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    // Add note button
                    Button(action: {
                        Task {
                            await viewModel.addNote(newNoteText, momentType: selectedMomentType)
                            newNoteText = ""
                            viewModel.hideAdd()
                        }
                    }) {
                        Text("Add Note")
                            .font(typography.body)
                            .foregroundStyle(colors.appBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, spacing.md)
                            .background(newNoteText.isEmpty ? colors.textSecondary.opacity(0.3) : colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: radii.md))
                    }
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, spacing.lg)

                Spacer()
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.appBackground.ignoresSafeArea())
            .foregroundStyle(colors.textPrimary)
            .navigationTitle("Add Experience")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newNoteText = ""
                        viewModel.hideAdd()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button("Cancel") {
                        newNoteText = ""
                        viewModel.hideAdd()
                    }
                }
            }
            #endif
        }
        #if os(iOS)
        .presentationDetents([.medium])
        #endif
    }
}

/// A row displaying a single experience.
struct ExperienceRow: View {
    let experience: ExperienceRecord
    @State private var showingFullPhoto: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let typography = tokens.typography
        let spacing = tokens.spacing
        let radii = tokens.radii

        HStack(alignment: .top, spacing: 12) {
            // Type icon
            Image(systemName: iconName)
                .font(typography.body)
                .foregroundStyle(colors.textSecondary)
                .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                contentView

                // Moment type label - visible by default
                Text(experience.momentType.displayName)
                    .font(typography.caption)
                    .foregroundStyle(colors.textSecondary.opacity(0.7))
                    .padding(.horizontal, spacing.sm)
                    .padding(.vertical, spacing.xs / 2)
                    .background(colors.dotBase.opacity(0.08))
                    .clipShape(Capsule())
            }

            Spacer()

            // Timestamp
            Text(timeString)
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
        }
        .padding(.vertical, 4)
        #if os(iOS)
        .fullScreenCover(isPresented: $showingFullPhoto) {
            if let photoPath = experience.photoLocalPath {
                PhotoFullScreenView(photoPath: photoPath, onDismiss: { showingFullPhoto = false })
            }
        }
        #else
        .sheet(isPresented: $showingFullPhoto) {
            if let photoPath = experience.photoLocalPath {
                PhotoFullScreenView(photoPath: photoPath, onDismiss: { showingFullPhoto = false })
            }
        }
        #endif
    }

    private var iconName: String {
        switch experience.experienceType {
        case .note: return "note.text"
        case .photo: return "photo"
        case .link: return "link"
        case .dot: return "circle.fill"
        }
    }

    @ViewBuilder
    private var contentView: some View {
        let colors = tokens.colors
        let typography = tokens.typography
        let radii = tokens.radii

        switch experience.experienceType {
        case .note:
            if let text = experience.noteText {
                Text(text)
                    .font(typography.body)
                    .foregroundStyle(colors.textPrimary)
            }
        case .link:
            if let url = experience.linkURL {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text(url.host ?? url.absoluteString)
                            .font(typography.body)
                            .foregroundStyle(colors.accent)
                            .lineLimit(1)
                        Image(systemName: "arrow.up.right.square")
                            .font(typography.caption)
                            .foregroundStyle(colors.accent)
                    }
                }
            }
        case .photo:
            if let thumbnailPath = experience.photoThumbnailPath {
                PhotoThumbnailView(thumbnailPath: thumbnailPath)
                    .onTapGesture {
                        showingFullPhoto = true
                    }
            } else if experience.photoLocalPath != nil {
                // Fallback if no thumbnail
                Rectangle()
                    .fill(colors.textSecondary.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: radii.sm))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(colors.textSecondary)
                    }
                    .onTapGesture {
                        showingFullPhoto = true
                    }
            } else {
                Text("Photo")
                    .font(typography.body)
                    .foregroundStyle(colors.textSecondary)
            }
        case .dot:
            Text("Moment")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary)
                .italic()
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: experience.timestamp)
    }
}

// MARK: - Photo Thumbnail View

/// Displays a photo thumbnail from local storage.
struct PhotoThumbnailView: View {
    let thumbnailPath: String
    @State private var image: Image?
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors
        let radii = tokens.radii

        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: radii.sm))
            } else {
                Rectangle()
                    .fill(colors.textSecondary.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: radii.sm))
                    .overlay {
                        ProgressView()
                            .tint(colors.accent)
                    }
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        #if canImport(UIKit)
        guard let thumbnailURL = AttachmentPathResolver.thumbnailURL(for: thumbnailPath) else { return }
        Task {
            if let loaded = await loadImage(from: thumbnailURL) {
                image = loaded
            }
        }
        #endif
    }
}

// MARK: - Photo Full Screen View

/// Full screen view for displaying a photo.
struct PhotoFullScreenView: View {
    let photoPath: String
    let onDismiss: () -> Void
    @State private var image: Image?
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    var body: some View {
        let colors = tokens.colors

        NavigationView {
            ZStack {
                colors.appBackground.ignoresSafeArea()

                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(colors.textPrimary)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundStyle(colors.textPrimary)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            #else
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundStyle(colors.textPrimary)
                }
            }
            #endif
        }
        .onAppear {
            loadPhoto()
        }
    }

    private func loadPhoto() {
        #if canImport(UIKit)
        guard let photoURL = AttachmentPathResolver.photoURL(for: photoPath) else { return }
        Task {
            if let loaded = await loadImage(from: photoURL) {
                image = loaded
            }
        }
        #endif
    }
}

// MARK: - Attachment Paths

private enum AttachmentPathResolver {
    static func photoURL(for relativePath: String) -> URL? {
        photosDirectory()?.appendingPathComponent(relativePath)
    }

    static func thumbnailURL(for relativePath: String) -> URL? {
        thumbnailsDirectory()?.appendingPathComponent(relativePath)
    }

    private static func photosDirectory() -> URL? {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("DotLife/Photos", isDirectory: true)
    }

    private static func thumbnailsDirectory() -> URL? {
        let base = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("DotLife/Thumbnails", isDirectory: true)
    }
}

// MARK: - Image Loading

#if canImport(UIKit)
private func loadImage(from url: URL) async -> Image? {
    await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            let image: Image?
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            } else {
                image = nil
            }
            continuation.resume(returning: image)
        }
    }
}
#endif

// MARK: - Detail View for Push Navigation

/// Detail view designed for push navigation (no NavigationView wrapper, no Done button).
/// Used when presenting from UINavigationController.
public struct DetailViewForPush: View {
    @ObservedObject private var viewModel: DetailViewModel
    let onRefreshNeeded: () -> Void

    @State private var newNoteText: String = ""
    @State private var selectedMomentType: MomentType = .now
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private var tokens: ThemeTokens {
        themeManager.tokens(for: colorScheme)
    }

    public init(
        viewModel: DetailViewModel,
        onRefreshNeeded: @escaping () -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onRefreshNeeded = onRefreshNeeded
    }

    public var body: some View {
        let colors = tokens.colors

        ZStack {
            if viewModel.isLoading && viewModel.experiences.isEmpty {
                loadingView
            } else if viewModel.experiences.isEmpty {
                emptyState
            } else {
                experienceList
            }
        }
        .background(colors.appBackground.ignoresSafeArea())
        .foregroundStyle(colors.textPrimary)
        .sheet(isPresented: $viewModel.showingAddSheet) {
            addExperienceSheet
        }
        .tint(colors.accent)
        .task {
            await viewModel.loadExperiences()
        }
    }

    // MARK: - Experience List

    private var experienceList: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return List {
            ForEach(viewModel.experiences) { experience in
                ExperienceRow(experience: experience)
            }

            // Add button at bottom
            Section {
                Button(action: { viewModel.showAdd() }) {
                    Label("Add an experience", systemImage: "plus.circle")
                        .foregroundStyle(colors.accent)
                        .font(typography.body)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(colors.appBackground)
        .refreshable {
            await viewModel.loadExperiences()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return VStack(spacing: 24) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 60))
                .foregroundStyle(colors.textSecondary)

            Text("No experiences yet")
                .font(typography.title)
                .foregroundStyle(colors.textSecondary)

            Text("Add something to remember this moment")
                .font(typography.body)
                .foregroundStyle(colors.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: { viewModel.showAdd() }) {
                Label("Add an experience", systemImage: "plus.circle.fill")
                    .font(typography.body)
                    .foregroundStyle(colors.appBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(colors.accent)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading

    private var loadingView: some View {
        let colors = tokens.colors
        let typography = tokens.typography

        return VStack(spacing: 12) {
            ProgressView()
                .tint(colors.accent)
            Text("Loading...")
                .font(typography.caption)
                .foregroundStyle(colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Add Sheet

    private var addExperienceSheet: some View {
        let colors = tokens.colors
        let typography = tokens.typography
        let spacing = tokens.spacing
        let radii = tokens.radii

        return NavigationView {
            VStack(spacing: 24) {
                // Moment type picker
                Picker("Moment", selection: $selectedMomentType) {
                    ForEach(MomentType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, spacing.lg)

                // Note input
                TextField("What are you appreciating?", text: $newNoteText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(typography.body)
                    .foregroundStyle(colors.textPrimary)
                    .padding(spacing.lg)
                    .background(colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: radii.md))
                    .padding(.horizontal, spacing.lg)
                    .lineLimit(3...6)

                // Action buttons
                HStack(spacing: 16) {
                    // Quick dot button
                    Button(action: {
                        Task {
                            await viewModel.addDot(momentType: selectedMomentType)
                            viewModel.hideAdd()
                            onRefreshNeeded()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(colors.dotBase)
                                .frame(width: 40, height: 40)
                            Text("Just a dot")
                                .font(typography.caption)
                                .foregroundStyle(colors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    // Add note button
                    Button(action: {
                        Task {
                            await viewModel.addNote(newNoteText, momentType: selectedMomentType)
                            newNoteText = ""
                            viewModel.hideAdd()
                            onRefreshNeeded()
                        }
                    }) {
                        Text("Add Note")
                            .font(typography.body)
                            .foregroundStyle(colors.appBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, spacing.md)
                            .background(newNoteText.isEmpty ? colors.textSecondary.opacity(0.3) : colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: radii.md))
                    }
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, spacing.lg)

                Spacer()
            }
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.appBackground.ignoresSafeArea())
            .foregroundStyle(colors.textPrimary)
            .navigationTitle("Add Experience")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newNoteText = ""
                        viewModel.hideAdd()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem {
                    Button("Cancel") {
                        newNoteText = ""
                        viewModel.hideAdd()
                    }
                }
            }
            #endif
        }
        #if os(iOS)
        .presentationDetents([.medium])
        #endif
    }
}
