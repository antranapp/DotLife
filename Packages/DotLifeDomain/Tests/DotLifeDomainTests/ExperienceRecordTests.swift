import Testing
import Foundation
import DotLifeDomain

// MARK: - ExperienceRecord Tests

@Test func experienceRecordCreation() {
    let id = UUID()
    let timestamp = Date()
    let createdAt = Date()

    let record = ExperienceRecord(
        id: id,
        timestamp: timestamp,
        createdAt: createdAt,
        momentType: .now,
        experienceType: .note,
        noteText: "Test note"
    )

    #expect(record.id == id)
    #expect(record.timestamp == timestamp)
    #expect(record.createdAt == createdAt)
    #expect(record.momentType == .now)
    #expect(record.experienceType == .note)
    #expect(record.noteText == "Test note")
    #expect(record.linkURL == nil)
    #expect(record.photoLocalPath == nil)
}

@Test func experienceRecordWithLink() {
    let id = UUID()
    let url = URL(string: "https://example.com")!

    let record = ExperienceRecord(
        id: id,
        timestamp: Date(),
        createdAt: Date(),
        momentType: .today,
        experienceType: .link,
        linkURL: url
    )

    #expect(record.experienceType == .link)
    #expect(record.linkURL == url)
    #expect(record.noteText == nil)
}

@Test func experienceRecordWithPhoto() {
    let id = UUID()

    let record = ExperienceRecord(
        id: id,
        timestamp: Date(),
        createdAt: Date(),
        momentType: .thisWeek,
        experienceType: .photo,
        photoLocalPath: "/path/to/photo.jpg",
        photoThumbnailPath: "/path/to/thumbnail.jpg"
    )

    #expect(record.experienceType == .photo)
    #expect(record.photoLocalPath == "/path/to/photo.jpg")
    #expect(record.photoThumbnailPath == "/path/to/thumbnail.jpg")
}

@Test func experienceRecordDotOnly() {
    let id = UUID()

    let record = ExperienceRecord(
        id: id,
        timestamp: Date(),
        createdAt: Date(),
        momentType: .now,
        experienceType: .dot
    )

    #expect(record.experienceType == .dot)
    #expect(record.noteText == nil)
    #expect(record.linkURL == nil)
    #expect(record.photoLocalPath == nil)
}

@Test func experienceRecordHashable() {
    let id = UUID()
    let timestamp = Date()

    let record1 = ExperienceRecord(
        id: id,
        timestamp: timestamp,
        createdAt: timestamp,
        momentType: .now,
        experienceType: .note,
        noteText: "Test"
    )

    let record2 = ExperienceRecord(
        id: id,
        timestamp: timestamp,
        createdAt: timestamp,
        momentType: .now,
        experienceType: .note,
        noteText: "Test"
    )

    #expect(record1 == record2)
}

// MARK: - ExperienceCreateRequest Tests

@Test func createRequestNote() {
    let request = ExperienceCreateRequest.note("Test note", momentType: .now)

    #expect(request.momentType == .now)
    #expect(request.experienceType == .note)
    #expect(request.noteText == "Test note")
    #expect(request.linkURL == nil)
    #expect(request.photoData == nil)
}

@Test func createRequestLink() {
    let url = URL(string: "https://example.com")!
    let request = ExperienceCreateRequest.link(url, momentType: .today)

    #expect(request.momentType == .today)
    #expect(request.experienceType == .link)
    #expect(request.linkURL == url)
    #expect(request.noteText == nil)
}

@Test func createRequestPhoto() {
    let data = Data([0x00, 0x01, 0x02])
    let request = ExperienceCreateRequest.photo(data, momentType: .thisWeek)

    #expect(request.momentType == .thisWeek)
    #expect(request.experienceType == .photo)
    #expect(request.photoData == data)
    #expect(request.noteText == nil)
}

@Test func createRequestDot() {
    let request = ExperienceCreateRequest.dot(momentType: .now)

    #expect(request.momentType == .now)
    #expect(request.experienceType == .dot)
    #expect(request.noteText == nil)
    #expect(request.linkURL == nil)
    #expect(request.photoData == nil)
}

// MARK: - ExperienceFetchRequest Tests

@Test func fetchRequestForBucket() {
    let date = Date()
    let bucket = TimeBucket(type: .day, start: date)
    let request = ExperienceFetchRequest.forBucket(bucket)

    #expect(request.startDate == bucket.start)
    #expect(request.endDate == bucket.end)
}

@Test func fetchRequestWithFilters() {
    let request = ExperienceFetchRequest(
        startDate: Date(),
        endDate: Date().addingTimeInterval(3600),
        momentTypes: [.now, .today],
        experienceTypes: [.note],
        limit: 10,
        offset: 5
    )

    #expect(request.momentTypes?.count == 2)
    #expect(request.experienceTypes?.count == 1)
    #expect(request.limit == 10)
    #expect(request.offset == 5)
}
