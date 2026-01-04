import CoreData
import Foundation

/// Core Data entity for storing photo attachments.
public final class AttachmentEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var typeRaw: Int16
    @NSManaged public var localPath: String
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var experience: ExperienceEntity?
}

// MARK: - Attachment Type

extension AttachmentEntity {
    /// Attachment type enumeration.
    public enum AttachmentType: Int16 {
        case photo = 0
    }

    /// The attachment type as an enum.
    public var attachmentType: AttachmentType {
        get { AttachmentType(rawValue: typeRaw) ?? .photo }
        set { typeRaw = newValue.rawValue }
    }
}

// MARK: - Fetch Requests

extension AttachmentEntity {
    /// Creates a fetch request for all attachments.
    public static func fetchRequest() -> NSFetchRequest<AttachmentEntity> {
        NSFetchRequest<AttachmentEntity>(entityName: "AttachmentEntity")
    }

    /// Creates a fetch request for a specific ID.
    public static func fetchRequest(byID id: UUID) -> NSFetchRequest<AttachmentEntity> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return request
    }
}
