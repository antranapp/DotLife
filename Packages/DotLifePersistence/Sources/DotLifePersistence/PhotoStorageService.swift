import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Service for storing photos in the app's container.
/// Handles both full-size images and thumbnails.
public final class PhotoStorageService: @unchecked Sendable {
    /// The directory where photos are stored
    private let photosDirectory: URL

    /// The directory where thumbnails are stored
    private let thumbnailsDirectory: URL

    /// File manager for I/O operations
    private let fileManager: FileManager

    /// Thumbnail size for grid display
    private let thumbnailSize = CGSize(width: 200, height: 200)

    /// Shared instance
    public static let shared = PhotoStorageService()

    public init(
        photosDirectory: URL? = nil,
        thumbnailsDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.photosDirectory = photosDirectory ?? Self.defaultPhotosDirectory(fileManager: fileManager)
        self.thumbnailsDirectory = thumbnailsDirectory ?? Self.defaultThumbnailsDirectory(fileManager: fileManager)
    }

    // MARK: - Public API

    /// Stores photo data and generates a thumbnail.
    /// - Parameter data: The photo data (JPEG or PNG)
    /// - Returns: Tuple of (photoPath, thumbnailPath) as relative paths
    public func store(_ data: Data) throws -> (photoPath: String, thumbnailPath: String?) {
        try ensureDirectoriesExist()

        let photoID = UUID().uuidString

        // Store full-size photo
        let photoFilename = "\(photoID).jpg"
        let photoURL = photosDirectory.appendingPathComponent(photoFilename)
        do {
            try data.write(to: photoURL, options: [.atomic])
        } catch {
            throw PhotoStorageError.writeFailed(photoURL, error)
        }
        applyFileProtection(to: photoURL, excludeFromBackup: false)

        // Generate and store thumbnail
        var thumbnailFilename: String?
        #if canImport(UIKit)
        if let thumbnail = generateThumbnail(from: data) {
            let filename = "\(photoID)_thumb.jpg"
            let thumbnailURL = thumbnailsDirectory.appendingPathComponent(filename)
            do {
                try thumbnail.write(to: thumbnailURL, options: [.atomic])
            } catch {
                throw PhotoStorageError.writeFailed(thumbnailURL, error)
            }
            applyFileProtection(to: thumbnailURL, excludeFromBackup: true)
            thumbnailFilename = filename
        }
        #endif

        // Return relative paths (just the filenames)
        return (photoFilename, thumbnailFilename)
    }

    /// Retrieves photo data from a relative path.
    /// - Parameter relativePath: The relative path returned from store()
    /// - Returns: The photo data, or nil if not found
    public func retrievePhoto(at relativePath: String) -> Data? {
        let fullPath = photosDirectory.appendingPathComponent(relativePath)
        return try? Data(contentsOf: fullPath)
    }

    /// Retrieves thumbnail data from a relative path.
    /// - Parameter relativePath: The relative path returned from store()
    /// - Returns: The thumbnail data, or nil if not found
    public func retrieveThumbnail(at relativePath: String) -> Data? {
        let fullPath = thumbnailsDirectory.appendingPathComponent(relativePath)
        return try? Data(contentsOf: fullPath)
    }

    /// Returns the full URL for a photo path.
    public func fullPhotoURL(for relativePath: String) -> URL {
        photosDirectory.appendingPathComponent(relativePath)
    }

    /// Returns the full URL for a thumbnail path.
    public func fullThumbnailURL(for relativePath: String) -> URL {
        thumbnailsDirectory.appendingPathComponent(relativePath)
    }

    /// Deletes a photo and its thumbnail.
    /// - Parameter relativePath: The relative path of the photo
    public func delete(photoPath: String, thumbnailPath: String?) {
        let photoFullPath = photosDirectory.appendingPathComponent(photoPath)
        try? fileManager.removeItem(at: photoFullPath)

        if let thumbnailPath = thumbnailPath {
            let thumbnailFullPath = thumbnailsDirectory.appendingPathComponent(thumbnailPath)
            try? fileManager.removeItem(at: thumbnailFullPath)
        }
    }

    // MARK: - Private

    #if canImport(UIKit)
    private func generateThumbnail(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let scale = min(
            thumbnailSize.width / image.size.width,
            thumbnailSize.height / image.size.height
        )

        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let thumbnail = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return thumbnail.jpegData(compressionQuality: 0.7)
    }
    #endif

    // MARK: - Directories

    private static func defaultPhotosDirectory(fileManager: FileManager) -> URL {
        let base = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
        return base.appendingPathComponent("DotLife/Photos", isDirectory: true)
    }

    private static func defaultThumbnailsDirectory(fileManager: FileManager) -> URL {
        let base = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
        return base.appendingPathComponent("DotLife/Thumbnails", isDirectory: true)
    }

    private func ensureDirectoriesExist() throws {
        do {
            try fileManager.createDirectory(
                at: photosDirectory,
                withIntermediateDirectories: true
            )
            try fileManager.createDirectory(
                at: thumbnailsDirectory,
                withIntermediateDirectories: true
            )
        } catch {
            throw PhotoStorageError.directoryCreationFailed(error)
        }

        applyFileProtection(to: photosDirectory, excludeFromBackup: false)
        applyFileProtection(to: thumbnailsDirectory, excludeFromBackup: true)
    }

    private func applyFileProtection(to url: URL, excludeFromBackup: Bool) {
        #if os(iOS)
        try? fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        #endif

        if excludeFromBackup {
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            var mutableURL = url
            try? mutableURL.setResourceValues(values)
        }
    }
}

// MARK: - Errors

public enum PhotoStorageError: Error, Sendable {
    case directoryCreationFailed(Error)
    case writeFailed(URL, Error)
}
