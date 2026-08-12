import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/security/app_lock_controller.dart';
import 'package:your_budget_manager/core/security/biometric_service.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/features/auth/presentation/screens/pin_lock_screen.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}
class MockPinService extends Mock implements PinService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockLocalAuth;
  late MockPinService mockPinService;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_app_lock': true,
      'pref_use_biometric': true,
    });

    mockLocalAuth = MockLocalAuthentication();
    mockPinService = MockPinService();

    when(() => mockPinService.hasPin()).thenAnswer((_) async => true);
    when(() => mockPinService.getRemainingLockoutSeconds()).thenAnswer((_) async => 0);
    when(() => mockPinService.isLockedOut()).thenAnswer((_) async => false);
    when(() => mockPinService.getFailedAttempts()).thenAnswer((_) async => 0);
    when(() => mockPinService.verifyPin(any())).thenAnswer((inv) async {
      return inv.positionalArguments[0] == '1234';
    });

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
  });

  Widget buildSubject({ProviderContainer? container}) {
    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PinLockScreen(),
        ),
      );
    }
    return ProviderScope(
      overrides: [
        pinServiceProvider.overrideWithValue(mockPinService),
        biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
      ],
      child: const MaterialApp(
        home: PinLockScreen(),
      ),
    );
  }

  group('PinLockScreen Widget Tests', () {
    testWidgets('renders App Locked and biometric unlock button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('App Locked'), findsOneWidget);
      expect(find.text('Tap to use Fingerprint / Face ID'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('tapping fingerprint button invokes biometric authenticate', (tester) async {
      final container = ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(mockPinService),
          biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
        ],
      );

      await tester.pumpWidget(buildSubject(container: container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Tap the fingerprint icon button
      await tester.tap(find.byIcon(Icons.fingerprint));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      verify(() => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
            biometricOnly: any(named: 'biometricOnly'),
            sensitiveTransaction: any(named: 'sensitiveTransaction'),
            authMessages: any(named: 'authMessages'),
          )).called(greaterThanOrEqualTo(1));

      expect(container.read(appLockControllerProvider), isFalse);
    });

    testWidgets('entering invalid PIN displays error message when biometric is off', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_app_lock': true,
        'pref_use_biometric': false,
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid PIN'), findsOneWidget);
    });

    testWidgets('locked out state displays timer banner and disables input and button', (tester) async {
      when(() => mockPinService.getRemainingLockoutSeconds()).thenAnswer((_) async => 25);
      when(() => mockPinService.isLockedOut()).thenAnswer((_) async => true);

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Check for lockout warning
      expect(find.textContaining('Too many failed attempts'), findsOneWidget);
      expect(find.text('Locked Out'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
