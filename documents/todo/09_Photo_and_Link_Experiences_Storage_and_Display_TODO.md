# Milestone 09 — Photo + Link experiences (capture, storage, display)

## Goal
Complete the remaining experience types:
- Photo: picker → save locally → show in detail
- Link: validate → save → show in detail and open

## Scope
- Capture UI supports experience type cycling to photo/link
- Permissions:
  - Photo permission requested only when user chooses photo experience
- Persistence:
  - Save photo to app container, store local path in Core Data
- UI:
  - Detail list shows photo thumbnail rows and link rows

## Tasks
- [ ] Implement PhotoStorageService (write image + thumbnail)
- [ ] Add AttachmentEntity or fields needed in Core Data model + migration (if required)
- [ ] Update repository to support photo add/fetch
- [ ] Implement PhotoInputView using PhotosPicker (iOS 17+)
- [ ] Implement LinkInputView with URL validation
- [ ] Detail row supports photo thumbnail + link open

## Verifiable output
- User can add photo in ~2 actions and see it in the correct bucket detail
- User can add a link and tap to open it

## Acceptance criteria checklist
- [ ] Photo permission is requested only when selecting photo input
- [ ] Photo is stored locally and persists across relaunch
- [ ] Detail list renders photo thumbnails efficiently
- [ ] Link validation prevents invalid saves (or clearly indicates error)
- [ ] Tapping a link opens it (SFSafariViewController or openURL)
