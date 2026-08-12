import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'biometric_service.g.dart';

class BiometricService {
  final LocalAuthentication _auth;

  BiometricService(this._auth);

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!canAuthenticateWithBiometrics && !isDeviceSupported) {
        return false;
      }
      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty || canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (e, stack) {
      developer.log('Error checking biometric availability', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
        biometricOnly: false,
        sensitiveTransaction: true,
      );
    } on PlatformException catch (e, stack) {
      developer.log(
        'PlatformException during biometric authentication: ${e.code} - ${e.message}',
        error: e,
        stackTrace: stack,
      );
      return false;
    } catch (e, stack) {
      developer.log(
        'Unexpected error during biometric authentication',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}

@riverpod
BiometricService biometricService(Ref ref) {
  return BiometricService(LocalAuthentication());
}
