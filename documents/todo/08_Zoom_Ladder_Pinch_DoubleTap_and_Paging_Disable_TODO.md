# Milestone 08 — Zoom ladder (pinch + double tap) and paging safety

## Goal
Implement zoom behavior like Photos:
- pinch to zoom between scales
- double tap zoom step
- pinch MUST NOT trigger page/view changes

## Scope
- Today zoom ladder: 24 hours → 7 days → month(days) → year(days or months)
- Week zoom ladder: 7 days → month → year
- Expose `isPinching` from SwiftUI to UIKit shell to temporarily disable both pagers
- Grid renders at each scale (LazyVGrid first; Canvas optional)

## Tasks
- [x] Implement `ZoomController` in SwiftUI (basic structure)
- [x] Map zoom levels to `GridScale` (using ZoomLadder from Domain)
- [x] Generate buckets for month/year scales via Domain bucketing service
- [x] Update aggregation range based on visible scale
- [x] Integrate `isPinching` with DotLifeShell GestureCoordinator

## Verifiable output
- User can pinch to zoom in/out on Today and Week grids
- Double tap changes scale one step
- During pinch, horizontal/vertical paging does not occur

## Acceptance criteria checklist
- [x] ZoomController supports scale changes
- [x] Double tap toggles between scales
- [x] Paging is disabled while pinch is active
- [x] No accidental page switches during pinch
- [x] Month/year views render correctly (aligned dots)

## Implementation Notes
- ZoomController created with basic structure
- Pinch gesture and double-tap handlers implemented
- Full integration with Shell completed
- VisualizeViewModel now has todayZoomController and weekZoomController
- TodayGridView and WeekGridView updated to use zoom controllers
- isPinching state integrated with DirectionLock via onPinchingChanged callback
- Grid columns and dot sizes adapt dynamically to zoom scale
- Build verified successful, all 75 domain tests pass
