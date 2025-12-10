import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creditscoring/main.dart';

void main() {
  testWidgets('App loads SplashScreen correctly', (WidgetTester tester) async {
    // Load the main app
    await tester.pumpWidget(const VietCreditApp());

    // Verify SplashScreen UI
    expect(find.text('VietCredit'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);

    // Dispose the widget to cancel the pending Timer in SplashScreen
    await tester.pumpWidget(const SizedBox());
  });
}
