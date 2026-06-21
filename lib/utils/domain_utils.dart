class DomainUtils {
  static const _oauthHosts = {
    'accounts.google.com',
    'www.google.com',
    'oauth.google.com',
    'facebook.com',
    'www.facebook.com',
    'm.facebook.com',
    'appleid.apple.com',
  };

  static const _sharedMediaHosts = {
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'youtu.be',
  };

  static bool isAllowedHost(
    String host, {
    required String clientHost,
    bool debugMode = false,
  }) {
    if (host.isEmpty) {
      return true;
    }

    if (debugMode && _isLocalDevHost(host)) {
      return true;
    }

    if (_oauthHosts.contains(host) || _sharedMediaHosts.contains(host)) {
      return true;
    }

    final normalizedClientHost = _stripPort(clientHost);
    if (host == normalizedClientHost || host.endsWith('.$normalizedClientHost')) {
      return true;
    }

    return false;
  }

  static bool _isLocalDevHost(String host) {
    return host == '192.168.0.19' ||
        host.startsWith('192.168.') ||
        host == 'localhost' ||
        host == '10.0.2.2';
  }

  static String _stripPort(String host) {
    return host.split(':').first;
  }
}
