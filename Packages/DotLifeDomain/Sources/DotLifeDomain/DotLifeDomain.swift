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

    public var displayName: String {
        switch self {
        case .now: return "now"
        case .today: return "today"
        case .thisWeek: return "this week"
        }
    }
}

// MARK: - Experience Type

/// The type of content captured in an experience.
public enum ExperienceType: Int16, Codable, CaseIterable, Sendable {
    case note = 0
    case photo = 1
    case link = 2
    case dot = 3

    public var displayName: String {
        switch self {
        case .note: return "note"
        case .photo: return "photo"
        case .link: return "link"
        case .dot: return "dot"
        }
    }
}

// MARK: - Grid Scale

/// Time scales for the visualization grid.
/// Used for zoom ladder in Today and Week views.
public enum GridScale: Int, Codable, Sendable, CaseIterable {
    case hours = 0    // 24 hours in a day
    case days = 1     // 7 days in a week
    case weeks = 2    // weeks in a month
    case months = 3   // 12 months in a year

    public var displayName: String {
        switch self {
        case .hours: return "Hours"
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        }
    }
}

// MARK: - View Type

/// The two main views in the Visualize page.
public enum VisualizeViewType: Sendable {
    case today
    case week
}

// MARK: - Zoom Ladder

/// Defines the zoom ladder for each view type.
/// Today view: hours → days → months → year (as months)
/// Week view: days → months → year (as months)
public enum ZoomLadder {
    /// Zoom scales available in Today view
    public static let todayViewScales: [GridScale] = [.hours, .days, .months]

    /// Zoom scales available in Week view
    public static let weekViewScales: [GridScale] = [.days, .months]

    /// Get available scales for a view type
    public static func scales(for viewType: VisualizeViewType) -> [GridScale] {
        switch viewType {
        case .today:
            return todayViewScales
        case .week:
            return weekViewScales
        }
    }

    /// Get the next zoom-out scale, or nil if at maximum
    public static func zoomOut(from scale: GridScale, in viewType: VisualizeViewType) -> GridScale? {
        let availableScales = scales(for: viewType)
        guard let currentIndex = availableScales.firstIndex(of: scale),
              currentIndex + 1 < availableScales.count else {
            return nil
        }
        return availableScales[currentIndex + 1]
    }

    /// Get the next zoom-in scale, or nil if at minimum
    public static func zoomIn(from scale: GridScale, in viewType: VisualizeViewType) -> GridScale? {
        let availableScales = scales(for: viewType)
        guard let currentIndex = availableScales.firstIndex(of: scale),
              currentIndex > 0 else {
            return nil
        }
        return availableScales[currentIndex - 1]
    }
}

// MARK: - Module Info

/// Module version information.
public enum DotLifeDomainModule {
    public static let version = "0.1.0"
}
