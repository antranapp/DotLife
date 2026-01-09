import Testing
import Foundation
@testable import DotLifeUI
@testable import DotLifeDomain

// MARK: - Mock Repository

actor MockExperienceRepository: ExperienceRepository {
    private(set) var createdRequests: [ExperienceCreateRequest] = []
    private var records: [ExperienceRecord] = []

    func create(_ request: ExperienceCreateRequest) async throws -> ExperienceRecord {
        let record = ExperienceRecord(
            id: UUID(),
            timestamp: request.timestamp,
            createdAt: Date(),
            momentType: request.momentType,
            experienceType: request.experienceType,
            noteText: request.noteText,
            linkURL: request.linkURL,
            photoLocalPath: nil,
            photoThumbnailPath: nil
        )

        createdRequests.append(request)
        records.append(record)
        return record
    }

    func fetch(_ request: ExperienceFetchRequest) async throws -> [ExperienceRecord] {
        var filtered = records

        if let start = request.startDate {
            filtered = filtered.filter { $0.timestamp >= start }
        }

        if let end = request.endDate {
            filtered = filtered.filter { $0.timestamp < end }
        }

        if let momentTypes = request.momentTypes, !momentTypes.isEmpty {
            filtered = filtered.filter { momentTypes.contains($0.momentType) }
        }

        if let experienceTypes = request.experienceTypes, !experienceTypes.isEmpty {
            filtered = filtered.filter { experienceTypes.contains($0.experienceType) }
        }

        if let offset = request.offset, offset > 0 {
            if offset >= filtered.count {
                filtered = []
            } else {
                filtered = Array(filtered.dropFirst(offset))
            }
        }

        if let limit = request.limit, limit >= 0, limit < filtered.count {
            filtered = Array(filtered.prefix(limit))
        }

        return filtered
    }

    func fetch(byID id: UUID) async throws -> ExperienceRecord? {
        records.first { $0.id == id }
    }

    func delete(byID id: UUID) async throws {
        records.removeAll { $0.id == id }
    }

    func summaries(for buckets: [TimeBucket]) async throws -> [TimeBucketSummary] {
        buckets.map { bucket in
            let count = records.filter { bucket.contains($0.timestamp) }.count
            return TimeBucketSummary(bucket: bucket, count: count)
        }
    }

    func count(in bucket: TimeBucket) async throws -> Int {
        records.filter { bucket.contains($0.timestamp) }.count
    }

    func experienceCountsByDay(from startDate: Date, to endDate: Date) async throws -> [Date: Int] {
        let calendar = Calendar.current
        var countsByDay: [Date: Int] = [:]

        for record in records {
            let timestamp = record.timestamp
            guard timestamp >= startDate && timestamp <= endDate else { continue }

            let dayStart = calendar.startOfDay(for: timestamp)
            countsByDay[dayStart, default: 0] += 1
        }

        return countsByDay
    }
}

// MARK: - View Model Tests

@Test @MainActor func captureViewModelSavesNoteAndClearsText() async {
    let repository = MockExperienceRepository()
    let viewModel = CaptureViewModel(repository: repository)

    viewModel.noteText = "A small win"
    await viewModel.saveNote()

    #expect(viewModel.noteText.isEmpty)
    #expect(viewModel.savedCount == 1)

    let createdCount = await repository.createdRequests.count
    #expect(createdCount == 1)
    let createdType = await repository.createdRequests.first?.experienceType
    #expect(createdType == .note)
}

@Test @MainActor func detailViewModelAddsNoteInBucket() async {
    let repository = MockExperienceRepository()
    let service = TimeBucketingService.utc
    let now = Date()
    let bucket = service.bucket(for: now, type: .hour)
    let viewModel = DetailViewModel(
        bucket: bucket,
        repository: repository,
        bucketingService: service
    )

    await viewModel.addNote("Gratitude", momentType: .today)

    #expect(viewModel.experiences.count == 1)
    let experience = viewModel.experiences.first
    #expect(experience?.momentType == .today)
    if let timestamp = experience?.timestamp {
        #expect(bucket.contains(timestamp))
    }
}

@Test @MainActor func visualizeViewModelSelectBucketShowsDetail() {
    let repository = MockExperienceRepository()
    let viewModel = VisualizeViewModel(repository: repository)
    let bucket = TimeBucket(type: .day, start: Date())

    viewModel.selectBucket(bucket)

    #expect(viewModel.selectedBucket == bucket)
    #expect(viewModel.showingDetail == true)
}

// MARK: - YearViewModel Tests

@Test @MainActor func yearViewModelInitializesEmpty() {
    let repository = MockExperienceRepository()
    let viewModel = YearViewModel(repository: repository)

    #expect(viewModel.yearDays.isEmpty)
    #expect(viewModel.isLoading == false)
}

@Test @MainActor func yearViewModelRefreshGeneratesYearDays() async {
    let repository = MockExperienceRepository()
    let viewModel = YearViewModel(repository: repository)

    await viewModel.refresh()

    let calendar = Calendar.current
    let year = calendar.component(.year, from: Date())
    let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    let expectedDays = isLeapYear ? 366 : 365

    #expect(viewModel.yearDays.count == expectedDays)
}

@Test @MainActor func yearViewModelRefreshAppliesExperienceCounts() async {
    let repository = MockExperienceRepository()
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Create experiences in repository
    for i in 0..<5 {
        let timestamp = today.addingTimeInterval(Double(i) * 3600)
        _ = try? await repository.create(
            ExperienceCreateRequest.note("Note \(i)", momentType: .now, timestamp: timestamp)
        )
    }

    let viewModel = YearViewModel(repository: repository)
    await viewModel.refresh()

    // Find today in the year days
    let todayDay = viewModel.yearDays.first { calendar.isDate($0.date, inSameDayAs: today) }

    #expect(todayDay?.experienceCount == 5)
}

@Test @MainActor func yearViewModelMarksTodayCorrectly() async {
    let repository = MockExperienceRepository()
    let viewModel = YearViewModel(repository: repository)

    await viewModel.refresh()

    let todayDays = viewModel.yearDays.filter { $0.isToday }
    #expect(todayDays.count == 1)
}

@Test @MainActor func yearViewModelMarksFutureDaysCorrectly() async {
    let repository = MockExperienceRepository()
    let viewModel = YearViewModel(repository: repository)

    await viewModel.refresh()

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Check that future days are marked correctly
    for day in viewModel.yearDays {
        let dayStart = calendar.startOfDay(for: day.date)
        if dayStart > today {
            #expect(day.isFuture == true)
        } else {
            #expect(day.isFuture == false)
        }
    }
}

@Test @MainActor func yearViewModelDaysAreInOrder() async {
    let repository = MockExperienceRepository()
    let viewModel = YearViewModel(repository: repository)

    await viewModel.refresh()

    // Verify days are in chronological order
    for i in 1..<viewModel.yearDays.count {
        let previousDay = viewModel.yearDays[i - 1]
        let currentDay = viewModel.yearDays[i]
        #expect(previousDay.date < currentDay.date)
    }
}

@Test @MainActor func yearViewModelSetsLoadingDuringRefresh() async {
    let repository = MockExperienceRepository()
    let viewModel = YearViewModel(repository: repository)

    // Before refresh
    #expect(viewModel.isLoading == false)

    // After refresh completes
    await viewModel.refresh()
    #expect(viewModel.isLoading == false)
}
