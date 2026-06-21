# Launch Screen Assets & Build Guide

This folder holds iOS launch-screen images (`LaunchImage.imageset`). For a full checklist when onboarding a new brand, see [ADDING_FLAVORS.md](../../../../ADDING_FLAVORS.md) at the project root.

---

## Launch screen assets

### Generate from source images

Place these files in the **project root** (not in this folder):

- `launch_icon_<flavor>.png` — square app icon source
- `launch_screen_<flavor>.png` — launch/splash banner source

Then edit `icon_generator.js` at the project root and run:

```bash
# Uncomment or add a line like:
# buildAll('<flavor>', '<size>', '<bgColor>');

node icon_generator.js
```

Example:

```javascript
buildAll('smsp', '1284x2778', '#000000');
```

This updates:

- **iOS launch images** → `LaunchImage.imageset/` (this folder)
- **iOS app icons** → `AppIcon.appiconset/` (shared across all flavors)
- **Android icons** → `android/app/src/<flavor>/res/`

> **Note:** iOS `AppIcon` and `LaunchImage` are shared by every flavor. Regenerating assets for one brand overwrites iOS icons/launch screens for all brands. Android assets are per-flavor.

### Manual replacement

Open the Xcode workspace and drop images into the asset catalog:

```bash
open ios/Runner.xcworkspace
```

Select `Runner/Assets.xcassets` → `LaunchImage` in the Project Navigator.

---

## Critical rule: always pass both flags

`--flavor` controls the **native** Android/iOS build variant (bundle ID, app name, Firebase plist, icons).

`--dart-define=FLAVOR=...` controls the **Dart** tenant config (`.env` file, WebView URL, Firebase app IDs).

They must use the **same flavor name**. If `FLAVOR` is omitted, Dart defaults to `trackauthoritymusic`.

---

## Available flavors

| Flavor | Android `applicationId` | Env file |
|--------|-------------------------|----------|
| `pickupmvp` | `com.pickupmvp` | `.env.pickupmvp` |
| `rapruler` | `com.therapruler` | `.env.rapruler` |
| `trackauthoritymusic` | `com.trackauthoritymusic` | `.env.tam` |
| `smsp` | `com.smsp.myapp` | `.env.smsp` |

---

## Debug builds

### Command line (device or emulator)

```bash
flutter run --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

Examples:

```bash
flutter run --flavor smsp --dart-define=FLAVOR=smsp
flutter run --flavor pickupmvp --dart-define=FLAVOR=pickupmvp
flutter run --flavor rapruler --dart-define=FLAVOR=rapruler
flutter run --flavor trackauthoritymusic --dart-define=FLAVOR=trackauthoritymusic
```

### VS Code / Cursor

Use a launch configuration from `.vscode/launch.json` (pickupmvp, rapruler, tam, smsp). Each config already passes matching `--flavor` and `--dart-define=FLAVOR=...` args.

### iOS simulator

Same `flutter run` command as above. Flutter selects the matching Xcode scheme (`smsp`, `pickupmvp`, etc.) from the `--flavor` value.

### Verify the correct tenant loaded

In debug mode, the console should print:

```
running flavor: <flavor>
```

If that line is missing or shows `trackauthoritymusic` while you intended another brand, `--dart-define=FLAVOR=...` was not applied.

### After changing icons or native config

Uninstall the old app from the device, then do a full rebuild (hot reload does not refresh launcher icons or native assets):

```bash
# Android — replace package name with the flavor's applicationId
adb uninstall com.smsp.myapp

flutter run --flavor smsp --dart-define=FLAVOR=smsp
```

Optional clean if native builds act stale:

```bash
flutter clean && flutter pub get
```

---

## Release builds

### Prerequisites

- **Android:** `android/key.properties` must point at your upload keystore (see `android/key.properties.example` if present, or create from your keystore).
- **iOS:** Valid signing certificates and provisioning profiles for the flavor's bundle ID in Xcode.
- **Both:** Correct `.env.<flavor>` values (especially `ANDROID_APP_ID`, `IOS_APP_ID`, `CLIENT_HOST`).

### Android APK (sideload / internal testing)

```bash
flutter build apk --release --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

Output: `build/app/outputs/flutter-apk/app-<flavor>-release.apk`

Example:

```bash
flutter build apk --release --flavor smsp --dart-define=FLAVOR=smsp
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

Output: `build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab`

Examples:

```bash
flutter build appbundle --release --flavor trackauthoritymusic --dart-define=FLAVOR=trackauthoritymusic
flutter build appbundle --release --flavor pickupmvp --dart-define=FLAVOR=pickupmvp
flutter build appbundle --release --flavor rapruler --dart-define=FLAVOR=rapruler
flutter build appbundle --release --flavor smsp --dart-define=FLAVOR=smsp
```

### iOS (App Store / TestFlight)

```bash
flutter build ipa --release --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

Example:

```bash
flutter build ipa --release --flavor smsp --dart-define=FLAVOR=smsp
```

Output: `build/ios/ipa/*.ipa`

You can also archive from Xcode: open `ios/Runner.xcworkspace`, select the flavor scheme (e.g. `smsp`), then **Product → Archive**.

---

## Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| Wrong website loads | `--dart-define=FLAVOR=...` missing or mismatched with `--flavor` |
| Wrong launcher icon (Android) | Flavor missing `mipmap-*/ic_launcher.png`; falls back to `android/app/src/main/res/` |
| `ClassNotFoundException: ...MainActivity` | Native rebuild needed after Android package changes; uninstall old app |
| iOS icon wrong after generating another brand | iOS `AppIcon` is shared — re-run `icon_generator.js` for the flavor you are building |
| Firebase init errors | `.env.<flavor>` app IDs don't match `google-services.json` / `GoogleService-Info.plist` |
