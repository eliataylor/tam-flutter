import 'dart:developer' as developer;

import 'package:TrackAuthorityMusic/utils/url_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_config/flutter_config.dart';

class UrlService {
  late String appID;
  late String initUrl;
  late String myHost;
  late String port;

  init() {
    const String flavor = String.fromEnvironment('flavor');
    developer.log('running flavor: $flavor');

    myHost = FlutterConfig.get('CLIENT_HOST');
    if (kDebugMode) {
      port = '1337';
      if (flavor == 'pickupmvp') {
        port = '1340';
      } else if (flavor == 'rapruler') {
        port = '1339';
      }
      myHost = '192.168.0.19:$port';
    }
    appID = FlutterConfig.get("APP_ID");
    initUrl = 'https://$myHost';
    initUrl = UrlUtils.buildInitUrl(initUrl);
    developer.log('loading startup url: $initUrl');
  }
}
