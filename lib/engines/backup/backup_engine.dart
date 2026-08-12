import 'dart:convert';

import '../../core/errors/app_exception.dart';
import '../../core/security/encryption_service.dart';
import '../../database/app_database.dart';

class BackupEngine {
  final AppDatabase _db;

  BackupEngine(this._db);

  Future<String> exportData(String passphrase) async {
    final categories = await _db.select(_db.categoriesTable).get();
    final merchants = await _db.select(_db.merchantsTable).get();
    final transactions = await _db.select(_db.transactionsTable).get();
    final budgets = await _db.select(_db.budgetsTable).get();
    final recurring = await _db.select(_db.recurringTransactionsTable).get();
    final savingsGoals = await _db.select(_db.savingsGoalsTable).get();
    final settings = await _db.select(_db.appSettingsTable).get();

    final data = {
      'categories': categories.map((e) => e.toJson()).toList(),
      'merchants': merchants.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((e) => e.toJson()).toList(),
      'recurringTransactions': recurring.map((e) => e.toJson()).toList(),
      'savingsGoals': savingsGoals.map((e) => e.toJson()).toList(),
      'appSettings': settings.map((e) => e.toJson()).toList(),
    };

    final payload = {
      'formatVersion': 2,
      'appVersion': '1.0.0',
      'exportedAt': DateTime.now().millisecondsSinceEpoch,
      'dbSchemaVersion': _db.schemaVersion,
      'data': data,
    };

    final jsonString = jsonEncode(payload);
    return EncryptionService.encryptWithPassphrase(jsonString, passphrase);
  }

  Future<void> importData(String encryptedData, String passphrase) async {
    String jsonString;
    try {
      jsonString = EncryptionService.decryptWithPassphrase(encryptedData, passphrase);
    } catch (e) {
      throw CryptographyException('Failed to decrypt data. Invalid passphrase or corrupted/tampered file.', e);
    }

    dynamic rawPayload;
    try {
      rawPayload = jsonDecode(jsonString);
    } catch (e) {
      throw const ValidationException('Invalid backup format: Decrypted data is not valid JSON.');
    }

    if (rawPayload is! Map<String, dynamic>) {
      throw const ValidationException('Invalid backup format: root must be a JSON object.');
    }

    final payload = rawPayload;
    final formatVersion = payload['formatVersion'] as int?;

    if (formatVersion == null) {
      throw const ValidationException('Invalid backup format: missing formatVersion.');
    }

    if (formatVersion > 2) {
      throw const ValidationException('This backup was created by a newer version of the app');
    }

    if (payload['data'] == null || payload['data'] is! Map<String, dynamic>) {
      throw const ValidationException('Invalid backup format: missing or malformed data payload.');
    }

    switch (formatVersion) {
      case 1:
      case 2:
        await _importValidatedPayload(payload);
        break;
      default:
        throw ValidationException('Unsupported backup format version: $formatVersion');
    }
  }

  Future<void> _importValidatedPayload(Map<String, dynamic> payload) async {
    final data = payload['data'] as Map<String, dynamic>? ?? {};

    // Pre-validate all data lists before touching database
    final List<Category> categories = [];
    final List<Merchant> merchants = [];
    final List<Budget> budgets = [];
    final List<RecurringTransactionData> recurring = [];
    final List<SavingsGoal> savingsGoals = [];
    final List<Transaction> transactions = [];
    final List<AppSetting> settings = [];

    try {
      if (data.containsKey('categories') && data['categories'] is List) {
        for (var item in (data['categories'] as List)) {
          if (item is Map<String, dynamic>) {
            categories.add(Category.fromJson(item));
          }
        }
      }

      if (data.containsKey('merchants') && data['merchants'] is List) {
        for (var item in (data['merchants'] as List)) {
          if (item is Map<String, dynamic>) {
            merchants.add(Merchant.fromJson(item));
          }
        }
      }

      if (data.containsKey('budgets') && data['budgets'] is List) {
        for (var item in (data['budgets'] as List)) {
          if (item is Map<String, dynamic>) {
            budgets.add(Budget.fromJson(item));
          }
        }
      }

      if (data.containsKey('recurringTransactions') && data['recurringTransactions'] is List) {
        for (var item in (data['recurringTransactions'] as List)) {
          if (item is Map<String, dynamic>) {
            recurring.add(RecurringTransactionData.fromJson(item));
          }
        }
      }

      if (data.containsKey('savingsGoals') && data['savingsGoals'] is List) {
        for (var item in (data['savingsGoals'] as List)) {
          if (item is Map<String, dynamic>) {
            savingsGoals.add(SavingsGoal.fromJson(item));
          }
        }
      }

      if (data.containsKey('transactions') && data['transactions'] is List) {
        for (var item in (data['transactions'] as List)) {
          if (item is Map<String, dynamic>) {
            transactions.add(Transaction.fromJson(item));
          }
        }
      }

      if (data.containsKey('appSettings') && data['appSettings'] is List) {
        for (var item in (data['appSettings'] as List)) {
          if (item is Map<String, dynamic>) {
            settings.add(AppSetting.fromJson(item));
          }
        }
      }
    } catch (e) {
      throw ValidationException('Backup payload schema validation failed: $e');
    }

    // Atomic database replacement:
    // If any insert fails, transaction rolls back completely and existing DB is unchanged.
    await _db.transaction(() async {
      // Clear tables in reverse dependency order
      await _db.delete(_db.transactionsTable).go();
      await _db.delete(_db.savingsGoalsTable).go();
      await _db.delete(_db.recurringTransactionsTable).go();
      await _db.delete(_db.merchantsTable).go();
      await _db.delete(_db.budgetsTable).go();
      await _db.delete(_db.categoriesTable).go();
      await _db.delete(_db.appSettingsTable).go();

      // Insert pre-validated records in topological dependency order
      for (final cat in categories) {
        await _db.into(_db.categoriesTable).insert(cat);
      }

      for (final merch in merchants) {
        await _db.into(_db.merchantsTable).insert(merch);
      }

      for (final b in budgets) {
        await _db.into(_db.budgetsTable).insert(b);
      }

      for (final r in recurring) {
        await _db.into(_db.recurringTransactionsTable).insert(r);
      }

      for (final goal in savingsGoals) {
        await _db.into(_db.savingsGoalsTable).insert(goal);
      }

      for (final tx in transactions) {
        await _db.into(_db.transactionsTable).insert(tx);
      }

      for (final setting in settings) {
        await _db.into(_db.appSettingsTable).insert(setting);
      }
    });
  }
}
