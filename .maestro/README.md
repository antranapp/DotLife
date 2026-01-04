# DotLife Maestro Tests

End-to-end UI tests for DotLife using [Maestro](https://maestro.mobile.dev/).

## Prerequisites

1. Install Maestro:
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   ```

2. Build the app for simulator:
   ```bash
   tuist generate
   xcodebuild -workspace DotLife.xcworkspace -scheme DotLifeApp \
     -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
     build
   ```

3. Have an iOS Simulator running (iOS 17+):
   ```bash
   open -a Simulator
   # Or use a specific device:
   xcrun simctl boot "iPhone 15 Pro"
   ```

## Running Tests

### Run all tests
```bash
cd /path/to/DotLife
maestro test .maestro/flows/
```

### Run a specific flow
```bash
maestro test .maestro/flows/01_smoke.yaml
```

### Run with a specific device
```bash
maestro test --device "iPhone 16" .maestro/flows/
```

### Run in CI (headless)
```bash
maestro test --format junit --output results.xml .maestro/flows/
```

## Test Flows

| Flow | Description |
|------|-------------|
| `01_smoke.yaml` | App launch and default state verification |
| `02_capture_note.yaml` | Add note experience via return key |
| `03_capture_dot.yaml` | Add dot-only experience |
| `04_capture_link.yaml` | Add link with URL validation |
| `05_visualize_paging.yaml` | Horizontal/vertical paging navigation |
| `06_zoom_gestures.yaml` | Double-tap zoom through scale ladder |
| `07_detail_view.yaml` | Tap dot opens detail, view experiences |
| `08_settings.yaml` | Template editor with validation |

## CI Integration

For GitHub Actions:
```yaml
- name: Run Maestro Tests
  uses: mobile-dev-inc/action-maestro-cloud@v1
  with:
    api-key: ${{ secrets.MAESTRO_CLOUD_API_KEY }}
    app-file: DotLife.app
    flows: .maestro/flows/
```

For local CI runners, ensure Xcode and Simulator are available,
then run the tests with `maestro test`.

## Notes

- Photo picker tests require the simulator to have photos in the library
- Pinch gestures are limited in Maestro; manual verification recommended
- Tests assume a clean app state (clear simulator data before running)
