import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/providers/initial_route_provider.dart';
import 'package:your_budget_manager/core/security/app_lock_controller.dart';
import 'package:your_budget_manager/core/security/biometric_service.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/features/settings/presentation/screens/about_screen.dart';
import 'package:your_budget_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:your_budget_manager/routing/app_router.dart';

class MockPinService extends Mock implements PinService {}
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPinService mockPinService;
  late MockLocalAuthentication mockLocalAuth;

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

    mockPinService = MockPinService();
    mockLocalAuth = MockLocalAuthentication();

    when(() => mockPinService.hasPin()).thenAnswer((_) async => true);
    when(() => mockPinService.verifyPin(any())).thenAnswer((_) async => true);
    when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
    when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
  });

  final allSettingsTitles = [
    'Monthly Budget',
    'Savings Goals',
    'AI Financial Insights',
    'SMS Auto-Tracking',
    'Payment Notifications',
    'PIN & Security',
    'Categories',
    'Recurring Transactions',
    'Replay Onboarding',
    'Backup & Restore',
    'Appearance',
    'About App',
  ];

  final viewports = [320.0, 360.0, 375.0, 414.0];

  group('Phase 26: Settings Screen End-to-End Audit & Reachability Tests', () {
    for (final width in viewports) {
      testWidgets('Every settings item is scrollable and visible at width $width (Dark Theme)', (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

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
              theme: AppTheme.darkTheme,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);

        // Audit every single settings tile
        for (final title in allSettingsTitles) {
          final finder = find.text(title);
          await tester.scrollUntilVisible(
            finder,
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();

          expect(finder, findsOneWidget, reason: 'Tile "$title" must be present and scrollable into view');
        }
      });

      testWidgets('Every settings item is scrollable and visible at width $width (Light Theme)', (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

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
              theme: AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);

        for (final title in allSettingsTitles) {
          final finder = find.text(title);
          await tester.scrollUntilVisible(
            finder,
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();

          expect(finder, findsOneWidget, reason: 'Tile "$title" must be present and scrollable into view in Light Theme');
        }
      });
    }

    testWidgets('About App item at the bottom of Settings is reachable, tappable and navigates to AboutScreen', (WidgetTester tester) async {
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
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to the bottommost item "About App"
      final aboutFinder = find.text('About App');
      await tester.scrollUntilVisible(
        aboutFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(aboutFinder, findsOneWidget);
      expect(find.text('Privacy promise & local storage details'), findsOneWidget);

      // Tap About App
      await tester.tap(aboutFinder);
      await tester.pumpAndSettle();

      // Verify AboutScreen is displayed
      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('Your Budget Manager'), findsOneWidget);
      expect(find.text('v1.0.0 — Privacy-First Finance Companion'), findsOneWidget);
      expect(find.textContaining('100% stored locally on your device in an encrypted SQLite database'), findsOneWidget);
    });
  });
}
