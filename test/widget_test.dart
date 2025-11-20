import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creditscoring/main.dart';

void main() {
  testWidgets('App loads LoginPage correctly', (WidgetTester tester) async {
    // Load the main app
    await tester.pumpWidget(const VietCreditApp());

    // Verify LoginPage UI
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
