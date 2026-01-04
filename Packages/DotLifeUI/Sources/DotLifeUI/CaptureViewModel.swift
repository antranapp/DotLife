import Foundation
#if canImport(UIKit)
import UIKit
#endif
import DotLifeDomain

/// View model for the Capture screen.
@MainActor
public final class CaptureViewModel: ObservableObject {
    // MARK: - Published State

    /// The current moment type (now, today, this week)
    @Published public var momentType: MomentType = .now

    /// The current experience type (note, photo, link, dot)
    @Published public var experienceType: ExperienceType = .note

    /// The note text input
    @Published public var noteText: String = ""

    /// The link URL input
    @Published public var linkText: String = ""

    /// Whether saving is in progress
    @Published public var isSaving: Bool = false

    /// Error message to display
    @Published public var errorMessage: String?

    /// Count of saved experiences (for debug purposes)
    @Published public var savedCount: Int = 0

    /// Whether the photo picker should be shown
    @Published public var showingPhotoPicker: Bool = false

    /// The selected photo data (transient, for display before save)
    @Published public var selectedPhotoData: Data?

    // MARK: - Dependencies

    private let repository: any DotLifeDomain.ExperienceRepository
    private let bucketingService: TimeBucketingService

    // MARK: - Template

    /// The sentence template with placeholders
    public var sentenceTemplate: String = "I appreciate [experience] for [moment]"

    // MARK: - Computed Properties

    /// Whether the keyboard should be shown
    public var shouldShowKeyboard: Bool {
        experienceType == .note
    }

    /// Whether the save button should be enabled
    public var canSave: Bool {
        switch experienceType {
        case .note:
            return !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .link:
            return isValidURL(linkText)
        case .photo:
            return selectedPhotoData != nil
        case .dot:
            return true
        }
    }

    /// Whether the link URL is valid
    public var isValidLink: Bool {
        isValidURL(linkText)
    }

    // MARK: - Initialization

    public init(
        repository: any DotLifeDomain.ExperienceRepository,
        bucketingService: TimeBucketingService = .current
    ) {
        self.repository = repository
        self.bucketingService = bucketingService
    }

    // MARK: - URL Validation

    private func isValidURL(_ string: String) -> Bool {
        guard !string.isEmpty else { return false }

        // Add https:// if no scheme is present
        let urlString: String
        if string.hasPrefix("http://") || string.hasPrefix("https://") {
            urlString = string
        } else {
            urlString = "https://" + string
        }

        guard let url = URL(string: urlString),
              let host = url.host,
              host.contains(".") else {
            return false
        }

        return true
    }

    /// Normalizes the link text to a valid URL
    private func normalizedURL() -> URL? {
        guard !linkText.isEmpty else { return nil }

        let urlString: String
        if linkText.hasPrefix("http://") || linkText.hasPrefix("https://") {
            urlString = linkText
        } else {
            urlString = "https://" + linkText
        }

        return URL(string: urlString)
    }

    // MARK: - Actions

    /// Cycles to the next moment type
    public func cycleMomentType() {
        switch momentType {
        case .now:
            momentType = .today
        case .today:
            momentType = .thisWeek
        case .thisWeek:
            momentType = .now
        }
    }

    /// Cycles to the next experience type
    public func cycleExperienceType() {
        switch experienceType {
        case .note:
            experienceType = .photo
        case .photo:
            experienceType = .link
        case .link:
            experienceType = .dot
        case .dot:
            experienceType = .note
        }
    }

    /// Saves a note experience
    public func saveNote() async {
        let trimmedText = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        await save(ExperienceCreateRequest.note(trimmedText, momentType: momentType))
        noteText = ""
    }

    /// Saves a dot experience
    public func saveDot() async {
        await save(ExperienceCreateRequest.dot(momentType: momentType))
    }

    /// Saves a link experience
    public func saveLink() async {
        guard let url = normalizedURL() else {
            errorMessage = "Invalid URL"
            return
        }

        await save(ExperienceCreateRequest.link(url, momentType: momentType))
        linkText = ""
    }

    /// Saves a photo experience
    public func savePhoto() async {
        guard let photoData = selectedPhotoData else {
            errorMessage = "No photo selected"
            return
        }

        await save(ExperienceCreateRequest.photo(photoData, momentType: momentType))
        selectedPhotoData = nil
    }

    /// Called when photo is selected from picker
    public func photoSelected(_ data: Data?) {
        selectedPhotoData = data
        if data != nil {
            Task {
                await savePhoto()
            }
        }
    }

    // MARK: - Private

    private func save(_ request: ExperienceCreateRequest) async {
        isSaving = true
        errorMessage = nil

        do {
            _ = try await repository.create(request)
            savedCount += 1
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }

        isSaving = false
    }

    /// Fetches the current saved count
    public func refreshSavedCount() async {
        do {
            let records = try await repository.fetch(ExperienceFetchRequest())
            savedCount = records.count
        } catch {
            // Ignore errors for debug count
        }
    }
}
