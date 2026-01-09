import Foundation

/// Represents a single day in the year visualization grid.
/// Contains the date and experience count for rendering the dot.
public struct YearDay: Identifiable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let experienceCount: Int
    public let isToday: Bool
    public let isFuture: Bool

    public init(
        date: Date,
        experienceCount: Int,
        isToday: Bool,
        isFuture: Bool
    ) {
        // Use date string as stable ID for grid rendering
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.id = formatter.string(from: date)

        self.date = date
        self.experienceCount = experienceCount
        self.isToday = isToday
        self.isFuture = isFuture
    }

    /// Whether this day has at least one recorded experience.
    public var hasExperiences: Bool {
        experienceCount > 0
    }
}

// MARK: - Year Generation

public extension YearDay {
    /// Generates all days for a given year.
    /// - Parameters:
    ///   - year: The calendar year (e.g., 2026)
    ///   - experienceCounts: Dictionary mapping dates to experience counts
    ///   - calendar: Calendar to use for date calculations
    /// - Returns: Array of YearDay structs for each day in the year
    static func generateYear(
        _ year: Int,
        experienceCounts: [Date: Int],
        calendar: Calendar = .current
    ) -> [YearDay] {
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31))
        else {
            return []
        }

        let today = calendar.startOfDay(for: Date())
        var days: [YearDay] = []
        var currentDate = startOfYear

        while currentDate <= endOfYear {
            let startOfCurrentDay = calendar.startOfDay(for: currentDate)
            let count = experienceCounts[startOfCurrentDay] ?? 0
            let isToday = calendar.isDate(currentDate, inSameDayAs: today)
            let isFuture = currentDate > today

            days.append(YearDay(
                date: currentDate,
                experienceCount: count,
                isToday: isToday,
                isFuture: isFuture
            ))

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return days
    }

    /// Generates all days for the current calendar year.
    static func generateCurrentYear(
        experienceCounts: [Date: Int],
        calendar: Calendar = .current
    ) -> [YearDay] {
        let year = calendar.component(.year, from: Date())
        return generateYear(year, experienceCounts: experienceCounts, calendar: calendar)
    }
}
