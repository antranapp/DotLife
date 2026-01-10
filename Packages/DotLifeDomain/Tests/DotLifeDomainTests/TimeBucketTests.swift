import Testing
import Foundation
@testable import DotLifeDomain

// MARK: - Helper

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

// MARK: - TimeBucket Tests

@Test func timeBucketHashable() {
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)
    let bucket1 = TimeBucket(type: .hour, start: date)
    let bucket2 = TimeBucket(type: .hour, start: date)

    #expect(bucket1 == bucket2)
    #expect(bucket1.hashValue == bucket2.hashValue)
}

@Test func timeBucketIdentifiable() {
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)
    let bucket = TimeBucket(type: .hour, start: date)

    #expect(bucket.id == bucket.bucketID)
}

@Test func timeBucketEndForHour() {
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 14)
    let bucket = TimeBucket(type: .hour, start: date)
    let expectedEnd = makeDate(year: 2024, month: 6, day: 15, hour: 15)

    #expect(bucket.end == expectedEnd)
}

@Test func timeBucketEndForDay() {
    let date = makeDate(year: 2024, month: 6, day: 15)
    let bucket = TimeBucket(type: .day, start: date)
    let expectedEnd = makeDate(year: 2024, month: 6, day: 16)

    #expect(bucket.end == expectedEnd)
}

@Test func timeBucketEndForMonth() {
    let date = makeDate(year: 2024, month: 6, day: 1)
    let bucket = TimeBucket(type: .month, start: date)
    let expectedEnd = makeDate(year: 2024, month: 7, day: 1)

    #expect(bucket.end == expectedEnd)
}

@Test func timeBucketEndForYear() {
    let date = makeDate(year: 2024, month: 1, day: 1)
    let bucket = TimeBucket(type: .year, start: date)
    let expectedEnd = makeDate(year: 2025, month: 1, day: 1)

    #expect(bucket.end == expectedEnd)
}

// MARK: - TimeBucketSummary Tests

@Test func timeBucketSummaryHasMoments() {
    let date = makeDate(year: 2024, month: 6, day: 15)
    let bucket = TimeBucket(type: .day, start: date)
    let summary = TimeBucketSummary(bucket: bucket, count: 5)

    #expect(summary.hasMoments == true)
}

@Test func timeBucketSummaryNoMoments() {
    let date = makeDate(year: 2024, month: 6, day: 15)
    let bucket = TimeBucket(type: .day, start: date)
    let summary = TimeBucketSummary(bucket: bucket, count: 0)

    #expect(summary.hasMoments == false)
}

@Test func timeBucketSummaryEmpty() {
    let date = makeDate(year: 2024, month: 6, day: 15)
    let bucket = TimeBucket(type: .day, start: date)
    let summary = TimeBucketSummary.empty(for: bucket)

    #expect(summary.count == 0)
    #expect(summary.hasMoments == false)
}

@Test func timeBucketSummaryIdentifiable() {
    let date = makeDate(year: 2024, month: 6, day: 15)
    let bucket = TimeBucket(type: .day, start: date)
    let summary = TimeBucketSummary(bucket: bucket, count: 3)

    #expect(summary.id == bucket.bucketID)
}

// MARK: - Display Label Tests

@Test func timeBucketDisplayLabelForHour() {
    // Use current timezone so displayLabel() output matches expected hour
    let date = makeDate(year: 2024, month: 6, day: 15, hour: 15, timeZone: .current)
    let bucket = TimeBucket(type: .hour, start: date)

    // The exact format may vary by locale, but it should contain "3" (12h) or "15" (24h)
    let label = bucket.displayLabel()
    #expect(label.lowercased().contains("3") || label.lowercased().contains("15"))
}

@Test func timeBucketDisplayLabelForDay() {
    let date = makeDate(year: 2024, month: 6, day: 15) // Saturday
    let bucket = TimeBucket(type: .day, start: date)
    let label = bucket.displayLabel()

    // Should contain "Sat" for Saturday
    #expect(label.lowercased().contains("sat"))
}

@Test func timeBucketDisplayLabelForMonth() {
    let date = makeDate(year: 2024, month: 6, day: 15) // June
    let bucket = TimeBucket(type: .month, start: date)
    let label = bucket.displayLabel()

    // Should contain "Jun" for June
    #expect(label.lowercased().contains("jun"))
}

@Test func timeBucketDisplayLabelForYear() {
    let date = makeDate(year: 2024, month: 6, day: 15)
    let bucket = TimeBucket(type: .year, start: date)
    let label = bucket.displayLabel()

    #expect(label == "2024")
}
