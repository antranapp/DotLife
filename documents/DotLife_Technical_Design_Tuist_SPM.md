# DotLife Technical Design — Tuist + Swift Package Manager + Modular Architecture (iOS 17+)

This document defines the **technical architecture** and **project scaffolding** for DotLife using:

- **Tuist** for project/workspace generation (no manual `.xcodeproj` editing)
- **Swift Package Manager (SPM)** for all application code modules
- **UIKit** for the gesture/paging shell (nested orthogonal pagers + direction lock)
- **SwiftUI** for UI content (capture, grids, detail, settings)
- **Core Data** for persistence (packaged inside an SPM module)

> **Design goal:** The **App target** stays extremely thin (only `DotLifeApp.swift` + `AppDelegate.swift`).  
> All real implementation lives inside SPM packages.

---

## 1) Repository Layout

```
DotLife/
  Tuist/
    Config.swift
    Package.swift                  # Tuist-managed SPM resolution (local + remote)

  Project.swift                    # App target only
  Workspace.swift                  # Optional

  DotLifeApp/                      # App target sources ONLY
    Sources/
      DotLifeApp.swift
      AppDelegate.swift
    Resources/
    SupportingFiles/
      Info.plist

  Packages/                        # All code lives here
    DotLifeDomain/
      Package.swift
      Sources/...
      Tests/...

    DotLifePersistence/
      Package.swift
      Sources/...
      Resources/                   # Core Data model bundle (momd)
      Tests/...

    DotLifeUI/
      Package.swift
      Sources/...
      Tests/...

    DotLifeShell/
      Package.swift
      Sources/...
      Tests/...

    DotLifeAppKit/
      Package.swift
      Sources/...
      Tests/...
```

---

## 2) Package Responsibilities & Dependency Rules

### Packages

**DotLifeDomain (pure Swift)**
- Enums: `MomentType`, `ExperienceType`, `GridScale`
- Value types: `TimeBucket`, `TimeBucketSummary`, requests/records
- Services: `TimeBucketingService`, `GridAggregationService`
- Protocols: `ExperienceRepository` (and supporting DTOs)

**DotLifePersistence (Core Data)**
- Core Data model (`.xcdatamodeld` compiled to `.momd`) packaged as a resource
- `CoreDataStack` + `CoreDataExperienceRepository` implementing `ExperienceRepository`
- Photo file storage helper (write to app container, store local paths)

**DotLifeUI (SwiftUI)**
- Capture UI, dot grids, zoom controller, detail UI, settings
- View models depend on **Domain protocols**, not Core Data types

**DotLifeShell (UIKit gesture shell)**
- Outer horizontal pager (2 pages): Capture ↔ Visualize
- Inner vertical pager (2 pages): Today ↔ Week
- Direction-lock and gesture arbitration
- Hosts SwiftUI via `UIHostingController`

**DotLifeAppKit (composition root)**
- Boots services, repositories, Core Data stack
- Constructs the root UIKit shell or SwiftUI wrapper
- Exposes a minimal bootstrap API to the app target:
  - `configure()`
  - `makeRootView()` (SwiftUI) or `makeRootViewController()` (UIKit)

### Allowed dependency direction

✅ Allowed imports:
- `DotLifeUI` → `DotLifeDomain`
- `DotLifeShell` → `DotLifeUI`, `DotLifeDomain`
- `DotLifePersistence` → `DotLifeDomain`
- `DotLifeAppKit` → all packages

❌ Disallowed:
- `DotLifeDomain` importing anything
- `DotLifeUI` importing Core Data
- `DotLifeShell` importing persistence
- Persistence importing UI

This keeps the architecture modular and prevents coupling.

---

## 3) Tuist Configuration

### 3.1 `Tuist/Config.swift`

```swift
import ProjectDescription

let config = Config(
  compatibleXcodeVersions: .upToNextMajor("16.0"),
  generationOptions: [
    .disableShowEnvironmentVarsInScriptPhases
  ]
)
```

### 3.2 Tuist-managed SPM resolution: `Tuist/Package.swift`

This avoids fragile local-package linkage patterns and centralizes dependency resolution for Tuist.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "DotLifeDependencies",
  platforms: [.iOS(.v17)],
  products: [],
  dependencies: [
    .package(path: "../Packages/DotLifeDomain"),
    .package(path: "../Packages/DotLifePersistence"),
    .package(path: "../Packages/DotLifeUI"),
    .package(path: "../Packages/DotLifeShell"),
    .package(path: "../Packages/DotLifeAppKit")
  ]
)
```

> Later, remote dependencies can also be added here.

---

## 4) Tuist Project Definition (App Target Only)

### `Project.swift`

```swift
import ProjectDescription

let project = Project(
  name: "DotLife",
  targets: [
    .target(
      name: "DotLifeApp",
      destinations: .iOS,
      product: .app,
      bundleId: "com.yourcompany.dotlife",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .file(path: "DotLifeApp/SupportingFiles/Info.plist"),
      sources: ["DotLifeApp/Sources/**"],
      resources: ["DotLifeApp/Resources/**"],
      dependencies: [
        .external(name: "DotLifeAppKit")
      ]
    )
  ]
)
```

### Optional `Workspace.swift`

```swift
import ProjectDescription

let workspace = Workspace(
  name: "DotLife",
  projects: ["."]
)
```

---

## 5) App Target (Ultra-thin)

### `DotLifeApp/Sources/DotLifeApp.swift`

```swift
import SwiftUI
import DotLifeAppKit

@main
struct DotLifeApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      AppBootstrapper.makeRootView()
    }
  }
}
```

### `DotLifeApp/Sources/AppDelegate.swift`

```swift
import UIKit
import DotLifeAppKit

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    AppBootstrapper.configure()
    return true
  }
}
```

All other code lives in packages.

---

## 6) Composition Root (DotLifeAppKit)

### Responsibilities
- Initialize persistence stack and repositories
- Create domain services
- Create SwiftUI view models
- Assemble the UIKit shell and host SwiftUI views
- Provide the app target minimal APIs

### Public API (recommended)
- `public enum AppBootstrapper { ... }`
  - `public static func configure()`
  - `public static func makeRootView() -> some View`
  - (optional) `public static func makeRootViewController() -> UIViewController`

### Root construction approach
- Preferred: `makeRootView()` returns a `UIViewControllerRepresentable` that wraps the UIKit root controller.

---

## 7) UIKit Gesture Shell (DotLifeShell)

### Structure
- **RootHorizontalPagerController**
  - Horizontal paging between:
    - Capture page (SwiftUI)
    - Visualize page (vertical pager controller)
- **VisualizeVerticalPagerController**
  - Vertical paging between:
    - Today view (SwiftUI)
    - This Week view (SwiftUI)

### Gesture arbitration requirements
- Horizontal swipe anywhere switches pages
- Vertical swipe anywhere (visualize) switches views
- Pinch (grid zoom) must **not** trigger paging
- Tap dot must open detail reliably

### Direction-lock strategy
- Axis lock after small threshold (e.g., 12pt)
- Decide horizontal vs vertical using ratio threshold (e.g., 1.2x)
- Disable competing pager while locked
- Re-enable both on gesture end/cancel
- Expose a flag from SwiftUI grids: `isPinching` to temporarily disable both pagers

---

## 8) SwiftUI UI Layer (DotLifeUI)

### Major screens
- **CaptureView**
  - Sentence template with tappable placeholders: `[moment]`, `[experience]`
  - One primary input element (note/photo/link/dot)
  - Default: `now + note`, keyboard open only for note
- **Visualize Views**
  - Today and Week views
  - Dot matrix (monochrome)
  - Pinch/double-tap zoom ladder to month/year scales
- **Detail**
  - Full-screen expand animation
  - Vertical list of experiences
  - **MomentType label visible by default** as tiny mono label per row
- **Settings**
  - Template editor: must include `[moment]` and `[experience]`

### MVVM boundary
- View models depend on `ExperienceRepository` protocol from Domain
- No Core Data types in UI packages

---

## 9) Persistence Layer (DotLifePersistence)

### Core Data inside a Swift Package
- Store `.xcdatamodeld` in `DotLifePersistence/Resources`
- Load model via `Bundle.module`
- Construct `NSPersistentContainer` with the loaded model

### Entities (MVP)
- `ExperienceEntity`
  - `id: UUID`
  - `timestamp: Date`
  - `createdAt: Date`
  - `momentTypeRaw: Int16`
  - `experienceTypeRaw: Int16`
  - `noteText: String?`
  - `linkURL: String?`
  - `attachment: AttachmentEntity?`
- `AttachmentEntity` (photo)
  - `id: UUID`
  - `typeRaw: Int16`
  - `localPath: String`
  - `thumbnailPath: String?` (optional)

### Repository API
- Implement Domain’s `ExperienceRepository`:
  - add note/link/dot/photo
  - fetch by date interval
  - fetch by bucket for detail view

---

## 10) Commands & Workflow

### Install dependencies (SPM resolution)
- `tuist install`

### Generate Xcode project
- `tuist generate`

### Visualize the module graph (optional)
- `tuist graph`

---

## 11) Guardrails (Non-negotiables)

- App target contains **only** root `App` + `AppDelegate`
- No business logic in app target
- No Core Data usage in UI packages
- No persistence imports in UIKit shell
- All code shipped via packages

---

## 12) Next implementation steps

1. Create the five packages with `swift package init` (library), placed under `Packages/`
2. Add `Tuist/Package.swift` local package references
3. Create `Project.swift` for the app target and depend on `DotLifeAppKit`
4. Implement `AppBootstrapper` in `DotLifeAppKit`
5. Implement Core Data stack in `DotLifePersistence`
6. Implement UIKit pagers + direction lock in `DotLifeShell`
7. Implement SwiftUI screens in `DotLifeUI`
