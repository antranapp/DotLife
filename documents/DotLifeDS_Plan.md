# DotLifeDS Plan (Design System + Theming)

## Goals
- Create a new Swift package `DotLifeDS` as the design system for DotLife.
- Support 5 pre-defined color schemes from `documents/research/color_scheme.md`.
- Provide semantic tokens (colors, typography, spacing, radii) with SwiftUI + UIKit access.
- Add a theme manager with persistence and user-selectable light/dark override.
- Default theme: **Option 2 (Paper & Ink)**.
- Update all UI to use the semantic tokens (no legacy colors).

## Detailed Steps

### 1) Create Package: DotLifeDS
- Add new package at `Packages/DotLifeDS` with iOS 17+ target.
- Export public API for tokens and theming:
  - `Theme` model (id, name, palette).
  - `ThemePalette` (semantic colors).
  - `ThemeTypography` (fonts, sizes, weights).
  - `ThemeSpacing` (spacing scale).
  - `ThemeRadii` (corner radius scale).
- Add SwiftUI + UIKit bridges:
  - `Color` tokens for SwiftUI.
  - `UIColor` tokens for UIKit (DotLifeShell).

### 2) Define Semantic Tokens
- Colors:
  - `appBackground`, `surface`, `textPrimary`, `textSecondary`, `accent`, `dotBase`.
- Typography:
  - Body, caption, title, mono label styles as `Font` and `UIFont`.
- Spacing:
  - A small scale (e.g., 4, 8, 12, 16, 24, 32).
- Radii:
  - A small scale (e.g., 6, 10, 16).

### 3) Implement Color Palettes (Options 1–5)
- Encode light/dark hex values for each semantic token using `color_scheme.md`.
- Create themes:
  - Morning Mist
  - Paper & Ink (default)
  - Forest Floor
  - Ceramic
  - Twilight

### 4) Theme Manager
- Add `ThemeManager` in `DotLifeDS` or `DotLifeAppKit` (depending on dependency needs).
- Responsibilities:
  - Current selected theme (persisted in `UserDefaults`).
  - Light/dark override per theme (user-selectable).
  - Resolve effective palette based on override or system scheme.
- Provide SwiftUI integration:
  - `@Observable` or `ObservableObject` with environment injection.
- Provide UIKit integration:
  - Expose `UIColor` lookups based on current theme state.

### 5) Wire Into App Composition
- Add `DotLifeDS` to Tuist dependencies.
- Update `DotLifeAppKit` to initialize `ThemeManager`.
- Inject theme into SwiftUI root view and UIKit shell (DotLifeShell).

### 6) Update UI to Use Tokens (Full Migration)
- Replace all custom colors with semantic tokens across `DotLifeUI`:
  - Capture screen
  - Visualize views
  - Detail screen
  - Settings
- Ensure the dot matrix uses `dotBase` with opacity rules.
- Ensure text styles use typography tokens.

### 7) Settings: Theme Selector
- Add a theme selection UI in Settings:
  - List or cards showing theme name and palette preview.
  - Default selection: Paper & Ink.
  - Provide an explicit light/dark override control.
- Persist selection via ThemeManager.

### 8) Verify & Polish
- Check light/dark appearance for all themes.
- Validate dot visibility for empty vs filled states.
- Ensure UIKit shell backgrounds match `appBackground`/`surface`.

## Deliverables
- New `Packages/DotLifeDS` package.
- Updated dependencies in Tuist configuration.
- Theme manager with persistence + overrides.
- All UI using semantic tokens.
- Settings theme selector UI.
