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
1. **What can the web app not do inside of WebView?**
2. Can Flutter Deep Link to open and play from *Youtube Music*? 
3. Can Webview browser audio playback continue when:
    - [ ] App is in the background?
    - [ ] Device is locked?
    - [ ] Source is youtube.com?
4. Can native audio playback continue when:
   - [ ] App is in the background?
   - [ ] Device is locked?
   - [ ] Source is youtube.com?
5. When is LocalStorage of Webview Browsers automatically? (this would force logout)
6. What are the benefits of [flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview)?