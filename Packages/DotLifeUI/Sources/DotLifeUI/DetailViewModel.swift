import Foundation
import DotLifeDomain

/// View model for the Detail screen showing experiences in a bucket.
@MainActor
public final class DetailViewModel: ObservableObject {
    // MARK: - Published State

    /// The bucket being displayed
    @Published public var bucket: TimeBucket

    /// Experiences in this bucket
    @Published public var experiences: [ExperienceRecord] = []

    /// Whether data is loading
    @Published public var isLoading: Bool = false

    /// Whether showing the add sheet
    @Published public var showingAddSheet: Bool = false

    /// Error message
    @Published public var errorMessage: String?

    // MARK: - Dependencies

    private let repository: any DotLifeDomain.ExperienceRepository
    private let bucketingService: TimeBucketingService

    // MARK: - Initialization

    public init(
        bucket: TimeBucket,
        repository: any DotLifeDomain.ExperienceRepository,
        bucketingService: TimeBucketingService = .current
    ) {
        self.bucket = bucket
        self.repository = repository
        self.bucketingService = bucketingService
    }

    // MARK: - Actions

    /// Fetches experiences for this bucket.
    public func loadExperiences() async {
        isLoading = true
        errorMessage = nil

        do {
            let request = ExperienceFetchRequest.forBucket(bucket)
            let records = try await repository.fetch(request)
            // Sort newest first
            self.experiences = records.sorted { $0.timestamp > $1.timestamp }
        } catch {
            errorMessage = "Failed to load experiences"
        }

        isLoading = false
    }

    /// Adds a quick dot experience to this bucket.
    public func addDot(momentType: MomentType) async {
        // Use the bucket's start time for context
        let timestamp = bucket.start.addingTimeInterval(1) // Slight offset to ensure within bucket

        let request = ExperienceCreateRequest.dot(
            momentType: momentType,
            timestamp: timestamp
        )

        do {
            _ = try await repository.create(request)
            await loadExperiences()
        } catch {
            errorMessage = "Failed to add experience"
        }
    }

    /// Adds a note experience to this bucket.
    public func addNote(_ text: String, momentType: MomentType) async {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let timestamp = bucket.start.addingTimeInterval(1)

        let request = ExperienceCreateRequest.note(
            trimmedText,
            momentType: momentType,
            timestamp: timestamp
        )

        do {
            _ = try await repository.create(request)
            await loadExperiences()
        } catch {
            errorMessage = "Failed to add experience"
        }
    }

    /// Shows the add sheet
    public func showAdd() {
        showingAddSheet = true
    }

    /// Hides the add sheet
    public func hideAdd() {
        showingAddSheet = false
    }
}
