// Copyright 2023 @ TrackAuthorityMusic.com

import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:TrackAuthorityMusic/firebase_options.dart';
import 'package:TrackAuthorityMusic/src/menu.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_driver/driver_extension.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:pickupmvp/environment.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import 'src/navigation_controls.dart';
import 'src/web_view_stack.dart';

final _appLinks = AppLinks();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const WebViewApp(),
    ),
  );
}

AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'default_notification_channel_id', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          channelDescription: channel!.description,
          icon: 'ic_launcher',
        ),
      ),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;
  String? _token;
  String? initialMessage;
  bool _resolved = false;
  late Stream<String> _tokenStream;
  bool _notificationsEnabled = false;

  // String? _flavor;

  void setToken(String? token) {
    print('FCM Token: $token');
    setState(() {
      _token = token;
    });
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await FirebaseMessaging.instance.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        _notificationsEnabled = granted ?? false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    /* const MethodChannel('flavor').invokeMethod<String>('getFlavor').then((String? flavor) {
      setState(() {
        _flavor = flavor;
      });
    });
     */
    var myhost = FlutterConfig.get('CLIENT_HOST');
    var appID = FlutterConfig.get("APP_ID");
    var initUrl = 'https://' + myhost;

    // var myhost = 'youtube.com';
    _appLinks.allUriLinkStream.listen((uri) {
      if (uri.toString().contains("app://$appID")) {
        uri = Uri.parse(uri
            .toString()
            .replaceAll("app://$appID", 'https://' + myhost)
            .replaceFirst("?", ""));
      }

      initUrl = uri.toString();

      initUrl += '?appOS=' + Platform.operatingSystem;
      initUrl += '&paddingTop=' +
          MediaQueryData.fromWindow(ui.window).padding.top.toString();
      initUrl += '&paddingBottom=' +
          MediaQueryData.fromWindow(ui.window).padding.bottom.toString();

      print('loading url 2: ' + initUrl);
      developer.log(initUrl);

      controller.loadRequest(Uri.parse(initUrl));
    });

    // var myhost = '127.0.0.1:1340';
    // var myhost = 'localhost.pickupmvp.com:1340';
    initUrl += '?appOS=' + Platform.operatingSystem;
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

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
              _resolved = true;
              initialMessage = value?.data.toString();
            },
          ),
        );

    FirebaseMessaging.instance.getToken().then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey("url")) {
        initUrl = message.data["url"];
        initUrl += '?appOS=' + Platform.operatingSystem;
        initUrl += '&paddingTop=' +
            MediaQueryData.fromWindow(ui.window).padding.top.toString();
        initUrl += '&paddingBottom=' +
            MediaQueryData.fromWindow(ui.window).padding.bottom.toString();

        controller.loadRequest(Uri.parse(initUrl));
      }
    });
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
      floatingActionButton: FloatingActionButton(
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
