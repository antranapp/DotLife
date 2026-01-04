import CoreData
import Foundation

/// Core Data stack for DotLife persistence.
/// Supports both persistent (SQLite) and in-memory storage.
public final class CoreDataStack: @unchecked Sendable {
    /// Shared instance for app-wide use
    public static let shared = CoreDataStack()

    /// The managed object model
    private let managedObjectModel: NSManagedObjectModel

    /// The persistent container
    public let container: NSPersistentContainer

    /// View context for main thread operations
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    /// Creates a Core Data stack with persistent storage.
    public convenience init() {
        self.init(inMemory: false)
    }

    /// Creates a Core Data stack.
    /// - Parameter inMemory: If true, uses in-memory store (for testing).
    public init(inMemory: Bool) {
        self.managedObjectModel = CoreDataModel.createModel()

        // Create container with programmatic model
        self.container = NSPersistentContainer(
            name: CoreDataModel.modelName,
            managedObjectModel: managedObjectModel
        )

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Creates a new background context.
    public func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    /// Performs work on a background context and saves.
    public func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    if context.hasChanges {
                        try context.save()
                    }
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Saves the view context if it has changes.
    public func saveViewContext() throws {
        let context = viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}

// MARK: - Testing Support

extension CoreDataStack {
    /// Creates an in-memory stack for testing.
    public static func inMemory() -> CoreDataStack {
        CoreDataStack(inMemory: true)
    }
}
