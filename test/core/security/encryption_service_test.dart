import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/security/encryption_service.dart';

void main() {
  late EncryptionService encryptionService;
  late String key;

  setUp(() {
    key = base64Encode(List.generate(32, (_) => Random.secure().nextInt(256)));
    encryptionService = EncryptionService(key);
  });

  test('encrypt and decrypt round trip', () {
    const plainText = 'My secret data';
    final encrypted = encryptionService.encrypt(plainText);
    
    expect(encrypted, isNot(plainText));
    expect(encrypted.contains(':'), isTrue);

    final decrypted = encryptionService.decrypt(encrypted);
    expect(decrypted, equals(plainText));
  });

  test('decrypt fails on malformed input', () {
    expect(() => encryptionService.decrypt('invalid_data'), throwsFormatException);
  });

  test('decrypt fails with wrong key', () {
    const plainText = 'My secret data';
    final encrypted = encryptionService.encrypt(plainText);
    
    final wrongKey = base64Encode(List.generate(32, (_) => Random.secure().nextInt(256)));
    final wrongService = EncryptionService(wrongKey);

    expect(() => wrongService.decrypt(encrypted), throwsArgumentError);
  });
}
