import Foundation

// MARK: - Time Bucket Type

/// Represents the granularity of a time bucket.
public enum TimeBucketType: Int, Codable, Sendable, CaseIterable {
    case hour = 0
    case day = 1
    case week = 2
    case month = 3
    case year = 4
}

// MARK: - Time Bucket

/// A normalized time bucket representing a specific time period.
/// The `start` date is always normalized to the beginning of the period.
public struct TimeBucket: Hashable, Codable, Sendable, Identifiable {
    /// The type/granularity of this bucket
    public let type: TimeBucketType

    /// The start of this time bucket (normalized)
    public let start: Date

    /// Calendar used for bucket calculations (cached for performance)
    private static var mondayStartCalendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2 // Monday
        return calendar
    }()

    public var id: String {
        bucketID
    }

    /// A stable, unique identifier for this bucket.
    /// Format: "type_timestamp" where timestamp is the Unix timestamp of start.
    public var bucketID: String {
        "\(type.rawValue)_\(Int(start.timeIntervalSince1970))"
    }

    public init(type: TimeBucketType, start: Date) {
        self.type = type
        self.start = start
    }

    /// Returns the end date of this bucket (exclusive).
    public var end: Date {
        let calendar = Self.mondayStartCalendar
        switch type {
        case .hour:
            return calendar.date(byAdding: .hour, value: 1, to: start) ?? start
        case .day:
            return calendar.date(byAdding: .day, value: 1, to: start) ?? start
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? start
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: start) ?? start
        case .year:
            return calendar.date(byAdding: .year, value: 1, to: start) ?? start
        }
    }

    /// Checks if a given date falls within this bucket.
    public func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}

// MARK: - Time Bucket Summary

/// A summary of experiences within a time bucket.
/// Used for visualization (filled vs empty dots).
public struct TimeBucketSummary: Hashable, Codable, Sendable, Identifiable {
    /// The time bucket this summary represents
    public let bucket: TimeBucket

    /// Number of experiences in this bucket
    public let count: Int

    /// Whether this bucket has at least one experience
    public var hasMoments: Bool {
        count > 0
    }

    public var id: String {
        bucket.bucketID
    }

    public init(bucket: TimeBucket, count: Int) {
        self.bucket = bucket
        self.count = count
    }

    /// Creates an empty summary for the given bucket.
    public static func empty(for bucket: TimeBucket) -> TimeBucketSummary {
        TimeBucketSummary(bucket: bucket, count: 0)
    }
}

// MARK: - Display Helpers

extension TimeBucket {
    /// Returns a user-friendly label for this bucket.
    /// - Parameter calendar: The calendar to use for formatting (defaults to current).
    public func displayLabel(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()

        switch type {
        case .hour:
            formatter.dateFormat = "ha" // e.g., "3PM"
            return formatter.string(from: start).lowercased()

        case .day:
            formatter.dateFormat = "EEE" // e.g., "Mon"
            return formatter.string(from: start)

        case .week:
            // ISO week number
            let weekNumber = calendar.component(.weekOfYear, from: start)
            return "Week \(weekNumber)"

        case .month:
            formatter.dateFormat = "MMM" // e.g., "Jan"
            return formatter.string(from: start)

        case .year:
            formatter.dateFormat = "yyyy" // e.g., "2024"
            return formatter.string(from: start)
        }
    }

    /// Returns an extended label with more context.
    public func extendedLabel(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()

        switch type {
        case .hour:
            formatter.dateFormat = "EEE ha" // e.g., "Mon 3pm"
            return formatter.string(from: start).lowercased()

        case .day:
            formatter.dateFormat = "EEE, MMM d" // e.g., "Mon, Jan 15"
            return formatter.string(from: start)

        case .week:
            let weekNumber = calendar.component(.weekOfYear, from: start)
            formatter.dateFormat = "MMM d"
            let startStr = formatter.string(from: start)
            let endDate = calendar.date(byAdding: .day, value: 6, to: start) ?? start
            let endStr = formatter.string(from: endDate)
            return "Week \(weekNumber): \(startStr) - \(endStr)"

        case .month:
            formatter.dateFormat = "MMMM yyyy" // e.g., "January 2024"
            return formatter.string(from: start)

        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: start)
        }
    }
}
