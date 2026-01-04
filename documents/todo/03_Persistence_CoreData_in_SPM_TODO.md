# Milestone 03 — Core Data persistence module inside SPM + repository tests

## Goal
Implement `DotLifePersistence` as a robust Core Data module packaged in SPM, including a repository conforming to the Domain protocol.

## Scope
- Core Data model packaged as resource (`.momd`) inside `DotLifePersistence`
- `CoreDataStack` loads model via `Bundle.module`
- `CoreDataExperienceRepository` implements `DotLifeDomain.ExperienceRepository`
- Minimal entities:
  - `ExperienceEntity` (id, timestamp, createdAt, momentTypeRaw, experienceTypeRaw, noteText, linkURL)
  - (Optional now, required later) `AttachmentEntity` placeholder for photo file paths

## Tasks
- [x] Add `.xcdatamodeld` to `DotLifePersistence/Resources`
- [x] Load `NSManagedObjectModel` from `Bundle.module` and create `NSPersistentContainer`
- [x] Implement repository methods:
  - add note/dot/link (photo can be stubbed until later milestone)
  - fetch by date interval
  - fetch by bucket (TimeBucket)
- [x] Add test harness using in-memory store
- [x] Add unit tests:
  - create + fetch works
  - bucket fetch returns correct records
  - momentType is preserved and returned

## Verifiable output
- `swift test` passes in `Packages/DotLifePersistence`
- Basic repository CRUD works in-memory

## Acceptance criteria checklist
- [x] Core Data model is packaged and loaded from `Bundle.module`
- [x] Repository conforms to Domain protocol
- [x] Records returned as Domain value types (UI never sees NSManagedObject)
- [x] In-memory tests cover create/fetch paths
- [x] momentType is stored and retrieved intact

## Notes
- Core Data model is created programmatically (SPM-friendly approach)
- 22 tests pass covering all CRUD operations and filtering
