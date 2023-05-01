// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({required this.controller, super.key});

  final WebViewController controller;


  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    widget.controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (int progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              developer.log('finished loading ' + url);
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            developer.log('Error code: ${error.errorCode}');
            developer.log('Description: ${error.description}');
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.description)));
          },
          onNavigationRequest: (NavigationRequest navigation) {
            final host = Uri.parse(navigation.url).host;
            developer.log('navigating host ' + host);
            final allowedDomains = [
              'youtube.com',
              'therapruler.com',
              'fantasytrackball.com',
              'rsoundtrack.com',
              'giftofmusic.app',
              'pickupmvp.com',
              'trackauthoritymusic.com'
            ];
            if (kDebugMode) {
              allowedDomains.add('192.168.0.19');
            }
            if (!allowedDomains.contains(host)) {
              if (host != '') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Blocking navigation to $host',
                    ),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          developer.log('failed loading ' + message.message);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message.message),
            behavior: SnackBarBehavior.fixed,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ));
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            value: loadingPercentage / 100.0,
          ),
        WebViewWidget(controller: widget.controller),
      ],
    );
  }
}
