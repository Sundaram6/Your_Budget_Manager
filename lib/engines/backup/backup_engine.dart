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
        await _importValidatedPayload(payload, formatVersion);
        break;
      default:
        throw ValidationException('Unsupported backup format version: $formatVersion');
    }
  }

  Future<void> _importValidatedPayload(Map<String, dynamic> payload, int formatVersion) async {
    final data = payload['data'] as Map<String, dynamic>? ?? {};

    // 1. Strict top-level section completeness check
    if (formatVersion == 2) {
      const requiredSections = [
        'categories',
        'merchants',
        'budgets',
        'recurringTransactions',
        'savingsGoals',
        'transactions',
      ];

      for (final section in requiredSections) {
        if (!data.containsKey(section) || data[section] == null) {
          throw ValidationException(
            'Backup payload is corrupted or incomplete: missing expected section "$section" in v2 backup.',
          );
        }
        if (data[section] is! List) {
          throw ValidationException(
            'Backup payload schema validation failed: section "$section" must be a JSON array.',
          );
        }
      }
    } else {
      // Legacy v1 schema requires categories and transactions
      const requiredV1Sections = ['categories', 'transactions'];
      for (final section in requiredV1Sections) {
        if (!data.containsKey(section) || data[section] == null) {
          throw ValidationException(
            'Backup payload is corrupted or incomplete: missing expected section "$section" in v1 backup.',
          );
        }
        if (data[section] is! List) {
          throw ValidationException(
            'Backup payload schema validation failed: section "$section" must be a JSON array.',
          );
        }
      }
    }

    // 2. Strict item-level field and structure validation
    final List<Category> categories = [];
    final List<Merchant> merchants = [];
    final List<Budget> budgets = [];
    final List<RecurringTransactionData> recurring = [];
    final List<SavingsGoal> savingsGoals = [];
    final List<Transaction> transactions = [];
    final List<AppSetting> settings = [];

    try {
      // Categories validation
      if (data.containsKey('categories') && data['categories'] is List) {
        for (final item in (data['categories'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Category item is not a JSON object');
          }
          if (item['id'] is! String || item['name'] is! String) {
            throw const FormatException('Category item missing required string fields (id, name)');
          }
          categories.add(Category.fromJson(item));
        }
      }

      // Merchants validation
      if (data.containsKey('merchants') && data['merchants'] is List) {
        for (final item in (data['merchants'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Merchant item is not a JSON object');
          }
          if (item['id'] is! String || item['name'] is! String) {
            throw const FormatException('Merchant item missing required string fields (id, name)');
          }
          merchants.add(Merchant.fromJson(item));
        }
      }

      // Budgets validation
      if (data.containsKey('budgets') && data['budgets'] is List) {
        for (final item in (data['budgets'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Budget item is not a JSON object');
          }
          if (item['id'] is! String || item['amount'] is! num) {
            throw const FormatException('Budget item missing required fields (id, amount)');
          }
          budgets.add(Budget.fromJson(item));
        }
      }

      // Recurring Transactions validation
      if (data.containsKey('recurringTransactions') && data['recurringTransactions'] is List) {
        for (final item in (data['recurringTransactions'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Recurring transaction item is not a JSON object');
          }
          if (item['id'] is! String || item['title'] is! String) {
            throw const FormatException('Recurring transaction item missing required fields (id, title)');
          }
          recurring.add(RecurringTransactionData.fromJson(item));
        }
      }

      // Savings Goals validation (required in v2, optional in v1)
      if (data.containsKey('savingsGoals') && data['savingsGoals'] != null) {
        for (final item in (data['savingsGoals'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Savings goal item is not a JSON object');
          }
          if (item['id'] is! String ||
              item['name'] is! String ||
              item['targetAmount'] is! num ||
              item['currentAmount'] is! num) {
            throw const FormatException('Savings goal item missing required fields (id, name, targetAmount, currentAmount)');
          }
          savingsGoals.add(SavingsGoal.fromJson(item));
        }
      }

      // Transactions validation
      if (data.containsKey('transactions') && data['transactions'] is List) {
        for (final item in (data['transactions'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Transaction item is not a JSON object');
          }
          if (item['id'] is! String ||
              item['amount'] is! num ||
              item['type'] is! String ||
              item['categoryId'] is! String ||
              item['date'] is! num) {
            throw const FormatException('Transaction item missing required fields (id, amount, type, categoryId, date)');
          }
          transactions.add(Transaction.fromJson(item));
        }
      }

      // App Settings validation (optional)
      if (data.containsKey('appSettings') && data['appSettings'] is List) {
        for (final item in (data['appSettings'] as List)) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('App setting item is not a JSON object');
          }
          if (item['key'] is! String || item['value'] is! String) {
            throw const FormatException('App setting item missing key or value');
          }
          settings.add(AppSetting.fromJson(item));
        }
      }
    } catch (e) {
      throw ValidationException('Backup payload schema validation failed: $e');
    }

    // Atomic database replacement:
    // Only executed after 100% of the payload passes strict schema and completeness checks.
    // If any DB operation fails, the transaction rolls back completely and existing DB is unchanged.
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
