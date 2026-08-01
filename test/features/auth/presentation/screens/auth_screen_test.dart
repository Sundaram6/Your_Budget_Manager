import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/features/auth/presentation/screens/pin_lock_screen.dart';
import 'package:your_budget_manager/features/auth/presentation/screens/pin_setup_screen.dart';

void main() {
  testWidgets('PinSetupScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PinSetupScreen(),
        ),
      ),
    );
    expect(find.text('Create a PIN'), findsOneWidget);
  });

  testWidgets('PinLockScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PinLockScreen(),
        ),
      ),
    );
    expect(find.text('Enter PIN'), findsOneWidget);
  });
}
