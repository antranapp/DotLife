import Testing
import Foundation
import DotLifeDomain

// MARK: - Helper to create dates in UTC

private func makeDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int = 0,
    minute: Int = 0,
    second: Int = 0,
    timeZone: TimeZone = TimeZone(identifier: "UTC")!
) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second
    return calendar.date(from: components)!
}

// MARK: - Week Start Tests (Monday)

@Test func weekStartsOnMonday() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // Test a Wednesday (Jan 3, 2024)
    let wednesday = makeDate(year: 2024, month: 1, day: 3, hour: 14, minute: 30)
    let weekStart = service.startOfWeek(for: wednesday)

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let weekday = calendar.component(.weekday, from: weekStart)

    // weekday 2 = Monday
    #expect(weekday == 2, "Week should start on Monday (weekday 2), got \(weekday)")
}

@Test func weekStartForMonday() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // Jan 1, 2024 is a Monday
    let monday = makeDate(year: 2024, month: 1, day: 1, hour: 10, minute: 0)
    let weekStart = service.startOfWeek(for: monday)

    // Should return the same Monday at midnight
    let expectedStart = makeDate(year: 2024, month: 1, day: 1)
    #expect(weekStart == expectedStart)
}

@Test func weekStartForSunday() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // Jan 7, 2024 is a Sunday
    let sunday = makeDate(year: 2024, month: 1, day: 7, hour: 23, minute: 59)
    let weekStart = service.startOfWeek(for: sunday)

    // Should return the previous Monday (Jan 1)
    let expectedStart = makeDate(year: 2024, month: 1, day: 1)
    #expect(weekStart == expectedStart)
}

@Test func weekStartForSaturday() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // Jan 6, 2024 is a Saturday
    let saturday = makeDate(year: 2024, month: 1, day: 6, hour: 12, minute: 0)
    let weekStart = service.startOfWeek(for: saturday)

    // Should return the previous Monday (Jan 1)
    let expectedStart = makeDate(year: 2024, month: 1, day: 1)
    #expect(weekStart == expectedStart)
}

// MARK: - Day/Hour Normalization Tests

@Test func startOfHourNormalization() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 37, second: 42)
    let hourStart = service.startOfHour(for: date)

    let expected = makeDate(year: 2024, month: 6, day: 15, hour: 14)
    #expect(hourStart == expected)
}

@Test func startOfDayNormalization() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 23, minute: 59, second: 59)
    let dayStart = service.startOfDay(for: date)

    let expected = makeDate(year: 2024, month: 6, day: 15)
    #expect(dayStart == expected)
}

@Test func startOfMonthNormalization() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let monthStart = service.startOfMonth(for: date)

    let expected = makeDate(year: 2024, month: 6, day: 1)
    #expect(monthStart == expected)
}

@Test func startOfYearNormalization() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let yearStart = service.startOfYear(for: date)

    let expected = makeDate(year: 2024, month: 1, day: 1)
    #expect(yearStart == expected)
}

// MARK: - Leap Year Tests

@Test func leapYear2024() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    #expect(service.isLeapYear(2024) == true)
}

@Test func nonLeapYear2023() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    #expect(service.isLeapYear(2023) == false)
}

@Test func leapYear2000() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    // 2000 is a leap year (divisible by 400)
    #expect(service.isLeapYear(2000) == true)
}

@Test func nonLeapYear1900() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    // 1900 is NOT a leap year (divisible by 100 but not 400)
    #expect(service.isLeapYear(1900) == false)
}

@Test func daysInLeapYear() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let leapYearDate = makeDate(year: 2024, month: 6, day: 15)
    #expect(service.numberOfDaysInYear(containing: leapYearDate) == 366)
}

@Test func daysInNonLeapYear() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let nonLeapYearDate = makeDate(year: 2023, month: 6, day: 15)
    #expect(service.numberOfDaysInYear(containing: nonLeapYearDate) == 365)
}

// MARK: - Bucket Sequence Tests

@Test func hourBucketsForDay() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let buckets = service.hourBuckets(forDayContaining: date)

    #expect(buckets.count == 24)

    // Check first bucket is midnight
    let firstBucket = buckets.first!
    let expectedFirst = makeDate(year: 2024, month: 6, day: 15, hour: 0)
    #expect(firstBucket.start == expectedFirst)
    #expect(firstBucket.type == .hour)

    // Check last bucket is 11 PM
    let lastBucket = buckets.last!
    let expectedLast = makeDate(year: 2024, month: 6, day: 15, hour: 23)
    #expect(lastBucket.start == expectedLast)
}

@Test func dayBucketsForWeek() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // Jan 3, 2024 is a Wednesday
    let wednesday = makeDate(year: 2024, month: 1, day: 3, hour: 14, minute: 30)
    let buckets = service.dayBuckets(forWeekContaining: wednesday)

    #expect(buckets.count == 7)

    // First bucket should be Monday (Jan 1)
    let firstBucket = buckets.first!
    let expectedFirst = makeDate(year: 2024, month: 1, day: 1)
    #expect(firstBucket.start == expectedFirst)
    #expect(firstBucket.type == .day)

    // Last bucket should be Sunday (Jan 7)
    let lastBucket = buckets.last!
    let expectedLast = makeDate(year: 2024, month: 1, day: 7)
    #expect(lastBucket.start == expectedLast)
}

@Test func dayBucketsForMonth() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // February 2024 (leap year) should have 29 days
    let febDate = makeDate(year: 2024, month: 2, day: 15)
    let buckets = service.dayBuckets(forMonthContaining: febDate)

    #expect(buckets.count == 29)

    // First bucket should be Feb 1
    let firstBucket = buckets.first!
    let expectedFirst = makeDate(year: 2024, month: 2, day: 1)
    #expect(firstBucket.start == expectedFirst)

    // Last bucket should be Feb 29
    let lastBucket = buckets.last!
    let expectedLast = makeDate(year: 2024, month: 2, day: 29)
    #expect(lastBucket.start == expectedLast)
}

@Test func dayBucketsForNonLeapFebruary() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    // February 2023 (non-leap year) should have 28 days
    let febDate = makeDate(year: 2023, month: 2, day: 15)
    let buckets = service.dayBuckets(forMonthContaining: febDate)

    #expect(buckets.count == 28)
}

@Test func monthBucketsForYear() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15)
    let buckets = service.monthBuckets(forYearContaining: date)

    #expect(buckets.count == 12)

    // First bucket should be January
    let firstBucket = buckets.first!
    let expectedFirst = makeDate(year: 2024, month: 1, day: 1)
    #expect(firstBucket.start == expectedFirst)
    #expect(firstBucket.type == .month)

    // Last bucket should be December
    let lastBucket = buckets.last!
    let expectedLast = makeDate(year: 2024, month: 12, day: 1)
    #expect(lastBucket.start == expectedLast)
}

@Test func dayBucketsForLeapYear() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15)
    let buckets = service.dayBuckets(forYearContaining: date)

    #expect(buckets.count == 366)
}

@Test func dayBucketsForNonLeapYear() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2023, month: 6, day: 15)
    let buckets = service.dayBuckets(forYearContaining: date)

    #expect(buckets.count == 365)
}

// MARK: - Bucket ID Stability Tests

@Test func bucketIDIsStable() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let bucket1 = service.bucket(for: date, type: .hour)
    let bucket2 = service.bucket(for: date, type: .hour)

    #expect(bucket1.bucketID == bucket2.bucketID)
}

@Test func bucketIDDiffersByType() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let hourBucket = service.bucket(for: date, type: .hour)
    let dayBucket = service.bucket(for: date, type: .day)

    #expect(hourBucket.bucketID != dayBucket.bucketID)
}

@Test func bucketIDDiffersByTime() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date1 = makeDate(year: 2024, month: 6, day: 15, hour: 14)
    let date2 = makeDate(year: 2024, month: 6, day: 15, hour: 15)

    let bucket1 = service.bucket(for: date1, type: .hour)
    let bucket2 = service.bucket(for: date2, type: .hour)

    #expect(bucket1.bucketID != bucket2.bucketID)
}

// MARK: - Bucket Contains Tests

@Test func bucketContainsDate() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let bucket = service.bucket(for: date, type: .hour)

    #expect(bucket.contains(date) == true)
}

@Test func bucketDoesNotContainDateOutsideRange() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30)
    let bucket = service.bucket(for: date, type: .hour)

    let outsideDate = makeDate(year: 2024, month: 6, day: 15, hour: 15, minute: 0)
    #expect(bucket.contains(outsideDate) == false)
}

// MARK: - View Bucket Tests

@Test func bucketsForTodayViewAtHours() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)

    let buckets = service.buckets(forTodayView: date, at: .hours)
    #expect(buckets.count == 24)
    #expect(buckets.first?.type == .hour)
}

@Test func bucketsForTodayViewAtDays() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)

    let buckets = service.buckets(forTodayView: date, at: .days)
    #expect(buckets.count == 7)
    #expect(buckets.first?.type == .day)
}

@Test func bucketsForTodayViewAtMonths() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)

    let buckets = service.buckets(forTodayView: date, at: .months)
    #expect(buckets.count == 12)
    #expect(buckets.first?.type == .month)
}

@Test func bucketsForWeekViewAtDays() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)

    let buckets = service.buckets(forWeekView: date, at: .days)
    #expect(buckets.count == 7)
    #expect(buckets.first?.type == .day)
}

@Test func bucketsForWeekViewAtMonths() {
    let service = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)

    let buckets = service.buckets(forWeekView: date, at: .months)
    #expect(buckets.count == 12)
    #expect(buckets.first?.type == .month)
}
