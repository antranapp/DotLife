import CoreData

/// Creates the Core Data managed object model programmatically.
/// This approach is SPM-friendly and doesn't require a .xcdatamodeld file.
enum CoreDataModel {
    static let modelName = "DotLife"
    private static let sharedModel: NSManagedObjectModel = createSharedModel()

    /// Creates the managed object model with all entities defined.
    static func createModel() -> NSManagedObjectModel {
        sharedModel
    }

    private static func createSharedModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Create Experience entity
        let experienceEntity = NSEntityDescription()
        experienceEntity.name = "ExperienceEntity"
        experienceEntity.managedObjectClassName = NSStringFromClass(ExperienceEntity.self)

        // Experience attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = false

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        let momentTypeRawAttribute = NSAttributeDescription()
        momentTypeRawAttribute.name = "momentTypeRaw"
        momentTypeRawAttribute.attributeType = .integer16AttributeType
        momentTypeRawAttribute.isOptional = false
        momentTypeRawAttribute.defaultValue = Int16(0)

        let experienceTypeRawAttribute = NSAttributeDescription()
        experienceTypeRawAttribute.name = "experienceTypeRaw"
        experienceTypeRawAttribute.attributeType = .integer16AttributeType
        experienceTypeRawAttribute.isOptional = false
        experienceTypeRawAttribute.defaultValue = Int16(0)

        let noteTextAttribute = NSAttributeDescription()
        noteTextAttribute.name = "noteText"
        noteTextAttribute.attributeType = .stringAttributeType
        noteTextAttribute.isOptional = true

        let linkURLAttribute = NSAttributeDescription()
        linkURLAttribute.name = "linkURL"
        linkURLAttribute.attributeType = .stringAttributeType
        linkURLAttribute.isOptional = true

        experienceEntity.properties = [
            idAttribute,
            timestampAttribute,
            createdAtAttribute,
            momentTypeRawAttribute,
            experienceTypeRawAttribute,
            noteTextAttribute,
            linkURLAttribute
        ]

        // Create Attachment entity (placeholder for photos)
        let attachmentEntity = NSEntityDescription()
        attachmentEntity.name = "AttachmentEntity"
        attachmentEntity.managedObjectClassName = NSStringFromClass(AttachmentEntity.self)

        let attachmentIdAttribute = NSAttributeDescription()
        attachmentIdAttribute.name = "id"
        attachmentIdAttribute.attributeType = .UUIDAttributeType
        attachmentIdAttribute.isOptional = false

        let attachmentTypeRawAttribute = NSAttributeDescription()
        attachmentTypeRawAttribute.name = "typeRaw"
        attachmentTypeRawAttribute.attributeType = .integer16AttributeType
        attachmentTypeRawAttribute.isOptional = false
        attachmentTypeRawAttribute.defaultValue = Int16(0)

        let localPathAttribute = NSAttributeDescription()
        localPathAttribute.name = "localPath"
        localPathAttribute.attributeType = .stringAttributeType
        localPathAttribute.isOptional = false

        let thumbnailPathAttribute = NSAttributeDescription()
        thumbnailPathAttribute.name = "thumbnailPath"
        thumbnailPathAttribute.attributeType = .stringAttributeType
        thumbnailPathAttribute.isOptional = true

        attachmentEntity.properties = [
            attachmentIdAttribute,
            attachmentTypeRawAttribute,
            localPathAttribute,
            thumbnailPathAttribute
        ]

        // Create relationship between Experience and Attachment
        let attachmentRelationship = NSRelationshipDescription()
        attachmentRelationship.name = "attachment"
        attachmentRelationship.destinationEntity = attachmentEntity
        attachmentRelationship.minCount = 0
        attachmentRelationship.maxCount = 1
        attachmentRelationship.isOptional = true
        attachmentRelationship.deleteRule = .cascadeDeleteRule

        let experienceRelationship = NSRelationshipDescription()
        experienceRelationship.name = "experience"
        experienceRelationship.destinationEntity = experienceEntity
        experienceRelationship.minCount = 0
        experienceRelationship.maxCount = 1
        experienceRelationship.isOptional = true
        experienceRelationship.deleteRule = .nullifyDeleteRule

        // Set inverse relationships
        attachmentRelationship.inverseRelationship = experienceRelationship
        experienceRelationship.inverseRelationship = attachmentRelationship

        // Add relationships to entities
        experienceEntity.properties.append(attachmentRelationship)
        attachmentEntity.properties.append(experienceRelationship)

        // Set entities on model
        model.entities = [experienceEntity, attachmentEntity]

        return model
    }
}
