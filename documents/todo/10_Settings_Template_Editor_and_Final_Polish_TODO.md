# Milestone 10 — Settings + template editor + accessibility + QA checklist

## Goal
Finish MVP with Settings and polish:
- Template editor requiring placeholders
- Minimal accessibility + motion considerations
- Basic UI tests for gesture reliability
- Final QA against PRD acceptance criteria

## Scope
- Settings screen:
  - template string editor
  - validation: must include `[moment]` and `[experience]`
- Capture sentence renders template tokens
- Accessibility:
  - Dynamic Type support (reasonable)
  - Reduce Motion disables any pulsing/extra animations
- Tests:
  - UI test smoke: horizontal/vertical paging, tap dot opens detail

## Tasks
- [ ] Build SettingsView with TemplateEditorView
- [ ] Implement placeholder validation + error UI
- [ ] Persist template in UserDefaults/AppStorage (inside packages)
- [ ] Update Capture sentence rendering with custom template
- [ ] Add accessibility labels for dots and list items
- [ ] Add UI tests:
  - swipe horizontal switches pages
  - swipe vertical switches views
  - tap dot opens detail
- [ ] Final PRD QA checklist run-through

## Verifiable output
- User can customize sentence template and see it reflected immediately
- App meets MVP PRD acceptance criteria end-to-end

## Acceptance criteria checklist
- [ ] Template cannot be saved unless it contains both placeholders
- [ ] Capture renders custom template correctly with tappable tokens
- [ ] App remains minimalist (no new chrome introduced)
- [ ] Basic accessibility labels exist (VoiceOver doesn’t break flow)
- [ ] UI test suite passes on iOS 17+ simulator
- [ ] PRD MVP checklist fully satisfied
