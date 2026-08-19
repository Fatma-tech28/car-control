# Inspection Rover — Flutter Control App

A two-page Flutter app for controlling and monitoring an Arduino/ESP32
inspection car equipped with five sensors (ultrasonic, flame, gas, PIR,
humidity & temperature).

## Run it locally

This repo ships only `lib/` + `pubspec.yaml` (no `android/`/`ios/`
folders yet). Generate them once, then run as normal:

```bash
flutter create --platforms=android --org com.inspectionrover .
flutter pub get
dart run flutter_launcher_icons
flutter run
```

Requires Flutter 3.22+ (Dart 3.3+). No hardware is required to try the
app — it runs against `MockCarConnectionService`, which simulates live
sensor data and command acknowledgements.

## Host on GitHub and get a built APK (no local Flutter needed)

A workflow at `.github/workflows/build-apk.yml` builds a release APK
for you in GitHub's cloud on every push:

1. Create a new GitHub repo and push this project to it:
   ```bash
   cd inspection_car_app
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<your-repo>.git
   git push -u origin main
   ```
2. On GitHub, open the **Actions** tab — the "Build APK" workflow runs
   automatically. When it finishes (a few minutes), open the run and
   download the **inspection-rover-apk** artifact — that's your `.apk`.
3. To also get it attached to a proper **Release** (a persistent
   download link, not just a build artifact), tag a version and push
   the tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   The workflow will attach `app-release.apk` to the Release it creates
   for that tag automatically.
4. Install the APK: download it to your Android phone (or `adb install
   app-release.apk`), then enable "install from unknown sources" if
   prompted, since it isn't signed for the Play Store.

This is a debug/unsigned release build meant for testing. For a Play
Store submission you'll need to set up your own signing key and update
`android/app/build.gradle` accordingly — happy to walk through that
when you're ready for it.

## Structure

```
lib/
  main.dart                     App entry point, theme + Provider wiring
  theme/app_theme.dart          Color tokens (brand blue ramp + dark/turquoise/pink) and ThemeData
  models/sensor_data.dart       DriveMode, DriveCommand, SensorSnapshot, CarStatus, AlertEvent, etc.
  services/car_connection_service.dart  Transport abstraction + mock implementation
  state/car_state.dart          ChangeNotifier: mode switching, obstacle-avoidance
                                 state machine, flame-escape logic, alert lifecycle
  pages/
    home_shell.dart             Bottom navigation between Control and Dashboard
    control_page.dart           Page 1 — status header, mode toggle, D-pad, Stop Alert
    dashboard_page.dart         Page 2 — four half-circle gauge cards
    sensor_detail_page.dart     Historical trend report per sensor
  widgets/
    status_header.dart
    mode_toggle.dart
    directional_pad.dart
    circular_control_button.dart
    half_gauge_painter.dart
    half_gauge_card.dart
    trend_chart.dart
    alert_overlay.dart
```

## Behavior implemented

- **Manual mode** — press-and-hold circular buttons (forward/back/left/right).
  The car moves only while a button is held and stops the instant it's
  released or the pointer leaves the button; no separate stop button.
- **Ultrasonic routine (both modes, always on)** — on obstacle detection:
  stop → reverse two steps → servo scan right → proceed if clear, else
  scan left → proceed if clear, else stay stopped and keep the alert up.
- **Auto mode** — drives forward continuously at moderate speed, running
  the same ultrasonic routine automatically.
- **Flame escape** — in Auto mode, a flame reading immediately reverses
  the car at maximum speed for a few seconds before resuming patrol; in
  both modes it raises the full-screen alert right away.
- **Alerts** — full-screen red overlay + haptic feedback (`HapticFeedback.heavyImpact`),
  persists until the operator taps **Stop Alert** on the overlay or the
  control page.
- **Dashboard** — four semi-circular gauge cards (flame, gas, PIR,
  humidity & temperature) on the light brand-blue palette; tapping a
  card opens a detail page with a historical trend chart (`fl_chart`).

## Wiring up real hardware

Everything the UI needs from the rover goes through the
`CarConnectionService` interface in `lib/services/car_connection_service.dart`.
Swap `MockCarConnectionService` for a real implementation and nothing
else in the app needs to change:

- `sendCommand(DriveCommand, speedPercent)` → e.g. `POST /command` or a
  WebSocket message `{"cmd":"forward","speed":55}`
- `sensorStream` → feed it from a WebSocket (`web_socket_channel` is
  already a dependency) or a REST polling loop hitting `GET /sensors`
- `fetchHistory(SensorKind)` → `GET /history/:kind`

A couple of hardware notes carried over from earlier discussion, worth
keeping in mind when you wire the ESP32 side:
- Keep motors on a separate power rail from the ESP32/sensor 5V rail
  (via a motor driver like an L298N/TB6612) to avoid brownouts.
- ESP32 GPIOs are 3.3V logic — level-shift any 5V sensor outputs.

## Assets & app icon

- `assets/icon/app_icon.png` — 1024×1024 full icon (dark navy background,
  pink drive-button motif, blue ring accent from the brand palette).
- `assets/icon/app_icon_foreground.png` — transparent-background version
  of the same mark, used as the Android **adaptive icon** foreground
  layer (paired with `#0A0F1C` as the adaptive background in
  `pubspec.yaml`).
- `assets/images/` — empty, reserved for any additional in-app imagery
  you add later (referenced under `flutter.assets` in `pubspec.yaml`
  once it has files in it).

Regenerating native launcher icons after changing either PNG:
```bash
dart run flutter_launcher_icons
```
This is also run automatically in CI before each APK build.

## .gitignore

The included `.gitignore` is the standard Flutter template covering
`.dart_tool/`, `build/`, IDE folders, and the platform-specific
generated files under `android/`, `ios/`, `macos/`, `windows/`, and
`linux/` once you run `flutter create`. It also excludes
`android/key.properties` and any `*.jks`/`*.keystore` files — if you
set up release signing later, keep those out of version control and
store them as GitHub Actions secrets instead.

## Notes


- State management uses `provider` (`ChangeNotifier` + `Consumer`).
- Charts use `fl_chart`; gauges are a custom `CustomPainter` so no extra
  gauge package is required.
- This environment couldn't run `flutter pub get` / `flutter analyze`
  (no Flutter SDK or pub.dev access), so the code has been reviewed by
  hand and bracket/import-checked, but please run `flutter analyze`
  once you pull it into a Flutter environment before shipping.
