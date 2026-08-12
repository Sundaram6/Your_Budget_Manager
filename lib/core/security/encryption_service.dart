import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' as pc;
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

  /// Encrypts plainText using PBKDF2-HMAC-SHA256 key derivation and Encrypt-then-MAC (AES-256-CBC + HMAC-SHA256).
  /// Output format: `v2:<salt_base64>:<iv_base64>:<ciphertext_base64>:<hmac_base64>`
  static String encryptWithPassphrase(String plainText, String passphrase, {int iterations = 100000}) {
    final salt = _generateSecureRandomBytes(16);
    final derivedKeys = _deriveKeys(passphrase, salt, iterations: iterations);
    final encKey = Key(derivedKeys.sublist(0, 32));
    final macKey = derivedKeys.sublist(32, 64);

    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(encKey, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Compute HMAC-SHA256 over salt + iv + ciphertext (Encrypt-then-MAC)
    final hmac = _computeHmac(macKey, [...salt, ...iv.bytes, ...encrypted.bytes]);

    return 'v2:${base64.encode(salt)}:${iv.base64}:${encrypted.base64}:${base64.encode(hmac)}';
  }

  /// Decrypts encryptedData with passphrase.
  /// Supports:
  /// - Modern `v2:` envelopes: verifies HMAC integrity before decrypting.
  /// - Legacy `v1` envelopes (`iv:ciphertext`): uses legacy single-round SHA-256 for backward compatibility.
  static String decryptWithPassphrase(String encryptedData, String passphrase, {int iterations = 100000}) {
    if (encryptedData.startsWith('v2:')) {
      final parts = encryptedData.split(':');
      if (parts.length != 5) {
        throw const FormatException('Invalid v2 backup format. Expected 5 colon-separated components.');
      }

      final salt = base64.decode(parts[1]);
      final ivBytes = base64.decode(parts[2]);
      final cipherBytes = base64.decode(parts[3]);
      final expectedHmac = base64.decode(parts[4]);

      final derivedKeys = _deriveKeys(passphrase, Uint8List.fromList(salt), iterations: iterations);
      final encKey = Key(derivedKeys.sublist(0, 32));
      final macKey = derivedKeys.sublist(32, 64);

      // Verify HMAC in constant time BEFORE attempting decryption
      final computedHmac = _computeHmac(macKey, [...salt, ...ivBytes, ...cipherBytes]);
      if (!_constantTimeEquals(computedHmac, expectedHmac)) {
        throw const FormatException('Backup integrity verification failed. File is corrupted, tampered, or invalid passphrase.');
      }

      final encrypter = Encrypter(AES(encKey, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(Encrypted(Uint8List.fromList(cipherBytes)), iv: IV(Uint8List.fromList(ivBytes)));
      return decrypted;
    } else {
      // Legacy v1 backup: single-round SHA-256 key derivation + AES-CBC
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw const FormatException('Invalid legacy backup format. Expected 2 colon-separated components.');
      }

      final bytes = utf8.encode(passphrase);
      final digest = crypto.sha256.convert(bytes);
      final key = Key(Uint8List.fromList(digest.bytes));

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    }
  }

  static Uint8List _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }

  static Uint8List _deriveKeys(String passphrase, Uint8List salt, {int iterations = 100000}) {
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(salt, iterations, 64));
    return derivator.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  static Uint8List _computeHmac(Uint8List key, List<int> message) {
    final hmac = pc.HMac(pc.SHA256Digest(), 64)..init(pc.KeyParameter(key));
    return hmac.process(Uint8List.fromList(message));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

@riverpod
EncryptionService encryptionService(Ref ref, String base64Key) {
  return EncryptionService(base64Key);
}
