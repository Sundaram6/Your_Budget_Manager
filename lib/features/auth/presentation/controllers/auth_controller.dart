import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/security/app_lock_controller.dart';
import '../../../../core/security/biometric_service.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> setupPin(String pin) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pinService = ref.read(pinServiceProvider);
      await pinService.setPin(pin);
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
    final biometricService = ref.read(biometricServiceProvider);
    final isAvailable = await biometricService.isBiometricAvailable();
    if (!isAvailable) return false;

    final success = await biometricService.authenticate(reason);
    if (success) {
      ref.read(appLockControllerProvider.notifier).unlock();
    }
    return success;
  }
}
