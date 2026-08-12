import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service responsible for managing the 256-bit database encryption key.
/// Key is stored in secure hardware-backed storage (Android Keystore / iOS Keychain)
/// and is never derived from PIN, password, or user input.
class DatabaseKeyService {
  static const String _dbKeyStorageKey = 'ybm_db_encryption_key';
  final FlutterSecureStorage _storage;

  DatabaseKeyService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// Retrieves the existing 256-bit database key, or generates and securely stores a new one.
  Future<String> getOrCreateDbKey() async {
    final existingKey = await _storage.read(key: _dbKeyStorageKey);
    if (existingKey != null && existingKey.isNotEmpty) {
      return existingKey;
    }

    final newKey = _generateSecureKey();
    await _storage.write(key: _dbKeyStorageKey, value: newKey);
    return newKey;
  }

  /// Generates a cryptographically secure 256-bit (32-byte) key encoded in base64.
  String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }
}
