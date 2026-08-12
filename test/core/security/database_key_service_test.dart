import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/security/database_key_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late DatabaseKeyService keyService;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    keyService = DatabaseKeyService(mockStorage);
  });

  group('DatabaseKeyService', () {
    test('generates and stores 256-bit key when no key exists', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final key = await keyService.getOrCreateDbKey();

      expect(key, isNotEmpty);
      final decodedBytes = base64Decode(key);
      expect(decodedBytes.length, equals(32)); // 256 bits

      verify(() => mockStorage.read(key: 'ybm_db_encryption_key')).called(1);
      verify(() => mockStorage.write(key: 'ybm_db_encryption_key', value: key)).called(1);
    });

    test('returns existing key when present in storage', () async {
      const existingKey = 'dGVzdF9leGlzdGluZ19rZXlfMjU2X2JpdHNfc2VjdXJlIQ==';
      when(() => mockStorage.read(key: 'ybm_db_encryption_key'))
          .thenAnswer((_) async => existingKey);

      final key = await keyService.getOrCreateDbKey();

      expect(key, equals(existingKey));
      verify(() => mockStorage.read(key: 'ybm_db_encryption_key')).called(1);
      verifyNever(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')));
    });
  });
}
