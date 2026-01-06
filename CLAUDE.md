## Project Structure

- Target iOS 17+; use modern Swift and Swift concurrency where appropriate.
- Follow `documents/DotLife_Moments_MVP_PRD.md` and `documents/DotLife_Technical_Design_Tuist_SPM.md`.
- Use Tuist + SPM; do not manually edit `.xcodeproj` or `.xcworkspace`.
- Prefer Tuist commands for build/run/test workflows (e.g. `tuist generate` then Xcode, or `tuist` task equivalents when available).
- Respect package boundaries: Domain is pure, Persistence owns Core Data, UI is SwiftUI, Shell is UIKit, AppKit composes.

## Running & Testing with XcodeBuildMCP

### Setup (run once per session)
```
1. list_sims → find a booted simulator UUID (or boot one)
2. session-set-defaults:
   - workspacePath: /Users/antran/Projects/iOS/Indie/DotLife/DotLife.xcworkspace
   - scheme: DotLifeApp
   - simulatorId: <UUID>
```

### Build & Run
```
build_run_sim → builds and launches app on simulator
```

### Gesture Testing
Screen size: 402x874 (iPhone 17 Pro). Use center Y (~437) for horizontal swipes.

| Action | Command |
|--------|---------|
| Swipe left (→ Visualize) | `swipe x1:350 y1:437 x2:50 y2:437 duration:0.3` |
| Swipe right (→ Capture) | `swipe x1:50 y1:437 x2:350 y2:437 duration:0.3` |
| Swipe up (→ Week view) | `swipe x1:200 y1:600 x2:200 y2:200 duration:0.3` |
| Swipe down (→ Today view) | `swipe x1:200 y1:200 x2:200 y2:600 duration:0.3` |
| Verify state | `screenshot` |

## Plan mode

-  Present the question in multiple choice style and enummarate the question and answer for easy answering