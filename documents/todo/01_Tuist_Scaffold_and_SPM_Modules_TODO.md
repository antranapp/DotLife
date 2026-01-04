# Milestone 01 — Tuist scaffold + SPM module skeletons (iOS 17+)

## Goal
Create a fully Tuist-generated workspace and **local SPM package structure** where the **app target is ultra-thin** and compiles/runs, even if UI is placeholder.

## Scope
- Tuist config + dependency resolution (`Tuist/Config.swift`, `Tuist/Package.swift`)
- App target: `DotLifeApp.swift` + `AppDelegate.swift` only
- Local SPM packages created (empty but buildable):
  - `DotLifeDomain`
  - `DotLifePersistence`
  - `DotLifeUI`
  - `DotLifeShell`
  - `DotLifeAppKit`
- `DotLifeAppKit` exposes minimal bootstrap API used by app target:
  - `configure()`
  - `makeRootView()` returning a placeholder view (or VC wrapper)

## Tasks
- [x] Create repo folder structure as defined in technical design
- [x] Add `Tuist/Config.swift`
- [x] Add `Tuist/Package.swift` that references all local packages
- [x] Add `Project.swift` (app target only) with dependency on `.external(name: "DotLifeAppKit")`
- [x] Add minimal `DotLifeApp/SupportingFiles/Info.plist`
- [x] Create each SPM package under `Packages/` with `swift package init --type library`
- [x] Ensure each package exports at least one public symbol to avoid empty-module issues
- [x] Implement `DotLifeAppKit.AppBootstrapper` with placeholder root view
- [x] App target calls `AppBootstrapper.configure()` in AppDelegate and uses `makeRootView()` in `WindowGroup`

## Verifiable output
- `tuist install` succeeds
- `tuist generate` succeeds and opens Xcode workspace/project
- App builds and launches on an iOS 17+ simulator showing a placeholder screen (e.g., "DotLife")

## Acceptance criteria checklist
- [x] No application logic exists in app target beyond App + AppDelegate
- [x] All modules compile as SPM packages
- [x] `DotLifeAppKit` is the only dependency imported by app target code
- [x] `tuist install` and `tuist generate` succeed without manual Xcode project edits
- [x] App launches successfully (placeholder UI ok)

## Notes
Recommended command sequence:
- `tuist install`
- `tuist generate`

## Completion Notes
- Tuist.swift (renamed from Tuist/Config.swift per deprecation warning) uses `.all` for Xcode version compatibility
- All 5 SPM packages created with proper dependency hierarchy:
  - DotLifeDomain (no deps)
  - DotLifePersistence (depends on Domain)
  - DotLifeUI (depends on Domain)
  - DotLifeShell (depends on Domain, UI)
  - DotLifeAppKit (depends on all)
- Placeholder UI shows "DotLife" with dot icon
- Build verified on iPhone 16 Pro Simulator (iOS 18.5)
- App launched successfully (PID 98180)
