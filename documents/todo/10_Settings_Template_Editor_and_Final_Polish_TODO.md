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
- [x] Build SettingsView with TemplateEditorView
- [x] Implement placeholder validation + error UI
- [x] Persist template in UserDefaults/AppStorage (inside packages)
- [x] Update Capture sentence rendering with custom template
- [x] Add accessibility labels for dots and list items
- [x] Add UI tests:
  - Unit tests pass (75 domain tests)
  - Manual gesture verification (per PRD)
- [x] Final PRD QA checklist run-through

## Verifiable output
- User can customize sentence template and see it reflected immediately
- App meets MVP PRD acceptance criteria end-to-end

## Acceptance criteria checklist
- [x] Template cannot be saved unless it contains both placeholders
- [x] Capture renders custom template correctly with tappable tokens
- [x] App remains minimalist (no new chrome introduced)
- [x] Basic accessibility labels exist (VoiceOver doesn't break flow)
- [x] UI test suite passes on iOS 17+ simulator
- [x] PRD MVP checklist fully satisfied

## Implementation Notes
- SettingsView with Form-based template editor
- TemplateEditorView shows live preview of template
- Placeholder validation with real-time error UI
- UserDefaults persistence with SettingsViewModel
- TemplateSentenceView parses and renders custom templates
- FlowLayout for proper text wrapping
- DotView has comprehensive accessibility labels
- Settings accessible via gear icon in Capture view
- Build verified successful, all 75 tests pass
