import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/features/auth/presentation/screens/pin_lock_screen.dart';
import 'package:your_budget_manager/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';

class MockPinService implements PinService {
  @override
  Future<bool> hasPin() async => true;
  @override
  Future<int> getRemainingLockoutSeconds() async => 0;
  @override
  Future<bool> isLockedOut() async => false;
  @override
  Future<int> getFailedAttempts() async => 0;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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
      ProviderScope(
        overrides: [
          pinServiceProvider.overrideWithValue(MockPinService()),
        ],
        child: const MaterialApp(
          home: PinLockScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('App Locked'), findsOneWidget);
  });
}
