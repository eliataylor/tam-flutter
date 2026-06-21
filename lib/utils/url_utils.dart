import 'dart:io';

import 'package:flutter/material.dart';

class UrlUtils {
  static Map<String, dynamic> nativeInsetsPayload(EdgeInsets padding) {
    return {
      'appOS': Platform.operatingSystem,
      'paddingTop': padding.top,
      'paddingBottom': padding.bottom,
      'paddingLeft': padding.left,
      'paddingRight': padding.right,
    };
  }

  static String buildInitUrl(
    String baseUrl, {
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    final insets = nativeInsetsPayload(padding);
    var initUrl = baseUrl;
    if (initUrl.contains('?')) {
      initUrl += '&';
    } else {
      initUrl += '?';
    }
    initUrl += 'appOS=${insets['appOS']}';
    initUrl += '&paddingTop=${insets['paddingTop']}';
    initUrl += '&paddingBottom=${insets['paddingBottom']}';
    initUrl += '&paddingLeft=${insets['paddingLeft']}';
    initUrl += '&paddingRight=${insets['paddingRight']}';
    return initUrl;
  }
}
