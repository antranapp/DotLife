import Foundation

// MARK: - Time Bucketing Service

/// Service for time bucketing operations.
/// All week calculations use Monday as the first day (ISO 8601).
public struct TimeBucketingService: Sendable {
    /// Calendar configured with Monday as first day of week
    private let calendar: Calendar

    /// The timezone to use for bucketing
    public let timeZone: TimeZone

    public init(timeZone: TimeZone = .current) {
        self.timeZone = timeZone
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2 // Monday = 2 (Sunday = 1)
        calendar.timeZone = timeZone
        self.calendar = calendar
    }

    // MARK: - Start of Period

    /// Returns the start of the hour containing the given date.
    public func startOfHour(for date: Date) -> Date {
        calendar.dateInterval(of: .hour, for: date)?.start ?? date
    }

    /// Returns the start of the day containing the given date.
    public func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Returns the start of the week (Monday) containing the given date.
    public func startOfWeek(for date: Date) -> Date {
        // Get the weekday (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
        let weekday = calendar.component(.weekday, from: date)

        // Calculate days to subtract to get to Monday
        // If weekday is 1 (Sunday), we need to go back 6 days
        // If weekday is 2 (Monday), we need to go back 0 days
        // If weekday is 3 (Tuesday), we need to go back 1 day
        // etc.
        let daysFromMonday = (weekday + 5) % 7

        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: startOfDay(for: date)) else {
            return startOfDay(for: date)
        }
        return monday
    }

    /// Returns the start of the month containing the given date.
    public func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }

    /// Returns the start of the year containing the given date.
    public func startOfYear(for date: Date) -> Date {
        let components = calendar.dateComponents([.year], from: date)
        return calendar.date(from: components) ?? date
    }

    // MARK: - Bucket Creation

    /// Creates a time bucket for the given date at the specified granularity.
    public func bucket(for date: Date, type: TimeBucketType) -> TimeBucket {
        let start: Date
        switch type {
        case .hour:
            start = startOfHour(for: date)
        case .day:
            start = startOfDay(for: date)
        case .week:
            start = startOfWeek(for: date)
        case .month:
            start = startOfMonth(for: date)
        case .year:
            start = startOfYear(for: date)
        }
        return TimeBucket(type: type, start: start)
    }

    // MARK: - Bucket Sequences

    /// Generates hour buckets for a specific day (24 hours).
    /// - Parameter date: Any date within the target day.
    /// - Returns: Array of 24 hour buckets, starting from midnight.
    public func hourBuckets(forDayContaining date: Date) -> [TimeBucket] {
        let dayStart = startOfDay(for: date)
        return (0..<24).compactMap { hour in
            guard let hourStart = calendar.date(byAdding: .hour, value: hour, to: dayStart) else {
                return nil
            }
            return TimeBucket(type: .hour, start: hourStart)
        }
    }

    /// Generates day buckets for a specific week (7 days, Monday-Sunday).
    /// - Parameter date: Any date within the target week.
    /// - Returns: Array of 7 day buckets, starting from Monday.
    public func dayBuckets(forWeekContaining date: Date) -> [TimeBucket] {
        let weekStart = startOfWeek(for: date)
        return (0..<7).compactMap { day in
            guard let dayStart = calendar.date(byAdding: .day, value: day, to: weekStart) else {
                return nil
            }
            return TimeBucket(type: .day, start: dayStart)
        }
    }

    /// Generates day buckets for a specific month.
    /// - Parameter date: Any date within the target month.
    /// - Returns: Array of day buckets for each day in the month.
    public func dayBuckets(forMonthContaining date: Date) -> [TimeBucket] {
        let monthStart = startOfMonth(for: date)
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        return range.compactMap { day in
            guard let dayStart = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else {
                return nil
            }
            return TimeBucket(type: .day, start: dayStart)
        }
    }

    /// Generates week buckets for a specific month.
    /// - Parameter date: Any date within the target month.
    /// - Returns: Array of week buckets that overlap with the month.
    public func weekBuckets(forMonthContaining date: Date) -> [TimeBucket] {
        let monthStart = startOfMonth(for: date)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart

        var buckets: [TimeBucket] = []
        var currentWeekStart = startOfWeek(for: monthStart)

        while currentWeekStart < monthEnd {
            buckets.append(TimeBucket(type: .week, start: currentWeekStart))
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) else {
                break
            }
            currentWeekStart = nextWeek
        }

        return buckets
    }

    /// Generates month buckets for a specific year.
    /// - Parameter date: Any date within the target year.
    /// - Returns: Array of 12 month buckets.
    public func monthBuckets(forYearContaining date: Date) -> [TimeBucket] {
        let yearStart = startOfYear(for: date)
        return (0..<12).compactMap { month in
            guard let monthStart = calendar.date(byAdding: .month, value: month, to: yearStart) else {
                return nil
            }
            return TimeBucket(type: .month, start: monthStart)
        }
    }

    /// Generates day buckets for a specific year.
    /// - Parameter date: Any date within the target year.
    /// - Returns: Array of day buckets (365 or 366 for leap years).
    public func dayBuckets(forYearContaining date: Date) -> [TimeBucket] {
        let yearStart = startOfYear(for: date)
        let daysInYear = numberOfDaysInYear(containing: date)

        return (0..<daysInYear).compactMap { day in
            guard let dayStart = calendar.date(byAdding: .day, value: day, to: yearStart) else {
                return nil
            }
            return TimeBucket(type: .day, start: dayStart)
        }
    }

    // MARK: - Year Calculations

    /// Returns the number of days in the year containing the given date.
    /// Returns 366 for leap years, 365 otherwise.
    public func numberOfDaysInYear(containing date: Date) -> Int {
        let year = calendar.component(.year, from: date)
        return isLeapYear(year) ? 366 : 365
    }

    /// Checks if the given year is a leap year.
    public func isLeapYear(_ year: Int) -> Bool {
        // Leap year: divisible by 4, but not by 100 unless also by 400
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    // MARK: - Bucket Sequences for Views

    /// Generates buckets for the Today view at a given scale.
    /// - Parameters:
    ///   - date: The reference date (typically "today").
    ///   - scale: The grid scale to use.
    /// - Returns: Array of time buckets appropriate for the scale.
    public func buckets(forTodayView date: Date, at scale: GridScale) -> [TimeBucket] {
        switch scale {
        case .hours:
            return hourBuckets(forDayContaining: date)
        case .days:
            return dayBuckets(forWeekContaining: date)
        case .weeks:
            return weekBuckets(forMonthContaining: date)
        case .months:
            return monthBuckets(forYearContaining: date)
        }
    }

    /// Generates buckets for the Week view at a given scale.
    /// - Parameters:
    ///   - date: The reference date (typically within "this week").
    ///   - scale: The grid scale to use.
    /// - Returns: Array of time buckets appropriate for the scale.
    public func buckets(forWeekView date: Date, at scale: GridScale) -> [TimeBucket] {
        switch scale {
        case .hours:
            // Week view doesn't support hours, fall back to days
            return dayBuckets(forWeekContaining: date)
        case .days:
            return dayBuckets(forWeekContaining: date)
        case .weeks:
            return weekBuckets(forMonthContaining: date)
        case .months:
            return monthBuckets(forYearContaining: date)
        }
    }

    // MARK: - Date Range

    /// Returns the date interval for a given bucket type containing the date.
    public func dateInterval(for date: Date, bucketType: TimeBucketType) -> DateInterval {
        let bucket = self.bucket(for: date, type: bucketType)
        return DateInterval(start: bucket.start, end: bucket.end)
    }
}

// MARK: - Convenience Extensions

extension TimeBucketingService {
    /// Creates a bucketing service using the current timezone.
    public static var current: TimeBucketingService {
        TimeBucketingService(timeZone: .current)
    }

    /// Creates a bucketing service using UTC.
    public static var utc: TimeBucketingService {
        TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    }
}
