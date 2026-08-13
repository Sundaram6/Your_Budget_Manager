import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/providers/initial_route_provider.dart';
import 'package:your_budget_manager/core/security/biometric_service.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine_provider.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine_provider.dart';
import 'package:your_budget_manager/features/intelligence/presentation/screens/insights_screen.dart';
import 'package:your_budget_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:your_budget_manager/routing/app_router.dart';
import 'package:your_budget_manager/screens/settings/pin_security_screen.dart';

class MockPinService extends Mock implements PinService {}
class MockBiometricService extends Mock implements BiometricService {}
class MockIntelligenceEngine extends Mock implements IntelligenceEngine {}
class MockAnalyticsEngine extends Mock implements AnalyticsEngine {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPinService mockPinService;
  late MockBiometricService mockBiometricService;
  late MockIntelligenceEngine mockIntelligenceEngine;
  late MockAnalyticsEngine mockAnalyticsEngine;

  setUp(() {
    mockPinService = MockPinService();
    mockBiometricService = MockBiometricService();
    mockIntelligenceEngine = MockIntelligenceEngine();
    mockAnalyticsEngine = MockAnalyticsEngine();

    when(() => mockPinService.hasPin()).thenAnswer((_) async => false);
    when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => false);
    when(() => mockIntelligenceEngine.generateInsights()).thenAnswer((_) async => []);
    when(() => mockIntelligenceEngine.calculateBudgetHealthScore()).thenAnswer((_) async => 85);
    when(() => mockAnalyticsEngine.getCategoryBreakdown(any(), any())).thenAnswer((_) async => []);

    SharedPreferences.setMockInitialValues({
      'hasCompletedOnboarding': true,
      'onboardingCompletedAt': 1700000000000,
      'pin_setup_complete': true,
    });
  });

  group('Phase 10: Product Cleanup - Settings & Security Screen Consolidation', () {
    testWidgets('SettingsScreen displays exactly ONE PIN & Security tile', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pinServiceProvider.overrideWithValue(mockPinService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      // Verify the canonical "PIN & Security" tile exists
      expect(find.text('PIN & Security'), findsOneWidget);
      expect(find.text('Change PIN, biometric & app lock'), findsOneWidget);

      // Verify the duplicate "Security & App Lock" tile is completely removed
      expect(find.text('Security & App Lock'), findsNothing);
      expect(find.text('PIN protection and authentication'), findsNothing);
    });

    testWidgets('Tapping PIN & Security tile navigates to PinSecurityScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pinServiceProvider.overrideWithValue(mockPinService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.tap(find.text('PIN & Security'));
      await tester.pumpAndSettle();

      expect(find.byType(PinSecurityScreen), findsOneWidget);
      expect(find.text('BIOMETRIC & LOCK'), findsOneWidget);
      expect(find.text('SET PIN'), findsOneWidget);
    });
  });

  group('Phase 10: Product Cleanup - Router Uniqueness & Canonical Destinations', () {
    testWidgets('Route /security resolves to PinSecurityScreen with no duplicate definitions', (tester) async {
      final container = ProviderContainer(
        overrides: [
          initialRouteProvider.overrideWithValue('/security'),
          pinServiceProvider.overrideWithValue(mockPinService),
          biometricServiceProvider.overrideWithValue(mockBiometricService),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                theme: AppTheme.darkTheme,
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PinSecurityScreen), findsOneWidget);
      expect(find.text('BIOMETRIC & LOCK'), findsOneWidget);
    });

    testWidgets('Route /insights resolves to canonical InsightsScreen', (tester) async {
      final container = ProviderContainer(
        overrides: [
          initialRouteProvider.overrideWithValue('/insights'),
          pinServiceProvider.overrideWithValue(mockPinService),
          biometricServiceProvider.overrideWithValue(mockBiometricService),
          intelligenceEngineProvider.overrideWithValue(mockIntelligenceEngine),
          analyticsEngineProvider.overrideWithValue(mockAnalyticsEngine),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              return MaterialApp.router(
                theme: AppTheme.darkTheme,
                routerConfig: router,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InsightsScreen), findsOneWidget);
    });
  });

  group('Phase 10: Product Cleanup - Debug Onboarding Reset Tile Gating', () {
    testWidgets('Reset Onboarding (Debug) tile presence respects kDebugMode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pinServiceProvider.overrideWithValue(mockPinService),
            biometricServiceProvider.overrideWithValue(mockBiometricService),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const SettingsScreen(),
          ),
        ),
      );

      if (kDebugMode) {
        expect(find.text('Reset Onboarding (Debug)'), findsOneWidget);
      } else {
        expect(find.text('Reset Onboarding (Debug)'), findsNothing);
      }
    });
  });
}
