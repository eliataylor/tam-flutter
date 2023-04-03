import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

var myFlavor = const String.fromEnvironment('FLAVOR');

class Environment {

  String get fileName {
    developer.log(
      'logging flavor',
      name: 'my.app',
      error: myFlavor,
    );

    if (kReleaseMode) {
      return '.env.' + myFlavor;
    }
    return '.env.' + myFlavor;
  }

  String get initUrl {
    return 'https://' + dotenv.get('CLIENT_HOST', fallback: 'trackauthoritymusic.com');
  }

  String get appName {
    return dotenv.get('APP_NAME', fallback: 'Track Authority Music');
  }

  String get packageId {
    return dotenv.get('APP_PACKAGE_ID', fallback: 'com.trackauthoritymusic');
  }

}