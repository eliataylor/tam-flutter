// This is a basic Flutter widget test.

import 'package:TrackAuthorityMusic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WebViewApp shows loading indicator initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WebViewApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
