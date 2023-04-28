// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;

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
            developer.log('web view error!!! ');
          },
          onNavigationRequest: (NavigationRequest navigation) {
            final host = Uri
                .parse(navigation.url)
                .host;
            developer.log('navigating host ' + host);
            if (
            host != 'youtube.com' &&
            host != 'therapruler.com' &&
            host != 'fantasytrackball.com' &&
            host != 'rsoundtrack.com' &&
            host != 'giftofmusic.app' &&
            host != 'pickupmvp.com' &&
            host != 'trackauthoritymusic.com') {
              if (host == '') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Blocking navigation to $host',
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message.message)));
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
        WebViewWidget(
          controller: widget.controller,
        ),
      ],
    );
  }
}