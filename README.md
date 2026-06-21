# TAM Flutter
#### Basic WebView wrapper for all Branded Apps using WebView

# Android Test install: 
- https://play.google.com/apps/internaltest/4700937001191384768

# Build to Debug
- `flutter run --flavor smsp --dart-define=FLAVOR=smsp` (match `--flavor` and `FLAVOR`)

# Build to Release
- `flutter build appbundle --flavor trackauthoritymusic --dart-define=FLAVOR=trackauthoritymusic`
- `flutter build appbundle --flavor pickupmvp --dart-define=FLAVOR=pickupmvp`
- `flutter build appbundle --flavor rapruler --dart-define=FLAVOR=rapruler`
- `flutter build appbundle --flavor smsp --dart-define=FLAVOR=smsp`
- Release builds require `android/key.properties` pointing at your upload keystore

## Launching Options
- [x] Load startup Url embedded from .env when built  
- [ ] Load Exact url passed from Push Notification Link
- [ ] Load Exact url passed from Deep Link?
- OnLoad WebView always adds query parameters `appPlatform` (for client controls), `paddingTop` & `paddingBottom` (for safearea).

## Firebase Notification Test
- Goto [Firebase Notification](https://console.firebase.google.com/u/0/project/trackauthoritymusic/messaging)
- Click on New Campaign Button, and then click on notifications
- Add notification title and text, click NEXT and select target devices.
- Enter Schedule date and click on NEXT
- Click NEXT on Conversion event
- In the custom data, add key as "url" and value with the value you want the user to be redirected to.
- Click Review and Publish.

## Test Push Notifications:
- Get simulator device id: `xcrun simctl list 'devices' 'booted'`
- `xcrun simctl push A1A523A9-F395-4BB0-8372-3D266F2E1224 com.pickupmvp [path to APS cert]`

## Test Universal (Deep) Links:
- Group Invite, Lands on Group Homepage: `xcrun simctl openurl booted 'https://fantasytrackball.com/otp/group_invite/accept/1897/437b56b295a1a4071a958d27da60df61/9?q=/group/9/details'` 
- Group Invite, Lands on Rewards Dashboard: `xcrun simctl openurl booted 'https://pickupmvp.com/otp/group_invite/accept/1903/b1dc5133e71985d8c0671a291d6b9966/61?q=/group/61/rewards'`
- Forgot Password: `xcrun simctl openurl booted 'https://pickupmvp.com/otp/account_otp/accept/1911/a8136bca890667fa98dc0f5e2a0d0546'`


## To Add a Brand For Android:
- edit `.env.[brand]` with correct firebase values from `google-services.json`
- add config in `project.ext.envConfigFiles` of build.gradle
- from /android folder: `ENVFILE=.env.[brand] ./gradlew assembleDebug`
- create dedication /app/src/[brand]/res folder with icons
- 
## To Add a Brand For ioS:
- edit `.env.[brand]` with correct firebase values from `google-services.json`
- create Schema from xCode, duplicate a config and change the env file brand. 
- change pre-run script to use new env file