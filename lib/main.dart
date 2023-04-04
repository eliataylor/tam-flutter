// Copyright 2023 @ TrackAuthorityMusic.com

import 'package:flutter/material.dart';
// import 'package:pickupmvp/environment.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_driver/driver_extension.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_config/flutter_config.dart';
// import 'src/menu.dart';
// import 'src/navigation_controls.dart';
import 'src/web_view_stack.dart';

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
  String? _flavor;

  @override
  void initState() {
    super.initState();
    const MethodChannel('flavor').invokeMethod<String>('getFlavor').then((String? flavor) {
      setState(() {
        _flavor = flavor;
      });
    });
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://'+FlutterConfig.get('CLIENT_HOST')),
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
      floatingActionButton:  FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: Menu(controller: controller),
      ),
       */
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

