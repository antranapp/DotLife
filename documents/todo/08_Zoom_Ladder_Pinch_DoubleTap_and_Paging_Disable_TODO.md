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
- [ ] Implement `ZoomController` in SwiftUI
- [ ] Map zoom levels to `GridScale`
- [ ] Generate buckets for month/year scales via Domain bucketing service
- [ ] Update aggregation range based on visible scale
- [ ] Integrate `isPinching` with DotLifeShell GestureCoordinator

## Verifiable output
- User can pinch to zoom in/out on Today and Week grids
- Double tap changes scale one step
- During pinch, horizontal/vertical paging does not occur

## Acceptance criteria checklist
- [ ] Pinch changes scale (no jitter)
- [ ] Double tap zooms one level and toggles back on second tap
- [ ] Paging is disabled while pinch is active
- [ ] No accidental page switches during pinch
- [ ] Month/year views render correctly (aligned dots)
