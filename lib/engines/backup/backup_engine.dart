import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/errors/app_exception.dart';
import '../../core/security/encryption_service.dart';
import '../../database/app_database.dart';

class BackupEngine {
  final AppDatabase _db;

  BackupEngine(this._db);

  String _deriveKey(String passphrase) {
    final bytes = utf8.encode(passphrase);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }

  Future<String> exportData(String passphrase) async {
    final categories = await _db.select(_db.categoriesTable).get();
    final merchants = await _db.select(_db.merchantsTable).get();
    final transactions = await _db.select(_db.transactionsTable).get();
    final budgets = await _db.select(_db.budgetsTable).get();
    final recurring = await _db.select(_db.recurringTransactionsTable).get();
    final settings = await _db.select(_db.appSettingsTable).get();

    final data = {
      'categories': categories.map((e) => e.toJson()).toList(),
      'merchants': merchants.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((e) => e.toJson()).toList(),
      'recurringTransactions': recurring.map((e) => e.toJson()).toList(),
      'appSettings': settings.map((e) => e.toJson()).toList(),
    };

    final payload = {
      'formatVersion': 1,
      'appVersion': '1.0.0',
      'exportedAt': DateTime.now().millisecondsSinceEpoch,
      'dbSchemaVersion': _db.schemaVersion,
      'data': data,
    };

    final jsonString = jsonEncode(payload);
    
    final key = _deriveKey(passphrase);
    final encryptionService = EncryptionService(key);
    
    return encryptionService.encrypt(jsonString);
  }

  Future<void> importData(String encryptedData, String passphrase) async {
    final key = _deriveKey(passphrase);
    final encryptionService = EncryptionService(key);
    
    String jsonString;
    try {
      jsonString = encryptionService.decrypt(encryptedData);
    } catch (e) {
      throw CryptographyException('Failed to decrypt data. Invalid passphrase or corrupted file.', e);
    }

    final payload = jsonDecode(jsonString) as Map<String, dynamic>;
    final formatVersion = payload['formatVersion'] as int?;

    if (formatVersion == null) {
      throw const ValidationException('Invalid backup format: missing formatVersion.');
    }

    if (formatVersion > 1) {
      throw const ValidationException('This backup was created by a newer version of the app');
    }

    switch (formatVersion) {
      case 1:
        await _importVersion1(payload);
        break;
      default:
        throw ValidationException('Unsupported backup format version: $formatVersion');
    }
  }

  Future<void> _importVersion1(Map<String, dynamic> payload) async {
    final data = payload['data'] as Map<String, dynamic>? ?? {};

    await _db.transaction(() async {
      // Clear tables
      await _db.delete(_db.categoriesTable).go();
      await _db.delete(_db.merchantsTable).go();
      await _db.delete(_db.transactionsTable).go();
      await _db.delete(_db.budgetsTable).go();
      await _db.delete(_db.recurringTransactionsTable).go();
      await _db.delete(_db.appSettingsTable).go();

      // Insert data if present
      if (data.containsKey('categories')) {
        for (var item in (data['categories'] as List)) {
          await _db.into(_db.categoriesTable).insert(Category.fromJson(item as Map<String, dynamic>));
        }
      }
      
      if (data.containsKey('merchants')) {
        for (var item in (data['merchants'] as List)) {
          await _db.into(_db.merchantsTable).insert(Merchant.fromJson(item as Map<String, dynamic>));
        }
      }

      if (data.containsKey('transactions')) {
        for (var item in (data['transactions'] as List)) {
          await _db.into(_db.transactionsTable).insert(Transaction.fromJson(item as Map<String, dynamic>));
        }
      }

      if (data.containsKey('budgets')) {
        for (var item in (data['budgets'] as List)) {
          await _db.into(_db.budgetsTable).insert(Budget.fromJson(item as Map<String, dynamic>));
        }
      }

      if (data.containsKey('recurringTransactions')) {
        for (var item in (data['recurringTransactions'] as List)) {
          await _db.into(_db.recurringTransactionsTable).insert(RecurringTransaction.fromJson(item as Map<String, dynamic>));
        }
      }

      if (data.containsKey('appSettings')) {
        for (var item in (data['appSettings'] as List)) {
          await _db.into(_db.appSettingsTable).insert(AppSetting.fromJson(item as Map<String, dynamic>));
        }
      }
    });
  }
}
