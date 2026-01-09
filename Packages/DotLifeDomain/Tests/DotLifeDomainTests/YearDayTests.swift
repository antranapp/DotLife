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
