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
    when(() => mockPinService.verifyPin(any())).thenAnswer((_) async => true);

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

  group('Phase 21: App Lock Intermittent Failure Race Condition & Boundary Tests', () {
    test('Reproduction 1: Biometric unlock followed immediately by screen-off within 300ms locks reliably', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      final authController = container.read(authControllerProvider.notifier);

      // User unlocks with biometric
      final unlockFuture = authController.authenticateBiometric('Unlock App');
      
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(appLockControllerProvider), isFalse, reason: 'App is unlocked upon verification');

      // User immediately locks phone
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      
      await unlockFuture;
      await Future.delayed(const Duration(milliseconds: 50));

      // User wakes phone up
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      // Must be locked
      expect(container.read(appLockControllerProvider), isTrue,
          reason: 'App must be locked after real screen-off even if within 300ms of biometric unlock');
    });

    test('Reproduction 2: Screen lock / app switch while system dialog active locks reliably', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      appLockNotifier.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // User opens a system permission dialog
      appLockNotifier.setSystemDialogActive(true);

      // User turns off screen or switches apps while permission dialog was active
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Dialog dismissed/closed
      appLockNotifier.setSystemDialogActive(false);

      // App resumed
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(appLockControllerProvider), isTrue,
          reason: 'App must lock if paused/backgrounded even if a system dialog was open at the time');
    });

    test('Rapid backgrounding (< 10ms) and immediate resume still locks app', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      appLockNotifier.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // Rapid sequence: inactive -> paused -> resumed in quick succession
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.inactive);
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(appLockControllerProvider), isTrue,
          reason: 'Rapid backgrounding must lock the app');
    });

    test('Rapid screen off via hidden state locks app immediately', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      appLockNotifier.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // Flutter 3.13+ hidden lifecycle event
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.hidden);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(appLockControllerProvider), isTrue,
          reason: 'Hidden state must lock the app immediately');
    });

    test('Debounce boundary: Inactive for 400ms followed by resume does NOT lock (transient drop down)', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      appLockNotifier.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future.delayed(const Duration(milliseconds: 400));
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(container.read(appLockControllerProvider), isFalse,
          reason: 'Brief transient inactive under 500ms threshold should not lock');
    });

    test('Debounce boundary: Inactive for 550ms without resume DOES lock (prolonged inactive)', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      appLockNotifier.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await Future.delayed(const Duration(milliseconds: 550));

      expect(container.read(appLockControllerProvider), isTrue,
          reason: 'Inactive state exceeding 500ms debounce threshold must lock');
    });

    test('Complex overlapping transitions sequence leaves app securely locked', () async {
      final appLockNotifier = container.read(appLockControllerProvider.notifier);
      appLockNotifier.unlock();
      expect(container.read(appLockControllerProvider), isFalse);

      // Rapidly overlapping events:
      appLockNotifier.setSystemDialogActive(true);
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.inactive);
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.hidden);
      appLockNotifier.setSystemDialogActive(false);
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      appLockNotifier.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container.read(appLockControllerProvider), isTrue,
          reason: 'Overlapping transition sequence must end in locked state');
    });
  });
}
