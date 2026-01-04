import CoreData
import Foundation
import DotLifeDomain

/// Core Data implementation of ExperienceRepository.
public final class CoreDataExperienceRepository: ExperienceRepository, @unchecked Sendable {
    private let stack: CoreDataStack
    private let photoStorage: PhotoStorageService

    public init(
        stack: CoreDataStack = .shared,
        photoStorage: PhotoStorageService = .shared
    ) {
        self.stack = stack
        self.photoStorage = photoStorage
    }

    // MARK: - Create

    public func create(_ request: ExperienceCreateRequest) async throws -> ExperienceRecord {
        // Handle photo storage outside of Core Data context (file I/O)
        var photoPaths: (photoPath: String, thumbnailPath: String?)?
        if let photoData = request.photoData {
            do {
                let storage = photoStorage
                photoPaths = try await Task.detached(priority: .utility) {
                    try storage.store(photoData)
                }.value
            } catch {
                throw ExperienceRepositoryError.photoStorageFailed(error)
            }
        }

        do {
            return try await stack.performBackgroundTask { context in
                let entity = ExperienceEntity(context: context)
                entity.id = UUID()
                entity.timestamp = request.timestamp
                entity.createdAt = Date()
                entity.momentType = request.momentType
                entity.experienceType = request.experienceType
                entity.noteText = request.noteText
                entity.linkURLValue = request.linkURL

                // Create attachment if photo was stored
                if let paths = photoPaths {
                    let attachment = AttachmentEntity(context: context)
                    attachment.id = UUID()
                    attachment.attachmentType = .photo
                    attachment.localPath = paths.photoPath
                    attachment.thumbnailPath = paths.thumbnailPath
                    entity.attachment = attachment
                }

                return entity.toRecord()
            }
        } catch {
            if let paths = photoPaths {
                photoStorage.delete(photoPath: paths.photoPath, thumbnailPath: paths.thumbnailPath)
            }
            throw ExperienceRepositoryError.saveFailed(error)
        }
    }

    // MARK: - Fetch

    public func fetch(_ request: ExperienceFetchRequest) async throws -> [ExperienceRecord] {
        try await stack.performBackgroundTask { context in
            let fetchRequest = ExperienceEntity.fetchRequest()

            // Build predicates
            var predicates: [NSPredicate] = []

            if let startDate = request.startDate {
                predicates.append(NSPredicate(
                    format: "timestamp >= %@",
                    startDate as NSDate
                ))
            }

            if let endDate = request.endDate {
                predicates.append(NSPredicate(
                    format: "timestamp < %@",
                    endDate as NSDate
                ))
            }

            if let momentTypes = request.momentTypes, !momentTypes.isEmpty {
                let rawValues = momentTypes.map { $0.rawValue }
                predicates.append(NSPredicate(
                    format: "momentTypeRaw IN %@",
                    rawValues
                ))
            }

            if let experienceTypes = request.experienceTypes, !experienceTypes.isEmpty {
                let rawValues = experienceTypes.map { $0.rawValue }
                predicates.append(NSPredicate(
                    format: "experienceTypeRaw IN %@",
                    rawValues
                ))
            }

            if !predicates.isEmpty {
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }

            // Sort by timestamp descending (newest first)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \ExperienceEntity.timestamp, ascending: false)
            ]

            // Apply limit and offset
            if let limit = request.limit {
                fetchRequest.fetchLimit = limit
            }
            if let offset = request.offset {
                fetchRequest.fetchOffset = offset
            }

            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toRecord() }
        }
    }

    public func fetch(byID id: UUID) async throws -> ExperienceRecord? {
        try await stack.performBackgroundTask { context in
            let fetchRequest = ExperienceEntity.fetchRequest(byID: id)
            let entity = try context.fetch(fetchRequest).first
            return entity?.toRecord()
        }
    }

    // MARK: - Delete

    public func delete(byID id: UUID) async throws {
        let attachmentPaths = try await stack.performBackgroundTask { context -> (String, String?)? in
            let fetchRequest = ExperienceEntity.fetchRequest(byID: id)
            guard let entity = try context.fetch(fetchRequest).first else {
                throw ExperienceRepositoryError.notFound(id)
            }

            let photoPath = entity.attachment?.localPath
            let thumbnailPath = entity.attachment?.thumbnailPath
            context.delete(entity)

            if let photoPath = photoPath {
                return (photoPath, thumbnailPath)
            }
            return nil
        }

        if let paths = attachmentPaths {
            photoStorage.delete(photoPath: paths.0, thumbnailPath: paths.1)
        }
    }

    // MARK: - Summaries

    public func summaries(for buckets: [TimeBucket]) async throws -> [TimeBucketSummary] {
        try await stack.performBackgroundTask { context in
            var results: [TimeBucketSummary] = []

            for bucket in buckets {
                let count = try self.countExperiences(in: bucket, context: context)
                results.append(TimeBucketSummary(bucket: bucket, count: count))
            }

            return results
        }
    }

    public func count(in bucket: TimeBucket) async throws -> Int {
        try await stack.performBackgroundTask { context in
            try self.countExperiences(in: bucket, context: context)
        }
    }

    // MARK: - Private Helpers

    private func countExperiences(in bucket: TimeBucket, context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = ExperienceEntity.fetchRequest(
            from: bucket.start,
            to: bucket.end
        )
        return try context.count(for: fetchRequest)
    }
}
