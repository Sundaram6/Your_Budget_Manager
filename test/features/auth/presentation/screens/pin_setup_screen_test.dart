import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/security/biometric_service.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/features/auth/presentation/screens/pin_setup_screen.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}
class MockPinService extends Mock implements PinService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockLocalAuth;
  late MockPinService mockPinService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockLocalAuth = MockLocalAuthentication();
    mockPinService = MockPinService();

    when(() => mockPinService.setPin(any())).thenAnswer((_) async {});
  });

  Widget buildSubject({required bool isBiometricCapable}) {
    if (isBiometricCapable) {
      when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => mockLocalAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);
      when(() => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
            biometricOnly: any(named: 'biometricOnly'),
            sensitiveTransaction: any(named: 'sensitiveTransaction'),
            authMessages: any(named: 'authMessages'),
          )).thenAnswer((_) async => true);
    } else {
      when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
      when(() => mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);
      when(() => mockLocalAuth.getAvailableBiometrics())
          .thenAnswer((_) async => []);
    }

    final router = GoRouter(
      initialLocation: '/pin-setup',
      routes: [
        GoRoute(
          path: '/pin-setup',
          builder: (context, state) => const PinSetupScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Dashboard Placeholder')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        pinServiceProvider.overrideWithValue(mockPinService),
        biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('PinSetupScreen Biometric Enrollment Tests', () {
    testWidgets('shows biometric enrollment prompt on biometric-capable device and enables on acceptance', (tester) async {
      await tester.pumpWidget(buildSubject(isBiometricCapable: true));
      await tester.pumpAndSettle();

      // Step 1: Create PIN
      expect(find.text('Create a PIN'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Step 2: Confirm PIN
      expect(find.text('Confirm your PIN'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Save PIN'));
      await tester.pumpAndSettle();

      // Step 3: Biometric prompt appears
      expect(find.text('Enable Biometric Unlock?'), findsOneWidget);
      expect(find.text('Enable Biometrics'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);

      // Tap Enable Biometrics
      await tester.tap(find.text('Enable Biometrics'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_use_biometric'), isTrue);
      expect(prefs.getBool('pref_app_lock'), isTrue);
      expect(find.text('Dashboard Placeholder'), findsOneWidget);
    });

    testWidgets('skipping biometric enrollment prompt leaves pref_use_biometric unset/false and routes to dashboard', (tester) async {
      await tester.pumpWidget(buildSubject(isBiometricCapable: true));
      await tester.pumpAndSettle();

      // Create PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Confirm PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Save PIN'));
      await tester.pumpAndSettle();

      // Biometric prompt appears -> tap Skip for now
      expect(find.text('Enable Biometric Unlock?'), findsOneWidget);
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_use_biometric'), isNot(true));
      expect(find.text('Dashboard Placeholder'), findsOneWidget);
    });

    testWidgets('does NOT show biometric prompt on non-biometric device and routes directly to dashboard', (tester) async {
      await tester.pumpWidget(buildSubject(isBiometricCapable: false));
      await tester.pumpAndSettle();

      // Create PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Confirm PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Save PIN'));
      await tester.pumpAndSettle();

      // Prompt should NOT appear on non-capable device
      expect(find.text('Enable Biometric Unlock?'), findsNothing);
      expect(find.text('Dashboard Placeholder'), findsOneWidget);
    });
  });
}
