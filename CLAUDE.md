# DotLife project instructions

- Target iOS 17+; use modern Swift and Swift concurrency where appropriate.
- Follow `documents/DotLife_Moments_MVP_PRD.md` and `documents/DotLife_Technical_Design_Tuist_SPM.md`.
- Use Tuist + SPM; do not manually edit `.xcodeproj` or `.xcworkspace`.
- Prefer Tuist commands for build/run/test workflows (e.g. `tuist generate` then Xcode, or `tuist` task equivalents when available).
- Keep `DotLifeApp` ultra-thin (only app + app delegate); implement everything in packages.
- Respect package boundaries: Domain is pure, Persistence owns Core Data, UI is SwiftUI, Shell is UIKit, AppKit composes.
- Gesture shell: direction-lock paging, pinch wins, tap targets must be reliable.
- Preserve the minimalist UX: no streaks, no negative empty states, monochrome dots.
