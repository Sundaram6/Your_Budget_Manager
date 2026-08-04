import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/screens/onboarding/notification_permission_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('NotificationPermissionScreen renders title, subtitle, and supported apps', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const NotificationPermissionScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Never miss a transaction'), findsOneWidget);
    expect(
      find.textContaining('All processing happens on your device — nothing leaves your phone.'),
      findsOneWidget,
    );
    expect(find.text('SUPPORTED APPS'), findsOneWidget);
    expect(find.text('Google Pay'), findsOneWidget);
    expect(find.text('PhonePe'), findsOneWidget);
    expect(find.text('Paytm'), findsOneWidget);
    expect(find.text('Amazon Pay'), findsOneWidget);
    expect(find.text('CRED'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Grant Access'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  testWidgets('NotificationPermissionScreen invokes onCompleted on Skip for now', (tester) async {
    bool completed = false;
    await tester.pumpWidget(buildTestableWidget(
      NotificationPermissionScreen(onCompleted: () => completed = true),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Skip for now'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(completed, isTrue);
  });
}
