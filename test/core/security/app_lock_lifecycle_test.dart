import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/security/app_lock_controller.dart';
import 'package:your_budget_manager/core/security/biometric_service.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/features/auth/presentation/controllers/auth_controller.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}
class MockPinService extends Mock implements PinService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalAuthentication mockLocalAuth;
  late MockPinService mockPinService;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'pref_app_lock': true,
      'pref_use_biometric': true,
    });

    mockLocalAuth = MockLocalAuthentication();
    mockPinService = MockPinService();

    when(() => mockPinService.hasPin()).thenAnswer((_) async => true);
    when(() => mockPinService.verifyPin(any())).thenAnswer((inv) async {
      return inv.positionalArguments[0] == '1234';
    });

    container = ProviderContainer(
      overrides: [
        pinServiceProvider.overrideWithValue(mockPinService),
        biometricServiceProvider.overrideWithValue(BiometricService(mockLocalAuth)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AppLockController & Biometric State Machine', () {
    test('starts locked by default (state = true)', () {
      final isLocked = container.read(appLockControllerProvider);
      expect(isLocked, isTrue);
    });

    test('manual unlock sets state to false', () {
      container.read(appLockControllerProvider.notifier).unlock();
      expect(container.read(appLockControllerProvider), isFalse);
    });

    test('backgrounding app triggers lock if security is active', () async {
      final controller = container.read(appLockControllerProvider.notifier);
      controller.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // Simulate app going to background (paused)
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(appLockControllerProvider), isTrue);
    });

    test('lifecycle pause is IGNORED when authenticating (protects OS biometric dialog)', () async {
      final controller = container.read(appLockControllerProvider.notifier);
      controller.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // System biometric dialog opens, setting authenticating to true
      controller.setAuthenticating(true);

      // OS dialog causes Flutter activity to pause/lose focus
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should NOT re-lock because isAuthenticating is true
      expect(container.read(appLockControllerProvider), isFalse);
    });

    test('lifecycle pause is IGNORED when system dialog / permissions active', () async {
      final controller = container.read(appLockControllerProvider.notifier);
      controller.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // System permissions dialog opens
      controller.setSystemDialogActive(true);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should NOT lock while permission dialog is presented
      expect(container.read(appLockControllerProvider), isFalse);

      // Permission dialog closes
      controller.setSystemDialogActive(false);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(appLockControllerProvider), isFalse);
    });

    test('transient inactive state (permission popup / notification drop) with quick resume does not lock', () async {
      final controller = container.read(appLockControllerProvider.notifier);
      controller.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // Transient inactive (e.g. system notification pull or dialog)
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future.delayed(const Duration(milliseconds: 100));

      // User resumes within debounce threshold
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 600));

      expect(container.read(appLockControllerProvider), isFalse);
    });

    test('persistent inactive state > 500ms without resume triggers lock', () async {
      final controller = container.read(appLockControllerProvider.notifier);
      controller.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // Inactive without resume
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future.delayed(const Duration(milliseconds: 650));

      expect(container.read(appLockControllerProvider), isTrue);
    });

    test('successful biometric authentication transitions state to unlocked', () async {
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

      expect(container.read(appLockControllerProvider), isTrue);

      final authController = container.read(authControllerProvider.notifier);
      final result = await authController.authenticateBiometric('Unlock App');

      expect(result, isTrue);
      expect(container.read(appLockControllerProvider), isFalse);
    });

    test('failed biometric authentication leaves app locked', () async {
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
          )).thenAnswer((_) async => false);

      expect(container.read(appLockControllerProvider), isTrue);

      final authController = container.read(authControllerProvider.notifier);
      final result = await authController.authenticateBiometric('Unlock App');

      expect(result, isFalse);
      expect(container.read(appLockControllerProvider), isTrue);
    });

    test('screen-lock (inactive / hidden) reliably locks the app even if resumed quickly', () async {
      final controller = container.read(appLockControllerProvider.notifier);
      controller.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // User presses power button: OS triggers inactive -> hidden
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);

      // User turns screen back on quickly
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      // Must reliably lock
      expect(container.read(appLockControllerProvider), isTrue);
    });

    test('successful PIN verification transitions state to unlocked', () async {
      expect(container.read(appLockControllerProvider), isTrue);

      final authController = container.read(authControllerProvider.notifier);
      final result = await authController.verifyPin('1234');

      expect(result, isTrue);
      expect(container.read(appLockControllerProvider), isFalse);
    });

    test('wrong PIN leaves app locked', () async {
      expect(container.read(appLockControllerProvider), isTrue);

      final authController = container.read(authControllerProvider.notifier);
      final result = await authController.verifyPin('9999');

      expect(result, isFalse);
      expect(container.read(appLockControllerProvider), isTrue);
    });
  });
}
