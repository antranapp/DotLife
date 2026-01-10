# Year Visualization View - Implementation Plan

## Feature Overview
Add a Year view to the left of the Capture view, displaying a dot matrix of all 365/366 days of the current calendar year. Users swipe right from Capture to reveal the Year view.

**Navigation Order:** Year → Capture → Visualize (Year is leftmost)

---

## Design Specifications

### Grid Layout
- **Columns:** 19
- **Flow:** Left-to-right, top-to-bottom (fill row 1, then row 2, etc.)
- **Days:** 365/366 days = ~19-20 rows
- **Sizing:** Maximize dot size while maintaining consistent gaps
- **Padding:** Standard content padding (~16-20pt from edges)

### Dot Appearance
- **Shape:** Filled circle (same as existing `DotView`)
- **Colors:** Match existing theme colors
- **Reusability:** Extract common dot component for shared use

### Day States
| State | Appearance |
|-------|------------|
| Empty past day | `dotBase` color, base opacity |
| Day with 1 experience | `accent` color, `opacity(0.85)` |
| Day with 2+ experiences | `accent` color, opacity increases with count (0.9 → 1.0) |
| Future day | `dotBase` color, ~30-40% opacity (faint) |
| Today | Same as recorded style + breathing animation |

### Today Animation
- **Type:** Scale pulse (grows and shrinks)
- **Duration:** ~3 seconds per cycle (slow)
- **Scale:** 1.0 → 1.08 → 1.0
- **Easing:** `.easeInOut`
- **Repeats:** Forever, autoreverses

### Interaction
- **Tap:** None (view-only)
- **Year switching:** None (current year only)
- **Text:** None (pure dot matrix)

---

## Implementation Tasks

### Phase 1: Extract Reusable Dot Component

**Task 1.1: Create `BaseDotView` in DotLifeUI**
- Extract common dot rendering logic from `DotView.swift`
- Parameters: size, fillColor, opacity, isAnimating, animationDuration
- Support breathing animation toggle
- Location: `Packages/DotLifeUI/Sources/DotLifeUI/BaseDotView.swift`

**Task 1.2: Refactor existing `DotView` to use `BaseDotView`**
- Update `DotView.swift` to compose `BaseDotView`
- Maintain backward compatibility with existing Today/Week views
- Ensure no visual regression

### Phase 2: Create Year Grid Data Model

**Task 2.1: Create `YearDay` model in DotLifeDomain**
- Properties: date, experienceCount, isToday, isFuture
- Location: `Packages/DotLifeDomain/Sources/DotLifeDomain/Models/YearDay.swift`

**Task 2.2: Create `YearDataService` in DotLifeDomain**
- Generate array of `YearDay` for current calendar year (Jan 1 - Dec 31)
- Query experience counts per day from repository
- Location: `Packages/DotLifeDomain/Sources/DotLifeDomain/Services/YearDataService.swift`

### Phase 3: Create Year View UI

**Task 3.1: Create `YearViewModel` in DotLifeUI**
- Fetch year data on appear
- Expose `[YearDay]` for grid
- Handle refresh when experiences change
- Location: `Packages/DotLifeUI/Sources/DotLifeUI/ViewModels/YearViewModel.swift`

**Task 3.2: Create `YearDotView` in DotLifeUI**
- Specialized dot for year grid using `BaseDotView`
- Maps `YearDay` state to dot appearance
- Handles today breathing animation
- Location: `Packages/DotLifeUI/Sources/DotLifeUI/YearDotView.swift`

**Task 3.3: Create `YearGridView` in DotLifeUI**
- LazyVGrid with 19 fixed columns
- Calculates optimal dot size to fill screen
- Standard padding (16-20pt)
- No text, no labels
- Background matches theme
- Location: `Packages/DotLifeUI/Sources/DotLifeUI/YearGridView.swift`

### Phase 4: Integrate into Navigation

**Task 4.1: Modify `HorizontalPagerController` in DotLifeShell**
- Change from 2 pages to 3 pages
- Page order: Year (0) → Capture (1) → Visualize (2)
- Default to Capture (page 1) on launch
- Update content width calculation for 3 pages
- Location: `Packages/DotLifeShell/Sources/DotLifeShell/HorizontalPagerController.swift`

**Task 4.2: Update `AppBootstrapper` in DotLifeAppKit**
- Create and inject `YearViewModel`
- Wire up `YearGridView` to pager
- Location: `Packages/DotLifeAppKit/Sources/DotLifeAppKit/AppBootstrapper.swift`

**Task 4.3: Update swipe hint in Capture view (if exists)**
- Add hint for swiping right to Year view
- Or remove hints if not desired

### Phase 5: Repository Updates

**Task 5.1: Add `experienceCountsByDay` method to `ExperienceRepository`**
- Returns `[Date: Int]` dictionary for a date range
- Efficient batch query for entire year
- Location: `Packages/DotLifeDomain/Sources/DotLifeDomain/Repositories/ExperienceRepository.swift`

**Task 5.2: Implement in `CoreDataExperienceRepository`**
- Core Data fetch with date grouping
- Optimize for performance (single query)
- Location: `Packages/DotLifePersistence/Sources/DotLifePersistence/CoreDataExperienceRepository.swift`

---

## File Changes Summary

### New Files
| File | Package | Description |
|------|---------|-------------|
| `BaseDotView.swift` | DotLifeUI | Reusable dot component |
| `YearDay.swift` | DotLifeDomain | Day model for year grid |
| `YearDataService.swift` | DotLifeDomain | Year data generation service |
| `YearViewModel.swift` | DotLifeUI | Year view state management |
| `YearDotView.swift` | DotLifeUI | Year-specific dot wrapper |
| `YearGridView.swift` | DotLifeUI | Main year visualization view |

### Modified Files
| File | Package | Changes |
|------|---------|---------|
| `DotView.swift` | DotLifeUI | Refactor to use BaseDotView |
| `HorizontalPagerController.swift` | DotLifeShell | Add 3rd page for Year |
| `AppBootstrapper.swift` | DotLifeAppKit | Create YearViewModel, wire Year view |
| `ExperienceRepository.swift` | DotLifeDomain | Add experienceCountsByDay method |
| `CoreDataExperienceRepository.swift` | DotLifePersistence | Implement experienceCountsByDay |

---

## Technical Notes

### Dot Size Calculation
```swift
// Calculate optimal dot size for 19 columns
let totalHorizontalPadding = 16 * 2  // left + right
let totalHorizontalSpacing = spacing * (columns - 1)
let availableWidth = screenWidth - totalHorizontalPadding - totalHorizontalSpacing
let dotSize = availableWidth / columns
```

### Year Day Generation
```swift
// Generate all days for current calendar year
let year = Calendar.current.component(.year, from: Date())
let startOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!
let endOfYear = Calendar.current.date(from: DateComponents(year: year, month: 12, day: 31))!
// Iterate from startOfYear to endOfYear
```

### Opacity Mapping for Experience Count
```swift
func opacity(for count: Int, isFuture: Bool) -> Double {
    if isFuture { return 0.35 }
    if count == 0 { return 0.1 }
    if count == 1 { return 0.85 }
    // 2+ experiences: scale from 0.9 to 1.0
    return min(1.0, 0.9 + Double(count - 2) * 0.02)
}
```

---

## Testing Checklist
- [ ] Year view displays 365/366 dots correctly
- [ ] Dots fill screen with 19 columns
- [ ] Empty days show base color at low opacity
- [ ] Days with experiences show accent color
- [ ] Intensity increases with more experiences per day
- [ ] Future days appear faint (~35% opacity)
- [ ] Today dot has breathing animation (3 sec cycle)
- [ ] Swipe right from Capture reveals Year view
- [ ] Swipe left from Year returns to Capture
- [ ] App launches on Capture view (middle page)
- [ ] Theme colors apply correctly
- [ ] No text or labels appear on Year view
