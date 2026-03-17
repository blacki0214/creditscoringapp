import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creditscoring/main.dart';

void main() {
  testWidgets('App loads SplashScreen correctly', (WidgetTester tester) async {
    // Load the main app
    await tester.pumpWidget(const VietCreditApp());
    await tester.pump();

    // Verify app bootstrap rendered
    expect(find.byType(MaterialApp), findsOneWidget);

    // Dispose the widget to cancel the pending Timer in SplashScreen
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  });
}
