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
- [ ] Add `.xcdatamodeld` to `DotLifePersistence/Resources`
- [ ] Load `NSManagedObjectModel` from `Bundle.module` and create `NSPersistentContainer`
- [ ] Implement repository methods:
  - add note/dot/link (photo can be stubbed until later milestone)
  - fetch by date interval
  - fetch by bucket (TimeBucket)
- [ ] Add test harness using in-memory store
- [ ] Add unit tests:
  - create + fetch works
  - bucket fetch returns correct records
  - momentType is preserved and returned

## Verifiable output
- `swift test` passes in `Packages/DotLifePersistence`
- Basic repository CRUD works in-memory

## Acceptance criteria checklist
- [ ] Core Data model is packaged and loaded from `Bundle.module`
- [ ] Repository conforms to Domain protocol
- [ ] Records returned as Domain value types (UI never sees NSManagedObject)
- [ ] In-memory tests cover create/fetch paths
- [ ] momentType is stored and retrieved intact
