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
- [ ] Implement `RootHorizontalPagerController` with paging enabled
- [ ] Implement `VisualizeVerticalPagerController` with paging enabled
- [ ] Implement DirectionLock (threshold + ratio)
- [ ] Ensure “swipe anywhere” works (not edge-only)
- [ ] Verify tap gestures still pass through to SwiftUI content

## Verifiable output
- In app, user can swipe horizontally anywhere to switch pages
- On Visualize page, user can swipe vertically anywhere to switch between Today/Week placeholder views

## Acceptance criteria checklist
- [ ] Horizontal swipe anywhere switches pages reliably
- [ ] Vertical swipe switches Today/Week only when on Visualize page
- [ ] Diagonal swipes do not trigger both axes
- [ ] Tap on SwiftUI controls still works (not swallowed by pagers)
- [ ] No persistence code imported into DotLifeShell
