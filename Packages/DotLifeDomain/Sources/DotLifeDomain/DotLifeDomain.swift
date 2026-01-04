import Foundation

// MARK: - Moment Type

/// Represents the user's intent when capturing an experience.
/// - `now`: Capturing something happening right now
/// - `today`: Reflecting on something from today
/// - `thisWeek`: Reflecting on something from this week
public enum MomentType: Int16, Codable, CaseIterable, Sendable {
    case now = 0
    case today = 1
    case thisWeek = 2
}

// MARK: - Experience Type

/// The type of content captured in an experience.
public enum ExperienceType: Int16, Codable, CaseIterable, Sendable {
    case note = 0
    case photo = 1
    case link = 2
    case dot = 3
}

// MARK: - Grid Scale

/// Time scales for the visualization grid.
public enum GridScale: Codable, Sendable {
    case hours      // 24 hours in a day
    case days       // 7 days in a week or ~30 days in a month
    case weeks      // ~4-5 weeks in a month
    case months     // 12 months in a year
}

// MARK: - Placeholder Export

/// Placeholder to ensure the module exports at least one public symbol.
public enum DotLifeDomainModule {
    public static let version = "0.1.0"
}
