import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'secure_key_storage.dart';

part 'pin_service.g.dart';

class PinService {
  final SecureKeyStorage _storage;
  static const _pinHashKey = 'user_pin_hash';
  static const _pinSaltKey = 'user_pin_salt';
  
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
  }

  Future<bool> verifyPin(String pin) async {
    final storedSaltBase64 = await _storage.getKey(_pinSaltKey);
    final storedHashBase64 = await _storage.getKey(_pinHashKey);

    if (storedSaltBase64 == null || storedHashBase64 == null) return false;

    final salt = base64Decode(storedSaltBase64);
    final storedHash = base64Decode(storedHashBase64);

    final hash = _hashPin(pin, salt);
    
    if (hash.length != storedHash.length) return false;
    for (int i = 0; i < hash.length; i++) {
      if (hash[i] != storedHash[i]) return false;
    }
    return true;
  }

  Future<void> removePin() async {
    await _storage.deleteKey(_pinHashKey);
    await _storage.deleteKey(_pinSaltKey);
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
PinService pinService(PinServiceRef ref) {
  final storage = ref.watch(secureKeyStorageProvider);
  return PinService(storage);
}
