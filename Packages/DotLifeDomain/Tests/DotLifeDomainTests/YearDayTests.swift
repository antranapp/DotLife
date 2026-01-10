import Testing
import Foundation
@testable import DotLifeDomain

// MARK: - YearDay Tests

@Test func yearDayCreation() {
    let date = Date()
    let yearDay = YearDay(
        date: date,
        experienceCount: 3,
        isToday: true,
        isFuture: false
    )

    #expect(yearDay.date == date)
    #expect(yearDay.experienceCount == 3)
    #expect(yearDay.isToday == true)
    #expect(yearDay.isFuture == false)
}

@Test func yearDayHasExperiences() {
    let dayWithExperiences = YearDay(
        date: Date(),
        experienceCount: 5,
        isToday: false,
        isFuture: false
    )

    let dayWithoutExperiences = YearDay(
        date: Date(),
        experienceCount: 0,
        isToday: false,
        isFuture: false
    )

    #expect(dayWithExperiences.hasExperiences == true)
    #expect(dayWithoutExperiences.hasExperiences == false)
}

@Test func yearDayIdIsUnique() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

    let day1 = YearDay(date: today, experienceCount: 0, isToday: true, isFuture: false)
    let day2 = YearDay(date: tomorrow, experienceCount: 0, isToday: false, isFuture: true)

    #expect(day1.id != day2.id)
}

@Test func yearDayIdIsDeterministic() {
    let date = Date()
    let day1 = YearDay(date: date, experienceCount: 0, isToday: false, isFuture: false)
    let day2 = YearDay(date: date, experienceCount: 5, isToday: true, isFuture: false)

    // Same date should produce same ID regardless of other properties
    #expect(day1.id == day2.id)
}

@Test func yearDayHashable() {
    let date = Date()
    let day1 = YearDay(date: date, experienceCount: 3, isToday: true, isFuture: false)
    let day2 = YearDay(date: date, experienceCount: 3, isToday: true, isFuture: false)

    #expect(day1 == day2)
}

// MARK: - Year Generation Tests

@Test func generateCurrentYearReturnsCorrectDayCount() {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())

    // Check if it's a leap year
    let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    let expectedDays = isLeapYear ? 366 : 365

    let yearDays = YearDay.generateCurrentYear(experienceCounts: [:], calendar: calendar)

    #expect(yearDays.count == expectedDays)
}

@Test func generateYearStartsOnJanuary1() {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())

    let yearDays = YearDay.generateYear(year, experienceCounts: [:], calendar: calendar)

    guard let firstDay = yearDays.first else {
        Issue.record("Expected at least one day")
        return
    }

    let components = calendar.dateComponents([.year, .month, .day], from: firstDay.date)
    #expect(components.year == year)
    #expect(components.month == 1)
    #expect(components.day == 1)
}

@Test func generateYearEndsOnDecember31() {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())

    let yearDays = YearDay.generateYear(year, experienceCounts: [:], calendar: calendar)

    guard let lastDay = yearDays.last else {
        Issue.record("Expected at least one day")
        return
    }

    let components = calendar.dateComponents([.year, .month, .day], from: lastDay.date)
    #expect(components.year == year)
    #expect(components.month == 12)
    #expect(components.day == 31)
}

@Test func generateYearDaysAreInOrder() {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())

    let yearDays = YearDay.generateYear(year, experienceCounts: [:], calendar: calendar)

    for i in 1..<yearDays.count {
        let previousDay = yearDays[i - 1]
        let currentDay = yearDays[i]
        #expect(previousDay.date < currentDay.date)
    }
}

@Test func generateYearMarksTodayCorrectly() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    let yearDays = YearDay.generateCurrentYear(experienceCounts: [:], calendar: calendar)

    let todayDays = yearDays.filter { $0.isToday }
    #expect(todayDays.count == 1)

    if let todayDay = todayDays.first {
        let dayStart = calendar.startOfDay(for: todayDay.date)
        #expect(dayStart == today)
    }
}

@Test func generateYearMarksFutureDaysCorrectly() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    let yearDays = YearDay.generateCurrentYear(experienceCounts: [:], calendar: calendar)

    for day in yearDays {
        let dayStart = calendar.startOfDay(for: day.date)
        if dayStart > today {
            #expect(day.isFuture == true, "Day \(day.date) should be marked as future")
        } else {
            #expect(day.isFuture == false, "Day \(day.date) should not be marked as future")
        }
    }
}

@Test func generateYearAppliesExperienceCounts() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

    let experienceCounts: [Date: Int] = [
        today: 5,
        yesterday: 3
    ]

    let yearDays = YearDay.generateCurrentYear(experienceCounts: experienceCounts, calendar: calendar)

    let todayDay = yearDays.first { calendar.isDate($0.date, inSameDayAs: today) }
    let yesterdayDay = yearDays.first { calendar.isDate($0.date, inSameDayAs: yesterday) }

    #expect(todayDay?.experienceCount == 5)
    #expect(yesterdayDay?.experienceCount == 3)
}

@Test func generateYearDefaultsToZeroExperiences() {
    let calendar = Calendar.current
    let yearDays = YearDay.generateCurrentYear(experienceCounts: [:], calendar: calendar)

    // Most days should have 0 experiences when no counts are provided
    let daysWithZeroExperiences = yearDays.filter { $0.experienceCount == 0 }
    #expect(daysWithZeroExperiences.count == yearDays.count)
}

@Test func generateLeapYear() {
    let calendar = Calendar.current
    // 2024 is a leap year
    let yearDays = YearDay.generateYear(2024, experienceCounts: [:], calendar: calendar)

    #expect(yearDays.count == 366)

    // Check Feb 29 exists
    let feb29 = yearDays.first { day in
        let components = calendar.dateComponents([.month, .day], from: day.date)
        return components.month == 2 && components.day == 29
    }
    #expect(feb29 != nil)
}

@Test func generateNonLeapYear() {
    let calendar = Calendar.current
    // 2023 is not a leap year
    let yearDays = YearDay.generateYear(2023, experienceCounts: [:], calendar: calendar)

    #expect(yearDays.count == 365)

    // Check Feb 29 does not exist
    let feb29 = yearDays.first { day in
        let components = calendar.dateComponents([.month, .day], from: day.date)
        return components.month == 2 && components.day == 29
    }
    #expect(feb29 == nil)
}

// MARK: - Day Change / Midnight Tests

@Test func generateYearWithCustomReferenceDate() {
    let calendar = Calendar.current
    // Use a specific date as "today"
    let customToday = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!

    let yearDays = YearDay.generateYear(2026, experienceCounts: [:], calendar: calendar, referenceDate: customToday)

    // Find the day marked as today
    let todayDays = yearDays.filter { $0.isToday }
    #expect(todayDays.count == 1)

    if let todayDay = todayDays.first {
        let components = calendar.dateComponents([.month, .day], from: todayDay.date)
        #expect(components.month == 6)
        #expect(components.day == 15)
    }
}

@Test func dayChangeUpdatesIsTodayFlag() {
    let calendar = Calendar.current

    // Day 1: January 10 is "today"
    let day1Today = calendar.date(from: DateComponents(year: 2026, month: 1, day: 10))!
    let yearDaysDay1 = YearDay.generateYear(2026, experienceCounts: [:], calendar: calendar, referenceDate: day1Today)

    // Find Jan 10 and Jan 11 in first generation
    let jan10Day1 = yearDaysDay1.first { day in
        let components = calendar.dateComponents([.month, .day], from: day.date)
        return components.month == 1 && components.day == 10
    }
    let jan11Day1 = yearDaysDay1.first { day in
        let components = calendar.dateComponents([.month, .day], from: day.date)
        return components.month == 1 && components.day == 11
    }

    // On Jan 10: Jan 10 is today, Jan 11 is future
    #expect(jan10Day1?.isToday == true)
    #expect(jan10Day1?.isFuture == false)
    #expect(jan11Day1?.isToday == false)
    #expect(jan11Day1?.isFuture == true)

    // Day 2: After midnight, January 11 is "today"
    let day2Today = calendar.date(from: DateComponents(year: 2026, month: 1, day: 11))!
    let yearDaysDay2 = YearDay.generateYear(2026, experienceCounts: [:], calendar: calendar, referenceDate: day2Today)

    // Find Jan 10 and Jan 11 in second generation
    let jan10Day2 = yearDaysDay2.first { day in
        let components = calendar.dateComponents([.month, .day], from: day.date)
        return components.month == 1 && components.day == 10
    }
    let jan11Day2 = yearDaysDay2.first { day in
        let components = calendar.dateComponents([.month, .day], from: day.date)
        return components.month == 1 && components.day == 11
    }

    // After midnight: Jan 10 is no longer today (past day), Jan 11 is now today
    #expect(jan10Day2?.isToday == false, "Jan 10 should no longer be today after midnight")
    #expect(jan10Day2?.isFuture == false, "Jan 10 should be a past day")
    #expect(jan11Day2?.isToday == true, "Jan 11 should now be today")
    #expect(jan11Day2?.isFuture == false, "Jan 11 should not be future (it's today)")
}

@Test func dayChangeOnlyOneTodayExists() {
    let calendar = Calendar.current

    // Test multiple days to ensure only one is marked as today
    let testDates = [
        calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!,
        calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!,
        calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!
    ]

    for referenceDate in testDates {
        let yearDays = YearDay.generateYear(2026, experienceCounts: [:], calendar: calendar, referenceDate: referenceDate)
        let todayCount = yearDays.filter { $0.isToday }.count
        #expect(todayCount == 1, "Should have exactly one today for reference date \(referenceDate)")
    }
}

@Test func dayChangeFutureDaysUpdateCorrectly() {
    let calendar = Calendar.current

    // Reference: June 15
    let june15 = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!
    let yearDays = YearDay.generateYear(2026, experienceCounts: [:], calendar: calendar, referenceDate: june15)

    // Count past, today, and future days
    let pastDays = yearDays.filter { !$0.isToday && !$0.isFuture }
    let todayDays = yearDays.filter { $0.isToday }
    let futureDays = yearDays.filter { $0.isFuture }

    // June 15 is day 166 of 2026 (non-leap year: 31+28+31+30+31+15 = 166)
    // Past days: 165 (Jan 1 to Jun 14)
    // Today: 1 (Jun 15)
    // Future days: 199 (Jun 16 to Dec 31)
    #expect(pastDays.count == 165)
    #expect(todayDays.count == 1)
    #expect(futureDays.count == 199)
    #expect(pastDays.count + todayDays.count + futureDays.count == 365)
}

@Test func dayChangeMidnightTransitionPreservesExperienceCounts() {
    let calendar = Calendar.current
    let jan10 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 10))!
    let jan11 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 11))!

    // Add experience counts
    let jan10Start = calendar.startOfDay(for: jan10)
    let experienceCounts: [Date: Int] = [jan10Start: 5]

    // Before midnight (Jan 10 is today)
    let beforeMidnight = YearDay.generateYear(2026, experienceCounts: experienceCounts, calendar: calendar, referenceDate: jan10)
    let jan10Before = beforeMidnight.first { calendar.isDate($0.date, inSameDayAs: jan10) }

    #expect(jan10Before?.experienceCount == 5)
    #expect(jan10Before?.isToday == true)

    // After midnight (Jan 11 is today)
    let afterMidnight = YearDay.generateYear(2026, experienceCounts: experienceCounts, calendar: calendar, referenceDate: jan11)
    let jan10After = afterMidnight.first { calendar.isDate($0.date, inSameDayAs: jan10) }

    // Experience count should be preserved, but isToday should change
    #expect(jan10After?.experienceCount == 5, "Experience count should be preserved after midnight")
    #expect(jan10After?.isToday == false, "Jan 10 should no longer be today after midnight")
}
