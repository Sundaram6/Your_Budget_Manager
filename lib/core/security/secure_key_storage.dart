import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_key_storage.g.dart';

class SecureKeyStorage {
  final FlutterSecureStorage _storage;

  SecureKeyStorage(this._storage);

  Future<void> saveKey(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getKey(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }
}

@riverpod
SecureKeyStorage secureKeyStorage(SecureKeyStorageRef ref) {
  const storage = FlutterSecureStorage();
  return SecureKeyStorage(storage);
}
