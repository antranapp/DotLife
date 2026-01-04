# Milestone 02 — Domain core + bucketing + unit tests

## Goal
Implement the **pure Domain** layer: types, bucketing logic, scale definitions, and unit tests (no UI, no Core Data).

## Scope
- `MomentType`, `ExperienceType`, `GridScale`
- `TimeBucket`, `TimeBucketSummary`
- `TimeBucketingService`:
  - startOfHour/day/week/month/year
  - locale week = **Mon–Sun**
  - bucket sequences for Today/Week/Month/Year
- Domain repository protocol + DTOs:
  - `ExperienceRepository`
  - `ExperienceCreateRequest`
  - `ExperienceRecord` value type

## Tasks
- [x] Implement enums and value types in `DotLifeDomain`
- [x] Implement `TimeBucketingService` with deterministic behavior (timezone-aware)
- [x] Implement `GridScale` zoom ladder mapping (Today/Week view level-to-scale mapping as constants)
- [x] Add unit tests:
  - week start Monday
  - day/hour normalization
  - leap year day counts (365/366)
  - stable bucket ID generation

## Verifiable output
- Domain package builds independently
- Unit tests pass via `swift test` within `Packages/DotLifeDomain`

## Acceptance criteria checklist
- [x] Week bucketing uses Monday as first day
- [x] Buckets normalize correctly for hour/day/week/month/year
- [x] Leap years are handled (365 vs 366)
- [x] Bucket sequences for Today (24 hours) and Week (7 days) are correct
- [x] Domain has no UI or persistence dependencies
- [x] All tests pass

## Notes
Keep Domain free of `UIKit`, `SwiftUI`, `CoreData`.
