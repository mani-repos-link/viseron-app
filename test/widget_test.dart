import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viseron_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({}); // Mock empty prefs
    
    await tester.pumpWidget(const ViseronApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Connect to Viseron'), findsOneWidget);
  });
}
