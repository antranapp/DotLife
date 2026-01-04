# PRD: DotLife Moments (MVP)

## 1) Product definition

### Purpose
A minimalist “current moment” app that helps users **live now** by capturing small positive experiences and later reflecting via calm, monochrome dot matrices. It must never punish users for absence.

### One-line pitch
**Capture an experience in seconds. See time as soft dots. Tap to relive.**

### Core principles
- **Mindfulness over compliance**: no streaks, no missed indicators, no nagging.
- **Fast capture**: default flow is frictionless and one-handed.
- **Minimal surface area**: one primary input at a time; no menus unless long-press.
- **Gesture-native**: swipe-based navigation like TikTok; calm but responsive.
- **Neutral emptiness**: empty dots are texture, not failure.

---

## 2) Target platform
- **iOS 17+ only**
- iPhone first (iPad support can be “nice” but not required for MVP)

---

## 3) MVP scope

### Included (MVP)
- Two-page app (horizontal paging):
  1) **Capture**
  2) **Visualize**
- Moments user can assign at capture time:
  - **Now**, **Today**, **This Week** (locale week Mon–Sun)
- Experience types:
  - **Note**, **Photo**, **Link**, **Dot-only**
- Visualize page:
  - Vertical feed views: **Today** and **This Week**
  - Pinch + double-tap zoom between time scales (within each view)
  - Dots monochrome; fill indicates “has ≥1 experience”
  - Tap dot → **full-screen detail** (expand animation)
- Detail screen:
  - Vertical list, newest-first
  - **MomentType visible by default** as a tiny mono label per item
- Settings:
  - Customize sentence template **must include** `[moment]` and `[experience]`
  - Minimal toggles only (no deep customization in MVP)

### Explicitly excluded (post-MVP)
- Custom views (user-defined sets of experiences)
- Search, filters, tags
- Streaks, reminders, “missed” states
- Type-based dot colors (type shown only in detail)
- iCloud sync / multi-device (unless you decide otherwise)
- Rich editing (e.g., reassign moment intent, reorder, tag)

---

## 4) User stories

### Capture
1. As a user, I can open the app and immediately type a note for **now**.
2. As a user, I can switch moment intent (now/today/week) with minimal effort.
3. As a user, I can log a **photo** in two actions (choose → saved).
4. As a user, I can log “just a dot” instantly (no typing required).

### Reflect
5. As a user, I can swipe to see **Today** as hour dots and **This Week** as day dots.
6. As a user, I can pinch to zoom out to broader time scales (month/year) without UI clutter.
7. As a user, I can tap any dot to see the experiences for that time bucket.
8. As a user, I see the *intent* (“now”, “today”, “this week”) for each item in detail, subtly.

---

## 5) UX + UI specification

## Page 1: Capture
**Layout**
- Large centered sentence:
  - Default: `I appreciate [experience] for [moment]`
- Below it: one primary input element depending on experience type:
  - Note: text area
  - Photo: photo picker control
  - Link: single URL field
  - Dot: no input, just Add

**Defaults**
- moment = **now**
- experience = **note**
- keyboard opens only for note

**Controls (minimal)**
- Tap `[moment]` cycles: now → today → this week
- Tap `[experience]` cycles: note → photo → link → dot
- Long-press either placeholder: optional minimal picker sheet (discoverability)

**Save behavior**
- Note: return key saves (and clears input)
- Photo: pick a photo → auto-save immediately, return to capture
- Link: Add button saves when valid URL
- Dot: Add saves instantly

**Copy rules**
- Always positive-leaning (gratitude framing).
- No “completed” language.

---

## Page 2: Visualize
**Navigation**
- Horizontal swipe anywhere: Capture ↔ Visualize
- Vertical swipe anywhere (within Visualize): Today ↔ This Week

**Views (vertical feed)**
1) **Today view** (default landing on Visualize)
2) **This Week view**

**Dot matrix semantics**
- Monochrome theme (light/dark)
- Dot filled if bucket has ≥1 experience (regardless of experience type)
- Empty dots: very soft, background texture
- Multiple experiences in same bucket: subtle intensity increase or thin ring (no size changes)

**Zoom behavior**
- Pinch to zoom between time scales (like Photos)
- Double tap to zoom in one step; double tap again zooms out

**Suggested zoom ladders**
- Today view:
  - 24 hours → 7 days → month (days) → year (days or months)
- Week view:
  - 7 days → month → year

(Exact grid dimensions are implementation details; keep spacing and alignment perfect.)

---

## Detail screen (tap dot)
**Transition**
- Expands from tapped dot position (Photos-like feel)

**Content**
- Header: bucket label (e.g., “Tue 3pm”, “Week 03”)
- List: newest-first
- Each row:
  - type icon (small)
  - content (note text / photo thumbnail / link)
  - **momentType label visible by default** (tiny mono label e.g., “now”)

**Empty bucket**
- Calm empty state + single CTA “Add an experience”
- CTA pre-fills the correct bucket context on capture

---

## 6) Gesture spec (must be reliable)

### Required gestures
- Horizontal drag anywhere: switch between the 2 pages
- Vertical drag anywhere on Visualize: switch between views
- Pinch: zoom scale
- Double-tap: zoom step
- Tap: open detail

### Conflict resolution rule: direction lock
- On pan start, lock to horizontal or vertical based on initial movement threshold.
- Pinch always wins over paging.
- Taps must not be swallowed by paging (tap has priority when finger is stationary).

**Validation criteria**
- Diagonal swipes do not accidentally trigger both axes.
- Pinch never causes a page/view change.
- Tap dot always opens detail on first attempt.

---

## 7) Data model & semantics

### Experience (single source of truth)
Stored with:
- `id`
- `timestamp` (real time of creation)
- `momentType` = { now, today, thisWeek, … } (**keep even if capture uses only 3**)
- `experienceType` = { note, photo, link, dot }
- payload:
  - note text / URL string / local photo reference / empty
- createdAt

### Bucketing (computed)
Used for visualization aggregation:
- hour bucket (start of hour)
- day bucket (start of day)
- week bucket (ISO week, Mon–Sun)
- month/year buckets for zoomed-out states

### Key semantic guarantees
- Moments are **exclusive for filtering by intent** (momentType).
- Visualizations are **objective by time bucket** (timestamp-driven).
- “Now” has **no dedicated view**; it appears within Today/Week by timestamp, but intent remains visible in detail.

---

## 8) Technical architecture (Best-risk)

### UI framework split
- **UIKit**: gesture containers (paging + direction lock)
  - Outer horizontal pager (2 pages)
  - Inner vertical pager (2 views) inside Visualize page
- **SwiftUI**: all content views
  - CaptureView, TodayGridView, WeekGridView, DetailView, SettingsView
- **Core Data**: persistence for Experiences and attachments (photo refs)

### Why this is chosen
- “Swipe anywhere” + nested orthogonal paging + pinch/tap is most robust with UIKit’s mature gesture infrastructure.
- SwiftUI excels at the minimalist UI and the expand-to-detail polish.
- Core Data reduces migration risk as the schema grows.

---

## 9) MVP acceptance criteria

### Speed
- Launch → saved note in ≤ 2 interactions (type + return).
- Photo logging in ≤ 2 interactions (pick → saved).

### UX
- No streak UI, no missed-day indicators, no negative language.
- Empty dots feel like background texture, not failure.

### Gestures
- Swipe anywhere horizontal works on both pages.
- Visualize vertical view switching works from anywhere on the grid.
- Pinch zoom works without accidental paging.
- Tap dot reliably opens detail.

### Data integrity
- All experiences stored with timestamp + momentType + type.
- Aggregation by buckets is deterministic across timezones/locale weeks.

---

## 10) Risks & mitigations (last validation)

1) **Gesture conflicts feel “slippery”**
   - Mitigation: strict direction-lock thresholds; pinch supersedes paging; high test coverage on gestures.

2) **Empty dots feel like shame**
   - Mitigation: extremely low opacity empties; default landing on Today (hours) not Year.

3) **“I appreciate” feels forced**
   - Mitigation: template customization (placeholders required) + keep tone positive but not preachy.

4) **Photo storage complexity**
   - Mitigation: store local file references in app container; request permission only when selecting photo.

---

## Final validation checklist
- Two pages only (overlays don’t count as pages): **Yes**
- MVP moments only now/today/week: **Yes**
- Month/year appear only as zoom scales: **Yes**
- No Now view: **Yes**
- Type hidden in dots; shown in detail only: **Yes**
- Multiple experiences per bucket supported: **Yes**
- Dot-only allowed: **Yes**
- momentType visible by default in detail list: **Yes**
- Swipe anywhere horizontal + vertical feed + pinch + tap expand: **Yes**
- iOS 17+ + UIKit paging skeleton + SwiftUI content + Core Data: **Yes**
