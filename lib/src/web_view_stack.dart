// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:TrackAuthorityMusic/main.dart';
import 'package:TrackAuthorityMusic/services/notification_service.dart';
import 'package:TrackAuthorityMusic/services/oauth_browser_service.dart';
import 'package:TrackAuthorityMusic/services/url_service.dart';
import 'package:TrackAuthorityMusic/utils/domain_utils.dart';
import 'package:TrackAuthorityMusic/utils/url_utils.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({super.key});

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  final _appLinks = AppLinks();
  final _oauthBrowser = OAuthBrowserService();

  NotificationService notificationService =
      serviceLocator.get<NotificationService>();
  UrlService urlService = serviceLocator.get<UrlService>();

  InAppWebViewController? _webViewController;

  EdgeInsets? _lastSentPadding;

  var loadingPercentage = 0;

  void setToken(String? token) {
    developer.log('FCM Token: $token');
  }

  void _postNativeInsets(
    InAppWebViewController controller,
    EdgeInsets padding, {
    bool force = false,
  }) {
    if (!force && _lastSentPadding == padding) {
      return;
    }
    _lastSentPadding = padding;

    final insetsData = UrlUtils.nativeInsetsPayload(padding);

    controller.evaluateJavascript(source: '''
      window.postMessage(
        {
          type: 'NATIVE_INSETS',
          data: ${jsonEncode(insetsData)}
        },
        '*'
      );
    ''');
  }

  void _injectOAuthToken(
    InAppWebViewController controller, {
    required String provider,
    required String token,
    required String userId,
  }) {
    final tokenData = {
      'provider': provider,
      'token': token,
      'userId': userId,
    };

    controller.evaluateJavascript(source: '''
      window.postMessage(
        {
          type: 'OAUTH_TOKEN',
          data: ${jsonEncode(tokenData)}
        },
        '*'
      );
    ''');
  }

  void _handleIncomingUri(InAppWebViewController controller, Uri uri) {
    developer.log('incoming uri: $uri');

    if (OAuthCallbackParser.isOAuthCallback(
      uri,
      appId: urlService.appID,
      clientHost: urlService.myHost,
    )) {
      final tokenData = OAuthCallbackParser.parse(uri);
      if (tokenData != null) {
        _injectOAuthToken(
          controller,
          provider: tokenData['provider']!,
          token: tokenData['token']!,
          userId: tokenData['userId']!,
        );
      }
      return;
    }

    var targetUri = uri;
    if (uri.scheme == 'app' && uri.host == urlService.appID) {
      targetUri = Uri.parse(
        uri
            .toString()
            .replaceAll(
              'app://${urlService.appID}',
              urlService.baseUrl,
            )
            .replaceFirst('?', ''),
      );
    }

    final initUrl = UrlUtils.buildInitUrl(
      targetUri.toString(),
      padding: MediaQuery.paddingOf(context),
    );

    controller.loadUrl(urlRequest: URLRequest(url: WebUri(initUrl)));
  }

  void onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;

    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(controller, uri);
    });

    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.instance.getToken().then(setToken);
    FirebaseMessaging.instance.onTokenRefresh.listen(setToken);

    FirebaseMessaging.onMessage
        .listen(notificationService.showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('url') && mounted) {
        final padding = MediaQuery.paddingOf(context);
        final initUrl = UrlUtils.buildInitUrl(
          message.data['url'],
          padding: padding,
        );
        controller.loadUrl(urlRequest: URLRequest(url: WebUri(initUrl)));
      }
    });

    controller.addJavaScriptHandler(
      handlerName: 'SnackBar',
      callback: (args) {
        final message = args.map((arg) => arg.toString()).join();
        developer.log('failed loading $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.fixed,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'startOAuth',
      callback: (args) async {
        if (args.isEmpty) {
          return;
        }
        final authUrl = args[0].toString();
        developer.log('starting OAuth in external browser: $authUrl');
        await _oauthBrowser.openAuthUrl(authUrl);
      },
    );

    controller.addJavaScriptHandler(
      handlerName: 'handleOAuthToken',
      callback: (args) {
        if (args.length >= 3) {
          _injectOAuthToken(
            controller,
            provider: args[0].toString(),
            token: args[1].toString(),
            userId: args[2].toString(),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _appLinks.getInitialLink().then((uri) {
      final controller = _webViewController;
      if (uri != null && controller != null) {
        _handleIncomingUri(controller, uri);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = _webViewController;
    if (controller != null) {
      _postNativeInsets(controller, MediaQuery.paddingOf(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initUrl = UrlUtils.buildInitUrl(
      urlService.baseUrl,
      padding: MediaQuery.paddingOf(context),
    );

    return Stack(
      children: [
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
        InAppWebView(
          onWebViewCreated: onWebViewCreated,
          shouldInterceptRequest: (controller, request) async {
            if (request.isForMainFrame ?? false) {
              final host = request.url.host;
              developer.log('navigating host $host');
              if (!DomainUtils.isAllowedHost(
                host,
                clientHost: urlService.myHost,
                debugMode: kDebugMode,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Blocking navigation to $host'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
                return WebResourceResponse(
                  statusCode: 401,
                  data: Uint8List.fromList(
                    utf8.encode(
                      '<div style="position: absolute; left: 50%; top: 50%; -webkit-transform: translate(-50%, -50%); transform: translate(-50%, -50%);"><h1>Unauthorized domain</h1></div>',
                    ),
                  ),
                );
              }
            }
            return null;
          },
          onLoadStart: (controller, uri) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onLoadStop: (controller, uri) {
            setState(() {
              developer.log('finished loading ${uri?.host}');
              loadingPercentage = 100;
            });
            _postNativeInsets(
              controller,
              MediaQuery.paddingOf(context),
              force: true,
            );
          },
          initialUrlRequest: URLRequest(url: WebUri(initUrl)),
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
          onConsoleMessage: (controller, messages) {
            developer.log(
              '[IN_APP_BROWSER_LOG_LEVEL]: ${messages.messageLevel}',
            );
            developer.log('[IN_APP_BROWSER_MESSAGE]: ${messages.message}');
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
        ),
      ],
    );
  }
}
