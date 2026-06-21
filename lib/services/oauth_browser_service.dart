import 'dart:developer' as developer;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OAuthBrowserService {
  final ChromeSafariBrowser _browser = ChromeSafariBrowser();

  Future<void> openAuthUrl(String url) async {
    if (!await ChromeSafariBrowser.isAvailable()) {
      developer.log('ChromeSafariBrowser is not available on this device');
      return;
    }

    await _browser.open(
      url: WebUri(url),
      settings: ChromeSafariBrowserSettings(
        shareState: CustomTabsShareState.SHARE_STATE_OFF,
      ),
    );
  }
}

class OAuthCallbackParser {
  static bool isOAuthCallback(
    Uri uri, {
    required String appId,
    required String clientHost,
  }) {
    if (uri.scheme == 'app' && uri.host == appId) {
      return uri.path.contains('oauth') ||
          uri.queryParameters.containsKey('token');
    }

    final normalizedHost = clientHost.split(':').first;
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        (uri.host == normalizedHost ||
            uri.host.endsWith('.$normalizedHost'))) {
      return uri.path.contains('oauth/callback') ||
          uri.queryParameters.containsKey('token');
    }

    return false;
  }

  static Map<String, String>? parse(Uri uri) {
    final params = uri.queryParameters;
    final token = params['token'];
    if (token == null || token.isEmpty) {
      return null;
    }

    return {
      'provider': params['provider'] ?? 'google',
      'token': token,
      'userId': params['userId'] ?? params['user_id'] ?? '',
    };
  }
}
