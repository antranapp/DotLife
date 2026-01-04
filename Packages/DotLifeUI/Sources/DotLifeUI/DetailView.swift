import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import DotLifeDomain

/// Detail view showing experiences for a specific time bucket.
public struct DetailView: View {
    @ObservedObject private var viewModel: DetailViewModel
    let onDismiss: () -> Void

    @State private var newNoteText: String = ""
    @State private var selectedMomentType: MomentType = .now
    @Environment(\.openURL) private var openURL

    public init(
        viewModel: DetailViewModel,
        onDismiss: @escaping () -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }

    public var body: some View {
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
        }
        .task {
            await viewModel.loadExperiences()
        }
    }

    // MARK: - Experience List

    private var experienceList: some View {
        List {
            ForEach(viewModel.experiences) { experience in
                ExperienceRow(experience: experience)
            }

            // Add button at bottom
            Section {
                Button(action: { viewModel.showAdd() }) {
                    Label("Add an experience", systemImage: "plus.circle")
                        .foregroundStyle(.blue)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadExperiences()
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "circle.dotted")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No experiences yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add something to remember this moment")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button(action: { viewModel.showAdd() }) {
                Label("Add an experience", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Add Sheet

    private var addExperienceSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Moment type picker
                Picker("Moment", selection: $selectedMomentType) {
                    ForEach(MomentType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Note input
                TextField("What are you appreciating?", text: $newNoteText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
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
                                .fill(Color.primary)
                                .frame(width: 40, height: 40)
                            Text("Just a dot")
                                .font(.caption)
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
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(newNoteText.isEmpty ? Color.gray : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
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

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Type icon
            Image(systemName: iconName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                contentView

                // Moment type label - visible by default
                Text(experience.momentType.displayName)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Capsule())
            }

            Spacer()

            // Timestamp
            Text(timeString)
                .font(.caption)
                .foregroundStyle(.tertiary)
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
        switch experience.experienceType {
        case .note:
            if let text = experience.noteText {
                Text(text)
                    .font(.body)
            }
        case .link:
            if let url = experience.linkURL {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text(url.host ?? url.absoluteString)
                            .font(.body)
                            .foregroundStyle(.blue)
                            .lineLimit(1)
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.blue)
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
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        showingFullPhoto = true
                    }
            } else {
                Text("Photo")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        case .dot:
            Text("Moment")
                .font(.body)
                .foregroundStyle(.secondary)
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

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        ProgressView()
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

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            #else
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundStyle(.white)
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
