import 'package:encrypt/encrypt.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'encryption_service.g.dart';

class EncryptionService {
  final Key _key;

  EncryptionService(String base64Key) : _key = Key.fromBase64(base64Key);

  String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    return '${iv.base64}:${encrypted.base64}';
  }

  String decrypt(String encryptedText) {
    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid encrypted text format');
    }

    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    return encrypter.decrypt(encrypted, iv: iv);
  }
}

@riverpod
EncryptionService encryptionService(EncryptionServiceRef ref, String base64Key) {
  return EncryptionService(base64Key);
}
