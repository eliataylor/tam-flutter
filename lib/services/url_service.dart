import 'package:TrackAuthorityMusic/config/env_config.dart';
import 'package:flutter/foundation.dart';

class UrlService {
  late String appID;
  late String baseUrl;
  late String myHost;

  Future<void> init() async {
    const String flavor = String.fromEnvironment('FLAVOR');
    if (kDebugMode && flavor.isNotEmpty) {
      // ignore: avoid_print
      print('running flavor: $flavor');
    }

    myHost = kDebugMode ? env('CLIENT_HOST_DEBUG') : env('CLIENT_HOST');
    appID = env('APP_ID');
    baseUrl = 'https://$myHost';
  }
}
