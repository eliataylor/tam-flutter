# TAM Flutter
#### Basic WebView wrapper for all TAM Groups

# Building
- simply replace the contents of `.env` with the .env.[brand] you want to build
- then `flutter run` or `flutter run --release`

## Launching Options
- [x] Load startup Url embedded from .env when built  
- [ ] Load Exact url passed from Push Notification Link
- [ ] Load Exact url passed from Deep Link?
- OnLoad WebView always adds query parameters `appPlatform` (for client controls), `paddingTop` & `paddingBottom` (for safearea).


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
