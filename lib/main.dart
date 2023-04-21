// Copyright 2023 @ TrackAuthorityMusic.com

import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_driver/driver_extension.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_config/flutter_config.dart';
// import 'package:pickupmvp/environment.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'src/menu.dart';
// import 'src/navigation_controls.dart';
import 'src/web_view_stack.dart';

final _appLinks = AppLinks();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const WebViewApp(),
    ),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  // String? _flavor;

  @override
  void initState() {
    super.initState();
    /* const MethodChannel('flavor').invokeMethod<String>('getFlavor').then((String? flavor) {
      setState(() {
        _flavor = flavor;
      });
    });
     */

    _appLinks.allUriLinkStream.listen((uri) {
      // TODO: Add logic for deep link
      print('Uri ${uri}');
    });

    // var myhost = 'youtube.com';
    var myhost = FlutterConfig.get('CLIENT_HOST');
    // var myhost = '127.0.0.1:1340';
    // var myhost = 'localhost.pickupmvp.com:1340';
    var initUrl = 'https://' + myhost + '?appOS=' + Platform.operatingSystem;
    initUrl += '&paddingTop=' +
        MediaQueryData.fromWindow(ui.window).padding.top.toString();
    initUrl += '&paddingBottom=' +
        MediaQueryData.fromWindow(ui.window).padding.bottom.toString();

    print('loading url 2: ' + initUrl);
    developer.log(initUrl);

    controller = WebViewController()
      ..loadRequest(
        Uri.parse(initUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: const Text('PickupMVP'),
        actions: [
          // NavigationControls(controller: controller),
          Menu(controller: controller),
        ],
      ),
       */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: Menu(controller: controller),
      ),
      body: WebViewStack(controller: controller),
    );
  }

/*
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        /* builder: (_, __) => Scaffold(
          appBar: WebViewStack(controller: controller),
        ) */
      ),
    ],
  );
   */
}
