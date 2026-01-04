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
- [ ] Implement aggregation using Domain bucketing
- [ ] Implement Today grid rendering (LazyVGrid ok)
- [ ] Implement Week grid rendering
- [ ] Dot styling per PRD (empty ultra-soft, filled normal, multi slightly stronger)
- [ ] Tap dot selects bucket and presents detail (placeholder ok if list not done yet)

## Verifiable output
- Adding experiences on Capture reflects in Today/Week dot grids (after navigating)
- Tap a filled dot navigates/presents a detail view for that bucket

## Acceptance criteria checklist
- [ ] Today view shows 24 aligned dots
- [ ] Week view shows 7 aligned dots
- [ ] Filled dot iff bucket has >=1 experience
- [ ] Multi-experience bucket has subtle stronger appearance (no size change)
- [ ] Tap dot reliably opens a detail entry point
