import Testing
import Foundation
import CoreData
@testable import DotLifePersistence
@testable import DotLifeDomain

// MARK: - Module Tests

@Test func moduleVersionExists() async throws {
    #expect(DotLifePersistenceModule.version == "0.1.0")
}

// MARK: - Core Data Stack Tests

@Test func coreDataStackInitializesInMemory() async throws {
    let stack = CoreDataStack.inMemory()
    // The type can be "InMemory" or "NSInMemoryStoreType" depending on the system
    let storeType = stack.container.persistentStoreDescriptions.first?.type ?? ""
    #expect(storeType.contains("InMemory") || storeType == NSInMemoryStoreType)
}

@Test func coreDataStackViewContextExists() async throws {
    let stack = CoreDataStack.inMemory()
    #expect(stack.viewContext.persistentStoreCoordinator != nil)
}

// MARK: - Repository Create Tests

@Test func repositoryCreatesNoteExperience() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.note("Test note", momentType: .now)
    let record = try await repository.create(request)

    #expect(record.momentType == .now)
    #expect(record.experienceType == .note)
    #expect(record.noteText == "Test note")
}

@Test func repositoryCreatesDotExperience() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.dot(momentType: .today)
    let record = try await repository.create(request)

    #expect(record.momentType == .today)
    #expect(record.experienceType == .dot)
    #expect(record.noteText == nil)
}

@Test func repositoryCreatesLinkExperience() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let url = URL(string: "https://example.com")!
    let request = ExperienceCreateRequest.link(url, momentType: .thisWeek)
    let record = try await repository.create(request)

    #expect(record.momentType == .thisWeek)
    #expect(record.experienceType == .link)
    #expect(record.linkURL == url)
}

@Test func repositoryGeneratesUniqueIDs() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request1 = ExperienceCreateRequest.dot(momentType: .now)
    let request2 = ExperienceCreateRequest.dot(momentType: .now)

    let record1 = try await repository.create(request1)
    let record2 = try await repository.create(request2)

    #expect(record1.id != record2.id)
}

// MARK: - Repository Fetch Tests

@Test func repositoryFetchesByID() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.note("Test note", momentType: .now)
    let created = try await repository.create(request)

    let fetched = try await repository.fetch(byID: created.id)

    #expect(fetched != nil)
    #expect(fetched?.id == created.id)
    #expect(fetched?.noteText == "Test note")
}

@Test func repositoryReturnsNilForNonexistentID() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let fetched = try await repository.fetch(byID: UUID())

    #expect(fetched == nil)
}

@Test func repositoryFetchesByDateRange() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let now = Date()
    let hourAgo = now.addingTimeInterval(-3600)
    let twoHoursAgo = now.addingTimeInterval(-7200)

    // Create experiences at different times
    let request1 = ExperienceCreateRequest.note("Recent", momentType: .now, timestamp: now)
    let request2 = ExperienceCreateRequest.note("Hour ago", momentType: .now, timestamp: hourAgo)
    let request3 = ExperienceCreateRequest.note("Two hours ago", momentType: .now, timestamp: twoHoursAgo)

    _ = try await repository.create(request1)
    _ = try await repository.create(request2)
    _ = try await repository.create(request3)

    // Fetch only last 90 minutes
    let fetchRequest = ExperienceFetchRequest(
        startDate: now.addingTimeInterval(-5400), // 90 minutes ago
        endDate: now.addingTimeInterval(60) // 1 minute from now
    )
    let results = try await repository.fetch(fetchRequest)

    #expect(results.count == 2)
}

@Test func repositoryFetchesSortedByTimestampDescending() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let now = Date()
    let earlier = now.addingTimeInterval(-3600)

    let request1 = ExperienceCreateRequest.note("Earlier", momentType: .now, timestamp: earlier)
    let request2 = ExperienceCreateRequest.note("Now", momentType: .now, timestamp: now)

    _ = try await repository.create(request1)
    _ = try await repository.create(request2)

    let results = try await repository.fetch(ExperienceFetchRequest())

    #expect(results.count == 2)
    #expect(results[0].noteText == "Now") // Newest first
    #expect(results[1].noteText == "Earlier")
}

// MARK: - Bucket Fetch Tests

@Test func repositoryFetchesByBucket() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)
    let bucketingService = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let now = Date()
    let bucket = bucketingService.bucket(for: now, type: .hour)

    // Create experience in this bucket
    let request = ExperienceCreateRequest.note("In bucket", momentType: .now, timestamp: now)
    _ = try await repository.create(request)

    // Fetch by bucket
    let fetchRequest = ExperienceFetchRequest.forBucket(bucket)
    let results = try await repository.fetch(fetchRequest)

    #expect(results.count == 1)
    #expect(results[0].noteText == "In bucket")
}

@Test func repositoryCountsExperiencesInBucket() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)
    let bucketingService = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let now = Date()
    let bucket = bucketingService.bucket(for: now, type: .hour)

    // Create multiple experiences in this bucket
    for i in 0..<5 {
        let request = ExperienceCreateRequest.note("Note \(i)", momentType: .now, timestamp: now)
        _ = try await repository.create(request)
    }

    let count = try await repository.count(in: bucket)

    #expect(count == 5)
}

@Test func repositoryReturnsSummariesForBuckets() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)
    let bucketingService = TimeBucketingService(timeZone: TimeZone(identifier: "UTC")!)

    let now = Date()
    let hourBuckets = bucketingService.hourBuckets(forDayContaining: now)
    let currentBucket = bucketingService.bucket(for: now, type: .hour)

    // Create experience in current hour
    let request = ExperienceCreateRequest.note("Now", momentType: .now, timestamp: now)
    _ = try await repository.create(request)

    let summaries = try await repository.summaries(for: hourBuckets)

    #expect(summaries.count == 24)

    // Find current bucket summary
    let currentSummary = summaries.first { $0.bucket.start == currentBucket.start }
    #expect(currentSummary?.count == 1)
    #expect(currentSummary?.hasMoments == true)

    // Other buckets should be empty
    let emptySummaries = summaries.filter { $0.bucket.start != currentBucket.start }
    #expect(emptySummaries.allSatisfy { $0.count == 0 })
}

// MARK: - Moment Type Preservation Tests

@Test func repositoryPreservesMomentTypeNow() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.dot(momentType: .now)
    let created = try await repository.create(request)
    let fetched = try await repository.fetch(byID: created.id)

    #expect(fetched?.momentType == .now)
}

@Test func repositoryPreservesMomentTypeToday() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.dot(momentType: .today)
    let created = try await repository.create(request)
    let fetched = try await repository.fetch(byID: created.id)

    #expect(fetched?.momentType == .today)
}

@Test func repositoryPreservesMomentTypeThisWeek() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.dot(momentType: .thisWeek)
    let created = try await repository.create(request)
    let fetched = try await repository.fetch(byID: created.id)

    #expect(fetched?.momentType == .thisWeek)
}

// MARK: - Delete Tests

@Test func repositoryDeletesExperience() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let request = ExperienceCreateRequest.note("To delete", momentType: .now)
    let created = try await repository.create(request)

    try await repository.delete(byID: created.id)

    let fetched = try await repository.fetch(byID: created.id)
    #expect(fetched == nil)
}

@Test func repositoryDeleteThrowsForNonexistentID() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    do {
        try await repository.delete(byID: UUID())
        Issue.record("Expected error to be thrown")
    } catch {
        // Expected
        #expect(error is ExperienceRepositoryError)
    }
}

// MARK: - Attachment Cleanup Tests

@Test func repositoryDeletesPhotoFiles() async throws {
    let stack = CoreDataStack.inMemory()
    let storageRoot = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer {
        try? FileManager.default.removeItem(at: storageRoot)
    }

    let photosDirectory = storageRoot.appendingPathComponent("Photos", isDirectory: true)
    let thumbnailsDirectory = storageRoot.appendingPathComponent("Thumbnails", isDirectory: true)
    let photoStorage = PhotoStorageService(
        photosDirectory: photosDirectory,
        thumbnailsDirectory: thumbnailsDirectory
    )

    let repository = CoreDataExperienceRepository(
        stack: stack,
        photoStorage: photoStorage
    )

    let data = Data([0x01, 0x02, 0x03, 0x04])
    let record = try await repository.create(
        ExperienceCreateRequest.photo(data, momentType: .now)
    )

    guard let photoPath = record.photoLocalPath else {
        Issue.record("Expected photo path to be set")
        return
    }

    let photoURL = photoStorage.fullPhotoURL(for: photoPath)
    #expect(FileManager.default.fileExists(atPath: photoURL.path))

    try await repository.delete(byID: record.id)
    #expect(!FileManager.default.fileExists(atPath: photoURL.path))
}

// MARK: - Filter Tests

@Test func repositoryFiltersByMomentType() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    // Create experiences with different moment types
    _ = try await repository.create(ExperienceCreateRequest.dot(momentType: .now))
    _ = try await repository.create(ExperienceCreateRequest.dot(momentType: .today))
    _ = try await repository.create(ExperienceCreateRequest.dot(momentType: .thisWeek))

    let fetchRequest = ExperienceFetchRequest(momentTypes: [.now, .today])
    let results = try await repository.fetch(fetchRequest)

    #expect(results.count == 2)
    #expect(results.allSatisfy { $0.momentType == .now || $0.momentType == .today })
}

@Test func repositoryFiltersByExperienceType() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    // Create experiences with different types
    _ = try await repository.create(ExperienceCreateRequest.note("Note", momentType: .now))
    _ = try await repository.create(ExperienceCreateRequest.dot(momentType: .now))
    _ = try await repository.create(ExperienceCreateRequest.link(URL(string: "https://example.com")!, momentType: .now))

    let fetchRequest = ExperienceFetchRequest(experienceTypes: [.note])
    let results = try await repository.fetch(fetchRequest)

    #expect(results.count == 1)
    #expect(results[0].experienceType == .note)
}

@Test func repositoryAppliesLimitAndOffset() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    // Create 10 experiences
    for i in 0..<10 {
        let timestamp = Date().addingTimeInterval(Double(i) * 60) // 1 minute apart
        let request = ExperienceCreateRequest.note("Note \(i)", momentType: .now, timestamp: timestamp)
        _ = try await repository.create(request)
    }

    let fetchRequest = ExperienceFetchRequest(limit: 3, offset: 2)
    let results = try await repository.fetch(fetchRequest)

    #expect(results.count == 3)
}

// MARK: - Experience Counts By Day Tests

@Test func repositoryReturnsEmptyCountsForEmptyDatabase() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!

    let counts = try await repository.experienceCountsByDay(from: weekAgo, to: today)

    #expect(counts.isEmpty)
}

@Test func repositoryCountsExperiencesByDay() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

    // Create 3 experiences today
    for i in 0..<3 {
        let timestamp = today.addingTimeInterval(Double(i) * 3600) // 1 hour apart
        let request = ExperienceCreateRequest.note("Today \(i)", momentType: .now, timestamp: timestamp)
        _ = try await repository.create(request)
    }

    // Create 2 experiences yesterday
    for i in 0..<2 {
        let timestamp = yesterday.addingTimeInterval(Double(i) * 3600)
        let request = ExperienceCreateRequest.note("Yesterday \(i)", momentType: .now, timestamp: timestamp)
        _ = try await repository.create(request)
    }

    let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

    let counts = try await repository.experienceCountsByDay(from: weekAgo, to: tomorrow)

    #expect(counts[today] == 3)
    #expect(counts[yesterday] == 2)
}

@Test func repositoryCountsByDayRespectsDateRange() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
    let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

    // Create experiences
    _ = try await repository.create(
        ExperienceCreateRequest.note("Today", momentType: .now, timestamp: today)
    )
    _ = try await repository.create(
        ExperienceCreateRequest.note("Two days ago", momentType: .now, timestamp: twoDaysAgo)
    )
    _ = try await repository.create(
        ExperienceCreateRequest.note("Three days ago", momentType: .now, timestamp: threeDaysAgo)
    )

    // Query only last 2 days
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let counts = try await repository.experienceCountsByDay(from: yesterday, to: today)

    #expect(counts[today] == 1)
    #expect(counts[twoDaysAgo] == nil) // Outside range
    #expect(counts[threeDaysAgo] == nil) // Outside range
}

@Test func repositoryCountsByDayGroupsCorrectly() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Create experiences at different times on the same day
    let morning = today.addingTimeInterval(8 * 3600) // 8 AM
    let noon = today.addingTimeInterval(12 * 3600) // 12 PM
    let evening = today.addingTimeInterval(20 * 3600) // 8 PM

    _ = try await repository.create(
        ExperienceCreateRequest.note("Morning", momentType: .now, timestamp: morning)
    )
    _ = try await repository.create(
        ExperienceCreateRequest.note("Noon", momentType: .now, timestamp: noon)
    )
    _ = try await repository.create(
        ExperienceCreateRequest.note("Evening", momentType: .now, timestamp: evening)
    )

    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
    let counts = try await repository.experienceCountsByDay(from: yesterday, to: tomorrow)

    // All 3 experiences should be grouped under today
    #expect(counts.count == 1)
    #expect(counts[today] == 3)
}

@Test func repositoryCountsByDayIncludesAllExperienceTypes() async throws {
    let stack = CoreDataStack.inMemory()
    let repository = CoreDataExperienceRepository(stack: stack)

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Create different types of experiences
    _ = try await repository.create(
        ExperienceCreateRequest.note("Note", momentType: .now, timestamp: today)
    )
    _ = try await repository.create(
        ExperienceCreateRequest.dot(momentType: .now, timestamp: today)
    )
    _ = try await repository.create(
        ExperienceCreateRequest.link(URL(string: "https://example.com")!, momentType: .now, timestamp: today)
    )

    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
    let counts = try await repository.experienceCountsByDay(from: yesterday, to: tomorrow)

    #expect(counts[today] == 3)
}
