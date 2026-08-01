import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/security/encryption_service.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';

void main() {
  late AppDatabase db;
  late BackupEngine backupEngine;
  const passphrase = 'test_passphrase';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backupEngine = BackupEngine(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('exportData and importData should round-trip correctly', () async {
    // Insert some test data
    const category = Category(
      id: 'cat-1',
      name: 'Food',
      icon: 'food_icon',
      color: '#000000',
      isDefault: false,
      sortOrder: 0,
      createdAt: 1000,
      updatedAt: 1000,
    );
    await db.into(db.categoriesTable).insert(category);

    const merchant = Merchant(
      id: 'merch-1',
      name: 'Supermarket',
      icon: 'supermarket_icon',
      createdAt: 1000,
      updatedAt: 1000,
    );
    await db.into(db.merchantsTable).insert(merchant);

    // Export data
    final encryptedData = await backupEngine.exportData(passphrase);
    expect(encryptedData, isNotEmpty);

    // Clear database
    await db.delete(db.categoriesTable).go();
    await db.delete(db.merchantsTable).go();

    final catsBeforeImport = await db.select(db.categoriesTable).get();
    expect(catsBeforeImport, isEmpty);

    // Import data
    await backupEngine.importData(encryptedData, passphrase);

    // Verify
    final catsAfterImport = await db.select(db.categoriesTable).get();
    expect(catsAfterImport.length, 1);
    expect(catsAfterImport.first.name, 'Food');

    final merchAfterImport = await db.select(db.merchantsTable).get();
    expect(merchAfterImport.length, 1);
    expect(merchAfterImport.first.name, 'Supermarket');
  });

  test('importData handles missing fields gracefully', () async {
    final payload = {
      'formatVersion': 1,
      'appVersion': '1.0.0',
      'exportedAt': 1735689600,
      'dbSchemaVersion': 1,
      'data': {
        // merchants missing
        'categories': [
          {
            'id': 'cat-2',
            'name': 'Transport',
            'icon': 'car',
            'color': '#123456',
            'isDefault': false,
            'sortOrder': 0,
            'createdAt': 1000,
            'updatedAt': 1000,
          }
        ]
      }
    };

    final bytes = utf8.encode(passphrase);
    final key = base64.encode(sha256.convert(bytes).bytes);
    final encryptionService = EncryptionService(key);
    final encryptedData = encryptionService.encrypt(jsonEncode(payload));

    await backupEngine.importData(encryptedData, passphrase);

    final cats = await db.select(db.categoriesTable).get();
    expect(cats.length, 1);
    expect(cats.first.name, 'Transport');

    final merchants = await db.select(db.merchantsTable).get();
    expect(merchants, isEmpty);
  });

  test('importData throws on unknown future formatVersion', () async {
    final payload = {
      'formatVersion': 2,
      'appVersion': '2.0.0',
      'data': {}
    };

    final bytes = utf8.encode(passphrase);
    final key = base64.encode(sha256.convert(bytes).bytes);
    final encryptionService = EncryptionService(key);
    final encryptedData = encryptionService.encrypt(jsonEncode(payload));

    expect(
      () => backupEngine.importData(encryptedData, passphrase),
      throwsA(isA<Exception>()),
    );
  });
}
