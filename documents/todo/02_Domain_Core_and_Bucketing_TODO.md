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
- [ ] Implement enums and value types in `DotLifeDomain`
- [ ] Implement `TimeBucketingService` with deterministic behavior (timezone-aware)
- [ ] Implement `GridScale` zoom ladder mapping (Today/Week view level-to-scale mapping as constants)
- [ ] Add unit tests:
  - week start Monday
  - day/hour normalization
  - leap year day counts (365/366)
  - stable bucket ID generation

## Verifiable output
- Domain package builds independently
- Unit tests pass via `swift test` within `Packages/DotLifeDomain`

## Acceptance criteria checklist
- [ ] Week bucketing uses Monday as first day
- [ ] Buckets normalize correctly for hour/day/week/month/year
- [ ] Leap years are handled (365 vs 366)
- [ ] Bucket sequences for Today (24 hours) and Week (7 days) are correct
- [ ] Domain has no UI or persistence dependencies
- [ ] All tests pass

## Notes
Keep Domain free of `UIKit`, `SwiftUI`, `CoreData`.
