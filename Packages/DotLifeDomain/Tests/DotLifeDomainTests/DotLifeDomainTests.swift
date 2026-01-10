import Testing
import Foundation
@testable import DotLifeDomain

// MARK: - Module Tests

@Test func domainModuleVersionExists() async throws {
    #expect(DotLifeDomainModule.version == "0.1.0")
}

// MARK: - MomentType Tests

@Test func momentTypeRawValues() {
    #expect(MomentType.now.rawValue == 0)
    #expect(MomentType.today.rawValue == 1)
    #expect(MomentType.thisWeek.rawValue == 2)
}

@Test func momentTypeDisplayNames() {
    #expect(MomentType.now.displayName == "now")
    #expect(MomentType.today.displayName == "today")
    #expect(MomentType.thisWeek.displayName == "this week")
}

@Test func momentTypeAllCases() {
    #expect(MomentType.allCases.count == 3)
}

// MARK: - ExperienceType Tests

@Test func experienceTypeRawValues() {
    #expect(ExperienceType.note.rawValue == 0)
    #expect(ExperienceType.photo.rawValue == 1)
    #expect(ExperienceType.link.rawValue == 2)
    #expect(ExperienceType.dot.rawValue == 3)
}

@Test func experienceTypeDisplayNames() {
    #expect(ExperienceType.note.displayName == "note")
    #expect(ExperienceType.photo.displayName == "photo")
    #expect(ExperienceType.link.displayName == "link")
    #expect(ExperienceType.dot.displayName == "dot")
}

@Test func experienceTypeAllCases() {
    #expect(ExperienceType.allCases.count == 4)
}

// MARK: - GridScale Tests

@Test func gridScaleRawValues() {
    #expect(GridScale.hours.rawValue == 0)
    #expect(GridScale.days.rawValue == 1)
    #expect(GridScale.weeks.rawValue == 2)
    #expect(GridScale.months.rawValue == 3)
}

@Test func gridScaleAllCases() {
    #expect(GridScale.allCases.count == 4)
}

// MARK: - ZoomLadder Tests

@Test func zoomLadderTodayViewScales() {
    let scales = ZoomLadder.todayViewScales
    #expect(scales == [.hours, .days, .months])
}

@Test func zoomLadderWeekViewScales() {
    let scales = ZoomLadder.weekViewScales
    #expect(scales == [.days, .months])
}

@Test func zoomLadderScalesForViewType() {
    #expect(ZoomLadder.scales(for: .today) == [.hours, .days, .months])
    #expect(ZoomLadder.scales(for: .week) == [.days, .months])
}

@Test func zoomLadderZoomOutFromHoursInTodayView() {
    let nextScale = ZoomLadder.zoomOut(from: .hours, in: .today)
    #expect(nextScale == .days)
}

@Test func zoomLadderZoomOutFromDaysInTodayView() {
    let nextScale = ZoomLadder.zoomOut(from: .days, in: .today)
    #expect(nextScale == .months)
}

@Test func zoomLadderZoomOutFromMonthsInTodayView() {
    let nextScale = ZoomLadder.zoomOut(from: .months, in: .today)
    #expect(nextScale == nil)
}

@Test func zoomLadderZoomInFromMonthsInTodayView() {
    let nextScale = ZoomLadder.zoomIn(from: .months, in: .today)
    #expect(nextScale == .days)
}

@Test func zoomLadderZoomInFromHoursInTodayView() {
    let nextScale = ZoomLadder.zoomIn(from: .hours, in: .today)
    #expect(nextScale == nil)
}

@Test func zoomLadderZoomOutFromDaysInWeekView() {
    let nextScale = ZoomLadder.zoomOut(from: .days, in: .week)
    #expect(nextScale == .months)
}

@Test func zoomLadderZoomInFromDaysInWeekView() {
    let nextScale = ZoomLadder.zoomIn(from: .days, in: .week)
    #expect(nextScale == nil)
}
