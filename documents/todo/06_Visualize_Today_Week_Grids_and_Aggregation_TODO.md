# Milestone 06 — Visualize MVP: Today + Week dot grids + tap-to-detail entry point

## Goal
Replace Visualize placeholders with **real dot grids**:
- Today: 24 hour dots
- Week: 7 day dots
Dots fill if bucket has ≥1 experience (monochrome).

## Scope
- `DotLifeUI` Visualize views:
  - `TodayGridView` (24 hours)
  - `WeekGridView` (7 days)
- Aggregation:
  - Fetch experiences in date range
  - Aggregate into bucket summaries
- Tap dot:
  - Opens Detail screen (can be minimal placeholder list in this milestone)

## Tasks
- [x] Implement aggregation using Domain bucketing
- [x] Implement Today grid rendering (LazyVGrid ok)
- [x] Implement Week grid rendering
- [x] Dot styling per PRD (empty ultra-soft, filled normal, multi slightly stronger)
- [x] Tap dot selects bucket and presents detail (placeholder ok if list not done yet)

## Verifiable output
- Adding experiences on Capture reflects in Today/Week dot grids (after navigating)
- Tap a filled dot navigates/presents a detail view for that bucket

## Acceptance criteria checklist
- [x] Today view shows 24 aligned dots
- [x] Week view shows 7 aligned dots
- [x] Filled dot iff bucket has >=1 experience
- [x] Multi-experience bucket has subtle stronger appearance (no size change)
- [x] Tap dot reliably opens a detail entry point

## Implementation Notes
- VisualizeViewModel manages data for both grids
- DotView component with opacity-based fill intensity
- LazyVGrid with 6-column layout for Today view
- HStack for Week view (7 days)
- DetailView created but bucket selection action prepared
