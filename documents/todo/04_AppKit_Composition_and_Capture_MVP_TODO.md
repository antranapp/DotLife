# Milestone 04 — AppKit composition root + Capture MVP (note + dot)

## Goal
Wire up AppKit composition so the app launches into the **Capture page** with working persistence for:
- `now + note` (keyboard open)
- `dot-only` (instant save)

## Scope
- `DotLifeAppKit` composes:
  - CoreDataStack + CoreDataExperienceRepository
  - Domain services needed by UI
  - View models
  - Root UI (may still be placeholder for Visualize)
- `DotLifeUI` implements Capture UI per PRD:
  - sentence template with tappable placeholders
  - one primary input at a time
  - defaults: moment=now, experience=note, keyboard open
  - return key saves note
  - dot saves instantly

## Tasks
- [ ] Implement `AppBootstrapper.configure()` + `makeRootView()` in `DotLifeAppKit`
- [ ] Implement CaptureView + minimal styling
- [ ] Implement placeholder Visualize view (not interactive yet)
- [ ] Ensure saves persist via repository
- [ ] Add a subtle debug indicator (e.g., count of saved experiences) behind a hidden gesture or non-invasive footer (optional)

## Verifiable output
- App runs and shows Capture with sentence + note input focused
- Notes and dots persist across relaunch (using Core Data store)

## Acceptance criteria checklist
- [ ] Default state is `now + note` with keyboard open
- [ ] Return key saves note and clears input
- [ ] Dot experience saves with one tap
- [ ] Saved items exist after app relaunch
- [ ] App target remains thin; all logic in packages
