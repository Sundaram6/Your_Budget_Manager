import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'secure_key_storage.dart';

part 'pin_service.g.dart';

class PinService {
  final SecureKeyStorage _storage;
  static const _pinHashKey = 'user_pin_hash';
  static const _pinSaltKey = 'user_pin_salt';
  static const _failedAttemptsKey = 'failed_pin_attempts';
  static const _lockoutUntilMsKey = 'pin_lockout_until_ms';
  
  PinService(this._storage);

  Future<bool> hasPin() async {
    final hash = await _storage.getKey(_pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _storage.saveKey(_pinSaltKey, base64Encode(salt));
    await _storage.saveKey(_pinHashKey, base64Encode(hash));
    await recordSuccessfulAttempt();
  }

  Future<int> getFailedAttempts() async {
    final str = await _storage.getKey(_failedAttemptsKey);
    return str != null ? int.tryParse(str) ?? 0 : 0;
  }

  Future<int> getRemainingLockoutSeconds() async {
    final str = await _storage.getKey(_lockoutUntilMsKey);
    if (str == null) return 0;
    final lockoutUntilMs = int.tryParse(str) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final diffMs = lockoutUntilMs - nowMs;
    return diffMs > 0 ? (diffMs / 1000).ceil() : 0;
  }

  Future<bool> isLockedOut() async {
    return (await getRemainingLockoutSeconds()) > 0;
  }

  Future<int> recordFailedAttempt() async {
    final current = await getFailedAttempts();
    final newCount = current + 1;
    await _storage.saveKey(_failedAttemptsKey, newCount.toString());

    int lockoutDurationSeconds = 0;
    if (newCount >= 10) {
      lockoutDurationSeconds = 300; // 5 minutes lockout after 10 failures
    } else if (newCount >= 5) {
      lockoutDurationSeconds = 30; // 30 seconds lockout after 5 failures
    }

    if (lockoutDurationSeconds > 0) {
      final lockoutUntilMs = DateTime.now().millisecondsSinceEpoch + (lockoutDurationSeconds * 1000);
      await _storage.saveKey(_lockoutUntilMsKey, lockoutUntilMs.toString());
    }

    return lockoutDurationSeconds;
  }

  Future<void> recordSuccessfulAttempt() async {
    await _storage.deleteKey(_failedAttemptsKey);
    await _storage.deleteKey(_lockoutUntilMsKey);
  }

  Future<bool> verifyPin(String pin) async {
    if (await isLockedOut()) return false;

    final storedSaltBase64 = await _storage.getKey(_pinSaltKey);
    final storedHashBase64 = await _storage.getKey(_pinHashKey);

    if (storedSaltBase64 == null || storedHashBase64 == null) return false;

    final salt = base64Decode(storedSaltBase64);
    final storedHash = base64Decode(storedHashBase64);

    final hash = _hashPin(pin, salt);
    
    bool matches = (hash.length == storedHash.length);
    if (matches) {
      for (int i = 0; i < hash.length; i++) {
        if (hash[i] != storedHash[i]) {
          matches = false;
          break;
        }
      }
    }

    if (matches) {
      await recordSuccessfulAttempt();
      return true;
    } else {
      await recordFailedAttempt();
      return false;
    }
  }

  Future<void> removePin() async {
    await _storage.deleteKey(_pinHashKey);
    await _storage.deleteKey(_pinSaltKey);
    await _storage.deleteKey(_failedAttemptsKey);
    await _storage.deleteKey(_lockoutUntilMsKey);
  }

  Uint8List _generateSalt([int length = 16]) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }

  Uint8List _hashPin(String pin, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, 10000, 32));
    
    return derivator.process(Uint8List.fromList(utf8.encode(pin)));
  }
}

@riverpod
PinService pinService(Ref ref) {
  final storage = ref.watch(secureKeyStorageProvider);
  return PinService(storage);
}
