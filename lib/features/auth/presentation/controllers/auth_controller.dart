import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/security/app_lock_controller.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/pin_service.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> setupPin(String pin) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pinService = ref.read(pinServiceProvider);
      await pinService.setPin(pin);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pin_setup_complete', true);
      await prefs.setBool('pinSetupComplete', true);
      await prefs.setBool('hasSkippedPinSetup', false);
      await prefs.setBool('has_skipped_pin', false);
      await prefs.reload();
    });
  }

  Future<void> skipPinSetup() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pin_setup_complete', true);
      await prefs.setBool('pinSetupComplete', true);
      await prefs.setBool('hasSkippedPinSetup', true);
      await prefs.setBool('has_skipped_pin', true);
      await prefs.reload();
    });
  }

  Future<bool> verifyPin(String pin) async {
    final pinService = ref.read(pinServiceProvider);
    final isValid = await pinService.verifyPin(pin);
    if (isValid) {
      ref.read(appLockControllerProvider.notifier).unlock();
    }
    return isValid;
  }

  Future<bool> authenticateBiometric(String reason) async {
    final appLockNotifier = ref.read(appLockControllerProvider.notifier);
    appLockNotifier.setAuthenticating(true);

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final isAvailable = await biometricService.isBiometricAvailable();
      if (!isAvailable) return false;

      final success = await biometricService.authenticate(reason);
      if (success) {
        appLockNotifier.unlock();
      }
      return success;
    } finally {
      appLockNotifier.setAuthenticating(false);
    }
  }
}
