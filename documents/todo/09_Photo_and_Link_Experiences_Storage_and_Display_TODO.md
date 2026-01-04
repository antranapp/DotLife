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
- [x] Implement PhotoStorageService (write image + thumbnail)
- [x] Add AttachmentEntity or fields needed in Core Data model + migration (if required)
- [x] Update repository to support photo add/fetch
- [x] Implement PhotoInputView using PhotosPicker (iOS 17+)
- [x] Implement LinkInputView with URL validation
- [x] Detail row supports photo thumbnail + link open

## Verifiable output
- User can add photo in ~2 actions and see it in the correct bucket detail
- User can add a link and tap to open it

## Acceptance criteria checklist
- [x] Photo permission is requested only when selecting photo input
- [x] Photo is stored locally and persists across relaunch
- [x] Detail list renders photo thumbnails efficiently
- [x] Link validation prevents invalid saves (or clearly indicates error)
- [x] Tapping a link opens it (SFSafariViewController or openURL)

## Implementation Notes
- PhotoStorageService created in DotLifePersistence with store/retrieve/delete APIs
- Thumbnails generated at 200x200 with 0.7 JPEG compression
- PhotosPicker (iOS 16+) used for zero-permission photo selection
- URL validation auto-prepends https:// and validates host has domain
- Link input shows real-time validation feedback (checkmark/X icons)
- DetailView shows clickable photo thumbnails with full-screen view
- Links show host domain and open via SwiftUI Link component
- Build verified successful
