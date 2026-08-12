import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/security/pin_service.dart';
import 'package:your_budget_manager/core/security/secure_key_storage.dart';

class InMemorySecureKeyStorage implements SecureKeyStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> getKey(String key) async => _storage[key];

  @override
  Future<void> saveKey(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<void> deleteKey(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

void main() {
  late InMemorySecureKeyStorage storage;
  late PinService pinService;

  setUp(() async {
    storage = InMemorySecureKeyStorage();
    pinService = PinService(storage);
    await pinService.setPin('1234');
  });

  group('PinService - Lockout and Rate Limiting', () {
    test('1 to 4 failed attempts do not trigger lockout', () async {
      for (int i = 1; i <= 4; i++) {
        final result = await pinService.verifyPin('0000');
        expect(result, isFalse);
        expect(await pinService.getFailedAttempts(), i);
        expect(await pinService.isLockedOut(), isFalse);
        expect(await pinService.getRemainingLockoutSeconds(), 0);
      }

      // Valid PIN still succeeds
      final success = await pinService.verifyPin('1234');
      expect(success, isTrue);
      expect(await pinService.getFailedAttempts(), 0);
    });

    test('5 consecutive failed attempts trigger 30-second lockout', () async {
      for (int i = 0; i < 4; i++) {
        await pinService.verifyPin('0000');
      }

      // 5th attempt
      final result5 = await pinService.verifyPin('0000');
      expect(result5, isFalse);
      expect(await pinService.getFailedAttempts(), 5);
      expect(await pinService.isLockedOut(), isTrue);
      
      final remaining = await pinService.getRemainingLockoutSeconds();
      expect(remaining, greaterThanOrEqualTo(28));
      expect(remaining, lessThanOrEqualTo(30));

      // During lockout, even correct PIN is rejected
      final duringLockout = await pinService.verifyPin('1234');
      expect(duringLockout, isFalse);
    });

    test('10 consecutive failed attempts escalate lockout to 5 minutes (300s)', () async {
      for (int i = 0; i < 9; i++) {
        await pinService.recordFailedAttempt();
      }
      expect(await pinService.getFailedAttempts(), 9);

      // 10th attempt via verifyPin (simulate waiting out first lockout and failing again)
      // Clear lockout timestamp temporarily to allow 10th verify attempt
      await storage.deleteKey('pin_lockout_until_ms');
      final result10 = await pinService.verifyPin('0000');
      expect(result10, isFalse);
      expect(await pinService.getFailedAttempts(), 10);
      expect(await pinService.isLockedOut(), isTrue);

      final remaining = await pinService.getRemainingLockoutSeconds();
      expect(remaining, greaterThanOrEqualTo(290));
      expect(remaining, lessThanOrEqualTo(300));
    });

    test('successful PIN entry resets failed attempts and lockout to 0', () async {
      await pinService.verifyPin('9999');
      await pinService.verifyPin('9999');
      expect(await pinService.getFailedAttempts(), 2);

      final success = await pinService.verifyPin('1234');
      expect(success, isTrue);
      expect(await pinService.getFailedAttempts(), 0);
      expect(await pinService.isLockedOut(), isFalse);
      expect(await pinService.getRemainingLockoutSeconds(), 0);
    });

    test('lockout state persists across new PinService instance (simulating app restart)', () async {
      for (int i = 0; i < 5; i++) {
        await pinService.verifyPin('0000');
      }
      expect(await pinService.isLockedOut(), isTrue);

      // Create brand new PinService instance backed by same storage
      final restartedPinService = PinService(storage);
      expect(await restartedPinService.isLockedOut(), isTrue);
      expect(await restartedPinService.getFailedAttempts(), 5);
      expect(await restartedPinService.getRemainingLockoutSeconds(), greaterThan(0));

      // Rejection persists
      expect(await restartedPinService.verifyPin('1234'), isFalse);
    });
  });
}
