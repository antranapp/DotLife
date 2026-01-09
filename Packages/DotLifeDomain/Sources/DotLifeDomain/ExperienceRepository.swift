import Foundation

// MARK: - Experience Record

/// A value type representing a stored experience.
/// Used for passing experience data across module boundaries.
public struct ExperienceRecord: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let createdAt: Date
    public let momentType: MomentType
    public let experienceType: ExperienceType

    // Payload (mutually exclusive based on experienceType)
    public let noteText: String?
    public let linkURL: URL?
    public let photoLocalPath: String?
    public let photoThumbnailPath: String?

    public init(
        id: UUID,
        timestamp: Date,
        createdAt: Date,
        momentType: MomentType,
        experienceType: ExperienceType,
        noteText: String? = nil,
        linkURL: URL? = nil,
        photoLocalPath: String? = nil,
        photoThumbnailPath: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.createdAt = createdAt
        self.momentType = momentType
        self.experienceType = experienceType
        self.noteText = noteText
        self.linkURL = linkURL
        self.photoLocalPath = photoLocalPath
        self.photoThumbnailPath = photoThumbnailPath
    }
}

// MARK: - Experience Create Request

/// Request object for creating a new experience.
public struct ExperienceCreateRequest: Sendable {
    public let momentType: MomentType
    public let experienceType: ExperienceType
    public let timestamp: Date

    // Payload (set based on experienceType)
    public let noteText: String?
    public let linkURL: URL?
    public let photoData: Data?

    private init(
        momentType: MomentType,
        experienceType: ExperienceType,
        timestamp: Date,
        noteText: String?,
        linkURL: URL?,
        photoData: Data?
    ) {
        self.momentType = momentType
        self.experienceType = experienceType
        self.timestamp = timestamp
        self.noteText = noteText
        self.linkURL = linkURL
        self.photoData = photoData
    }

    /// Creates a request for a note experience.
    public static func note(
        _ text: String,
        momentType: MomentType,
        timestamp: Date = Date()
    ) -> ExperienceCreateRequest {
        ExperienceCreateRequest(
            momentType: momentType,
            experienceType: .note,
            timestamp: timestamp,
            noteText: text,
            linkURL: nil,
            photoData: nil
        )
    }

    /// Creates a request for a link experience.
    public static func link(
        _ url: URL,
        momentType: MomentType,
        timestamp: Date = Date()
    ) -> ExperienceCreateRequest {
        ExperienceCreateRequest(
            momentType: momentType,
            experienceType: .link,
            timestamp: timestamp,
            noteText: nil,
            linkURL: url,
            photoData: nil
        )
    }

    /// Creates a request for a photo experience.
    public static func photo(
        _ data: Data,
        momentType: MomentType,
        timestamp: Date = Date()
    ) -> ExperienceCreateRequest {
        ExperienceCreateRequest(
            momentType: momentType,
            experienceType: .photo,
            timestamp: timestamp,
            noteText: nil,
            linkURL: nil,
            photoData: data
        )
    }

    /// Creates a request for a dot-only experience (no content).
    public static func dot(
        momentType: MomentType,
        timestamp: Date = Date()
    ) -> ExperienceCreateRequest {
        ExperienceCreateRequest(
            momentType: momentType,
            experienceType: .dot,
            timestamp: timestamp,
            noteText: nil,
            linkURL: nil,
            photoData: nil
        )
    }
}

// MARK: - Fetch Request

/// Request for fetching experiences with filters.
public struct ExperienceFetchRequest: Sendable {
    public let startDate: Date?
    public let endDate: Date?
    public let momentTypes: Set<MomentType>?
    public let experienceTypes: Set<ExperienceType>?
    public let limit: Int?
    public let offset: Int?

    public init(
        startDate: Date? = nil,
        endDate: Date? = nil,
        momentTypes: Set<MomentType>? = nil,
        experienceTypes: Set<ExperienceType>? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.momentTypes = momentTypes
        self.experienceTypes = experienceTypes
        self.limit = limit
        self.offset = offset
    }

    /// Creates a request for fetching experiences within a time bucket.
    public static func forBucket(_ bucket: TimeBucket) -> ExperienceFetchRequest {
        ExperienceFetchRequest(
            startDate: bucket.start,
            endDate: bucket.end
        )
    }

    /// Creates a request for fetching all experiences on a specific day.
    public static func forDay(_ date: Date, using service: TimeBucketingService = .current) -> ExperienceFetchRequest {
        let bucket = service.bucket(for: date, type: .day)
        return forBucket(bucket)
    }

    /// Creates a request for fetching all experiences in a specific week.
    public static func forWeek(_ date: Date, using service: TimeBucketingService = .current) -> ExperienceFetchRequest {
        let bucket = service.bucket(for: date, type: .week)
        return forBucket(bucket)
    }
}

// MARK: - Experience Repository Protocol

/// Protocol for experience persistence operations.
/// Implemented by DotLifePersistence, consumed by DotLifeUI.
public protocol ExperienceRepository: Sendable {
    /// Creates a new experience and returns the created record.
    func create(_ request: ExperienceCreateRequest) async throws -> ExperienceRecord

    /// Fetches experiences matching the given request.
    func fetch(_ request: ExperienceFetchRequest) async throws -> [ExperienceRecord]

    /// Fetches a single experience by ID.
    func fetch(byID id: UUID) async throws -> ExperienceRecord?

    /// Deletes an experience by ID.
    func delete(byID id: UUID) async throws

    /// Returns bucket summaries for the given buckets.
    /// Used for determining which dots are filled.
    func summaries(for buckets: [TimeBucket]) async throws -> [TimeBucketSummary]

    /// Returns the count of experiences within a time bucket.
    func count(in bucket: TimeBucket) async throws -> Int

    /// Returns a dictionary mapping dates to experience counts for a date range.
    /// Used for year visualization grid.
    /// - Parameters:
    ///   - startDate: Start of the date range (inclusive)
    ///   - endDate: End of the date range (inclusive)
    /// - Returns: Dictionary with date keys (start of day) and count values
    func experienceCountsByDay(from startDate: Date, to endDate: Date) async throws -> [Date: Int]
}

// MARK: - Repository Errors

/// Errors that can occur during repository operations.
public enum ExperienceRepositoryError: Error, Sendable {
    case notFound(UUID)
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case photoStorageFailed(Error)
    case invalidData(String)
}
