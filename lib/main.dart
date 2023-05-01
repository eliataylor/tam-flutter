// Copyright 2023 @ TrackAuthorityMusic.com

import 'dart:developer' as developer;

import 'package:TrackAuthorityMusic/firebase_options.dart';
import 'package:TrackAuthorityMusic/services/notification_service.dart';
import 'package:TrackAuthorityMusic/services/url_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get_it/get_it.dart';

import 'src/web_view_stack.dart';

final serviceLocator = GetIt.instance;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService notificationService =
      serviceLocator.get<NotificationService>();

  await notificationService.setupFlutterNotifications();
  notificationService.showFlutterNotification(message);
  developer.log('Handling a background message ${message.messageId}');
}

void setUp() {
  serviceLocator.registerSingletonAsync<UrlService>(() async {
    final urlService = UrlService();
    await urlService.init();
    return urlService;
  });
  serviceLocator.registerSingletonAsync<NotificationService>(() async {
    final notificationService = NotificationService();
    await notificationService.init();
    return notificationService;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setUp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // if (kDebugMode) {
  //   HttpOverrides.global = MyHttpOverrides();
  // }

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: serviceLocator.allReady(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return const WebViewStack();
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}
