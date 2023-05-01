import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class UrlUtils {
  static buildInitUrl(baseUrl) {
    var initUrl = baseUrl;
    if (initUrl.contains('?'))
      initUrl += '&';
    else
      initUrl += '?';
    initUrl += 'appOS=' + Platform.operatingSystem;
    initUrl += '&paddingTop=' +
        MediaQueryData.fromWindow(ui.window).padding.top.toString();
    initUrl += '&paddingBottom=' +
        MediaQueryData.fromWindow(ui.window).padding.bottom.toString();
    return initUrl;
  }
}
