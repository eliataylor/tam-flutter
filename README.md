# TAM Flutter
#### Basic WebView wrapper for all TAM Groups

# Android Test install: 
- https://play.google.com/apps/internaltest/4700937001191384768

# Build to Debug
- simply replace the contents of `.env` with the .env.[brand] you want to build
- then `flutter run` or `flutter run --release`

# Build to Release
- `flutter build appbundle --flavor trackauthoritymusic`
- `flutter build appbundle --flavor pickupmvp`
- `flutter build appbundle --flavor rapruler`
- `flutter build appbundle --flavor djmote`

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


#### QUESTIONS:
1. **What can the WebApp *not* do while running inside of WebView browser?** 
2. What are the benefits of [flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview)?
3. Can Flutter open and play youtube videos using the installed *Youtube Music* app? 
4. Can Webview browser Audio play when:
    - [ ] App has been sent to the background?
    - [ ] Device is locked?
5. Can native audio playback continue when:
   - [ ] App is in the background?
   - [ ] Device is locked?
6. What might cause the session token in LocalStorage to be deleted from Webview Browsers?


## Test Audio Playback:
#### Go to: [/group/9/playlists/8278/tracks/9504](https://pickupmvp.com/group/9/playlists/8278/tracks/9504)
1.  Open Context Menu and click **"Play TaMP3"** 
- This will send a `GET` to `https://api.trackauthoritymusic.com/media/stream/4852/sample` for streamed mp3 and the music should start.
- [ ] Does the music continue when you go to another app?
- [ ] Does the music continue when you lock the phone?
----
2.  Open Context Menu and click **"Play Youtube"**
- This will load `https://www.youtube.com/watch?v=R4GLAKEjU4w` using ReactPlayer's youtube sdk 
- [ ] Does the music continue when you go to another app?
- [ ] Does the music continue when you lock the phone?


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