# Adding a New Flavor

This project is a multi-brand Flutter WebView wrapper. Each flavor is a separate app (own bundle ID / application ID) that shares one Dart codebase. Use an existing flavor (`smsp` is the most recent) as a reference while following the steps below.

Replace `<flavor>` with your flavor key (lowercase, no spaces, e.g. `mybrand`) and `<BrandName>` with a PascalCase label for iOS folders (e.g. `MyBrand`).

---

## Overview

A new flavor touches four layers:

1. **Dart config** — `.env.<flavor>` loaded via `--dart-define=FLAVOR=<flavor>`
2. **Android** — `productFlavors` entry, `res/` assets, `google-services.json` client
3. **iOS** — Xcode build configurations, scheme, entitlements, Firebase plist
4. **Tooling** — `pubspec.yaml` assets, VS Code launch config, launcher icons

---

## 1. Environment file

Create `.env.<flavor>` in the project root:

```env
APP_PACKAGE_ID=com.example.mybrand
APP_ID=mybrand
CLIENT_HOST=app.example.com
CLIENT_HOST_DEBUG=192.168.0.19:1337
TAM_GID=0
APP_NAME=My Brand
VERSION_CODE=1
ANDROID_APP_ID=1:364436864658:android:xxxxxxxxxxxxxxxx
IOS_APP_ID=1:364436864658:ios:xxxxxxxxxxxxxxxx
ANDROID_CLIENT_ID=your-android-oauth-client-id
IOS_CLIENT_ID=your-ios-oauth-client-id
```

Register the app in the [Firebase console](https://console.firebase.google.com/) (project: `trackauthoritymusic`) and copy the app IDs from the generated config files.

Add the file to `pubspec.yaml` under `flutter.assets`:

```yaml
  assets:
    - .env.<flavor>
```

> `trackauthoritymusic` is a special case: its env file is `.env.tam`. All other flavors use `.env.<flavor>`.

---

## 2. Android

### 2a. Product flavor (`android/app/build.gradle`)

Add a block inside `productFlavors`:

```groovy
<flavor> {
    dimension "default"
    applicationId 'com.example.mybrand'
    resValue "string", "app_name", "My Brand"
    resValue "string", "client_host", "app.example.com"
    resValue "string", "app_id", "mybrand"
}
```

`client_host` and `app_id` power deep-link intent filters in `AndroidManifest.xml`.

### 2b. Firebase (`android/app/google-services.json`)

Add a new `client` entry for `com.example.mybrand` in the shared `google-services.json`, or download an updated file from Firebase and merge the new client into the existing multi-app JSON.

Ensure `.env.<flavor>` `ANDROID_APP_ID` matches the `mobilesdk_app_id` for that client.

### 2c. Launcher icons & splash (`android/app/src/<flavor>/res/`)

Create the flavor resource directory:

```
android/app/src/<flavor>/res/
├── drawable/
├── drawable-v21/
├── mipmap-mdpi/
├── mipmap-hdpi/
├── mipmap-xhdpi/
├── mipmap-xxhdpi/
├── mipmap-xxxhdpi/
├── values/
│   └── styles.xml
└── values-night/
    └── styles.xml
```

Copy `values/` and `launch_background.xml` from an existing flavor (e.g. `smsp`), then generate icons:

1. Add `launch_icon_<flavor>.png` and `launch_screen_<flavor>.png` to the project root.
2. Edit `icon_generator.js`:

   ```javascript
   buildAll('<flavor>', '1284x2778', '#000000');
   ```

3. Run `node icon_generator.js` (requires ImageMagick).

The manifest references `@mipmap/ic_launcher` — mipmap folders are required; `drawable/` alone is not enough.

### 2d. Verify

```bash
flutter run --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

---

## 3. iOS

### 3a. Xcode build configurations

In `ios/Runner.xcodeproj`, duplicate an existing flavor's three configurations:

- `Debug-<flavor>`
- `Release-<flavor>`
- `Profile-<flavor>`

Set `PRODUCT_BUNDLE_IDENTIFIER` to match `APP_PACKAGE_ID` from your env file (e.g. `com.example.mybrand`).

Assign entitlements files (copy from an existing flavor and rename):

- `Runner/RunnerDebug-<flavor>.entitlements`
- `Runner/RunnerRelease-<flavor>.entitlements`
- `Runner/RunnerProfile-<flavor>.entitlements`

Update associated domains / push capabilities in each entitlements file for the new `client_host`.

### 3b. Env xcconfig

Create `ios/Flutter/env/<flavor>.xcconfig`:

```
APP_NAME=My Brand
APP_ID=mybrand
```

### 3c. Xcode scheme

Duplicate `ios/Runner.xcodeproj/xcshareddata/xcschemes/smsp.xcscheme` → `<flavor>.xcscheme`.

In the scheme's **Build** pre-action, update the copy script to use your xcconfig:

```
cp "${SRCROOT}/Flutter/env/<flavor>.xcconfig" "${SRCROOT}/Flutter/tmp.xcconfig"
```

Set each action's build configuration to `Debug-<flavor>`, `Profile-<flavor>`, or `Release-<flavor>` as appropriate.

### 3d. Firebase plist

Add `ios/Runner/Firebase/<BrandName>/GoogleService-Info.plist` downloaded from Firebase for the new iOS bundle ID.

### 3e. Firebase copy script (`project.pbxproj`)

In the **Copy GoogleService-Info.plist** run script build phase, add:

1. A variable: `GOOGLESERVICE_INFO_<BRAND>=${PROJECT_DIR}/${TARGET_NAME}/Firebase/<BrandName>/${GOOGLESERVICE_INFO_PLIST}`
2. A branch that copies it when `CONFIGURATION` matches `Debug-<flavor>`, `Release-<flavor>`, or `Profile-<flavor>`.

Follow the existing `SMSP` / `PickupMVP` pattern in the script.

### 3f. CocoaPods

After adding build configurations, regenerate Pods:

```bash
cd ios && pod install
```

### 3g. Launcher assets

iOS app icons and launch images are **shared** across flavors (`AppIcon.appiconset`, `LaunchImage.imageset`). Run `icon_generator.js` for the flavor you are actively developing. See [LaunchImage README](ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md) for details.

### 3h. Verify

```bash
flutter run --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

---

## 4. Tooling & IDE

### VS Code / Cursor (`.vscode/launch.json`)

```json
{
  "name": "<flavor>",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": ["--flavor", "<flavor>", "--dart-define=FLAVOR=<flavor>"]
}
```

### Optional: `env_config.dart`

Only needed for aliases. By default, `FLAVOR=mybrand` loads `.env.mybrand`. The `trackauthoritymusic` / `tam` alias loads `.env.tam`:

```dart
case 'trackauthoritymusic':
case 'tam':
  return '.env.tam';
```

### Debug WebView host

Set `CLIENT_HOST_DEBUG` in `.env.<flavor>` to the local dev server (host:port). In debug builds, `UrlService` loads this instead of `CLIENT_HOST`.

```env
CLIENT_HOST_DEBUG=192.168.0.19:1337
```

---

## 5. Checklist

- [ ] `.env.<flavor>` created with correct Firebase and host values
- [ ] `.env.<flavor>` listed in `pubspec.yaml` assets
- [ ] Android `productFlavors` entry in `build.gradle`
- [ ] Android `google-services.json` client for new package name
- [ ] `android/app/src/<flavor>/res/` with mipmap launcher icons
- [ ] iOS Debug / Release / Profile build configurations
- [ ] iOS entitlements files for the flavor
- [ ] `ios/Flutter/env/<flavor>.xcconfig`
- [ ] Xcode scheme `<flavor>.xcscheme` with pre-action script
- [ ] `ios/Runner/Firebase/<BrandName>/GoogleService-Info.plist`
- [ ] Firebase copy script updated in `project.pbxproj`
- [ ] `pod install` run
- [ ] VS Code launch configuration added
- [ ] `icon_generator.js` run with `launch_icon_<flavor>.png` / `launch_screen_<flavor>.png`
- [ ] Tested: `flutter run --flavor <flavor> --dart-define=FLAVOR=<flavor>`
- [ ] Tested: `flutter build appbundle --release --flavor <flavor> --dart-define=FLAVOR=<flavor>`

---

## Things that are shared (do not duplicate per flavor)

| Item | Location | Notes |
|------|----------|-------|
| Dart `MainActivity` | `android/.../com/trackauthoritymusic/flutter/MainActivity.kt` | Android `namespace` is shared |
| iOS `AppIcon` | `ios/Runner/Assets.xcassets/AppIcon.appiconset` | Last `icon_generator.js` run wins |
| iOS `LaunchImage` | `ios/Runner/Assets.xcassets/LaunchImage.imageset` | Same as above |
| Firebase project | `trackauthoritymusic` | Each flavor is a separate app *within* the project |
| Dart package name | `TrackAuthorityMusic` | Historical; all flavors use it |

---

## Build commands (quick reference)

```bash
# Debug
flutter run --flavor <flavor> --dart-define=FLAVOR=<flavor>

# Release APK
flutter build apk --release --flavor <flavor> --dart-define=FLAVOR=<flavor>

# Release App Bundle (Play Store)
flutter build appbundle --release --flavor <flavor> --dart-define=FLAVOR=<flavor>

# Release IPA (App Store / TestFlight)
flutter build ipa --release --flavor <flavor> --dart-define=FLAVOR=<flavor>
```

See [LaunchImage README](ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md) for troubleshooting and launch-asset details.
