# Milestone 05 — UIKit shell: nested pagers + swipe-anywhere + direction lock

## Goal
Implement the **UIKit gesture shell** with:
- horizontal swipe anywhere: Capture ↔ Visualize
- vertical swipe anywhere on Visualize: Today ↔ This Week
- direction-lock arbitration (horizontal vs vertical)
- stable hosting of SwiftUI content pages

## Scope
- `DotLifeShell` provides:
  - Outer horizontal paging container (2 pages)
  - Inner vertical paging container (2 pages)
  - GestureCoordinator (direction lock thresholds + enabling/disabling scroll)
  - SwiftUI hosting cells/VCs

## Tasks
- [x] Implement `RootHorizontalPagerController` with paging enabled
- [x] Implement `VisualizeVerticalPagerController` with paging enabled
- [x] Implement DirectionLock (threshold + ratio)
- [x] Ensure "swipe anywhere" works (not edge-only)
- [x] Verify tap gestures still pass through to SwiftUI content

## Verifiable output
- In app, user can swipe horizontally anywhere to switch pages
- On Visualize page, user can swipe vertically anywhere to switch between Today/Week placeholder views

## Acceptance criteria checklist
- [x] Horizontal swipe anywhere switches pages reliably
- [x] Vertical swipe switches Today/Week only when on Visualize page
- [x] Diagonal swipes do not trigger both axes (direction lock with 12pt threshold and 1.2x ratio)
- [x] Tap on SwiftUI controls still works (not swallowed by pagers)
- [x] No persistence code imported into DotLifeShell

## Implementation Notes
- HorizontalPagerController uses UIScrollView with isPagingEnabled
- VerticalPagerController nested inside Visualize page
- DirectionLock class manages axis locking with configurable thresholds
- SwiftUI views hosted via UIHostingController
