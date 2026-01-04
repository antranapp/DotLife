import CoreData
import Foundation
import DotLifeDomain

/// Core Data entity for storing experiences.
public final class ExperienceEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var createdAt: Date
    @NSManaged public var momentTypeRaw: Int16
    @NSManaged public var experienceTypeRaw: Int16
    @NSManaged public var noteText: String?
    @NSManaged public var linkURL: String?
    @NSManaged public var attachment: AttachmentEntity?
}

// MARK: - Convenience Properties

extension ExperienceEntity {
    /// The moment type as a domain enum.
    public var momentType: MomentType {
        get { MomentType(rawValue: momentTypeRaw) ?? .now }
        set { momentTypeRaw = newValue.rawValue }
    }

    /// The experience type as a domain enum.
    public var experienceType: ExperienceType {
        get { ExperienceType(rawValue: experienceTypeRaw) ?? .dot }
        set { experienceTypeRaw = newValue.rawValue }
    }

    /// The link URL as a URL object.
    public var linkURLValue: URL? {
        get {
            guard let urlString = linkURL else { return nil }
            return URL(string: urlString)
        }
        set {
            linkURL = newValue?.absoluteString
        }
    }
}

// MARK: - Conversion to Domain Type

extension ExperienceEntity {
    /// Converts this entity to a domain ExperienceRecord.
    public func toRecord() -> ExperienceRecord {
        ExperienceRecord(
            id: id,
            timestamp: timestamp,
            createdAt: createdAt,
            momentType: momentType,
            experienceType: experienceType,
            noteText: noteText,
            linkURL: linkURLValue,
            photoLocalPath: attachment?.localPath,
            photoThumbnailPath: attachment?.thumbnailPath
        )
    }
}

// MARK: - Fetch Requests

extension ExperienceEntity {
    /// Creates a fetch request for all experiences.
    public static func fetchRequest() -> NSFetchRequest<ExperienceEntity> {
        NSFetchRequest<ExperienceEntity>(entityName: "ExperienceEntity")
    }

    /// Creates a fetch request for experiences in a date range.
    public static func fetchRequest(
        from startDate: Date,
        to endDate: Date
    ) -> NSFetchRequest<ExperienceEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp < %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExperienceEntity.timestamp, ascending: false)
        ]
        return request
    }

    /// Creates a fetch request for a specific ID.
    public static func fetchRequest(byID id: UUID) -> NSFetchRequest<ExperienceEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return request
    }
}
