import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/providers/initial_route_provider.dart';
import 'package:your_budget_manager/core/security/app_lock_controller.dart';
import 'package:your_budget_manager/core/security/biometric_service.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:your_budget_manager/features/settings/presentation/screens/sms_settings_screen.dart';
import 'package:your_budget_manager/routing/app_router.dart';
import 'package:your_budget_manager/screens/settings/notification_settings_screen.dart';
import 'package:your_budget_manager/screens/settings/pin_security_screen.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}
class MockPinService extends Mock implements PinService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockLocalAuth;
  late MockPinService mockPinService;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_app_lock': true,
      'pref_use_biometric': false,
      'pref_notify_upi': true,
      'pref_notify_wallets': true,
      'pref_notify_banking': true,
      'autoTrackNewSms': false,
      'pin_setup_complete': true,
      'pinSetupComplete': true,
      'hasCompletedOnboarding': true,
      'onboarding_complete': true,
    });

    mockLocalAuth = MockLocalAuthentication();
    mockPinService = MockPinService();

    when(() => mockPinService.hasPin()).thenAnswer((_) async => true);
    when(() => mockPinService.verifyPin(any())).thenAnswer((_) async => true);
    when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
    when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ybm.your_budget_manager/notification_listener'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isNotificationAccessGranted') {
          return true;
        }
        if (methodCall.method == 'openNotificationSettings') {
          return true;
        }
        return null;
      },
    );
  });

  group('Settings Toggles & Navigation Guard Tests', () {
    testWidgets('NotificationSettingsScreen toggles modify preferences without navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pinServiceProvider.overrideWithValue(mockPinService),
            biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
          ],
          child: const MaterialApp(
            home: NotificationSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('UPI Payment Apps'), findsOneWidget);
      expect(find.text('Digital Wallets'), findsOneWidget);
      expect(find.text('Banking SMS & Notifications'), findsOneWidget);

      // Find switch for UPI and toggle it off
      final upiSwitch = find.widgetWithText(SwitchListTile, 'UPI Payment Apps');
      expect(upiSwitch, findsOneWidget);
      await tester.tap(upiSwitch);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_notify_upi'), isFalse);

      // Verify screen has NOT popped or navigated away
      expect(find.text('Notification Settings'), findsOneWidget);
    });

    testWidgets('PinSecurityScreen lock toggle updates preferences without navigating away', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pinServiceProvider.overrideWithValue(mockPinService),
            biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
          ],
          child: const MaterialApp(
            home: PinSecurityScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PIN & Security'), findsOneWidget);

      // Find Lock app when backgrounded toggle
      final lockSwitch = find.widgetWithText(SwitchListTile, 'Lock app when backgrounded');
      expect(lockSwitch, findsOneWidget);

      await tester.tap(lockSwitch);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_app_lock'), isFalse);

      // Verify screen is still active
      expect(find.text('PIN & Security'), findsOneWidget);
    });

    testWidgets('Permission dialog lifecycle simulation on Settings preserves route', (tester) async {
      final container = ProviderContainer(
        overrides: [
          initialRouteProvider.overrideWithValue('/settings'),
          pinServiceProvider.overrideWithValue(mockPinService),
          biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
        ],
      );

      // App unlocked initially
      container.read(appLockControllerProvider.notifier).unlock();

      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      // Simulate permission dialog appearing (setSystemDialogActive + inactive)
      final appLock = container.read(appLockControllerProvider.notifier);
      appLock.setSystemDialogActive(true);
      appLock.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate permission dialog dismissed (resumed + setSystemDialogActive(false))
      appLock.didChangeAppLifecycleState(AppLifecycleState.resumed);
      appLock.setSystemDialogActive(false);
      await tester.pumpAndSettle();

      // App should still be on Settings and NOT redirected to PIN lock
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App Locked'), findsNothing);
    });

    testWidgets('SettingsScreen navigates smoothly to sub-screens via GoRouter', (tester) async {
      final container = ProviderContainer(
        overrides: [
          initialRouteProvider.overrideWithValue('/settings'),
          pinServiceProvider.overrideWithValue(mockPinService),
          biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
        ],
      );

      container.read(appLockControllerProvider.notifier).unlock();
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Appearance'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);

      // Tap Appearance tile
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      // Verify Appearance screen is displayed
      expect(find.text('Dark Mode (Default & Active)'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
    });
  });
}
