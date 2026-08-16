import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;

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

    return compute(
      _exportPayloadWorker,
      _ExportPayloadParams(
        payload: payload,
        passphrase: passphrase,
      ),
    );
  }

  Future<void> importData(String encryptedData, String passphrase) async {
    final validatedData = await compute(
      _importValidationWorker,
      _ImportValidationParams(
        encryptedData: encryptedData,
        passphrase: passphrase,
      ),
    );

    // Atomic database replacement:
    // Only executed after 100% of the payload passes strict schema and completeness checks in the background isolate.
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
      for (final cat in validatedData.categories) {
        await _db.into(_db.categoriesTable).insert(cat);
      }

      for (final merch in validatedData.merchants) {
        await _db.into(_db.merchantsTable).insert(merch);
      }

      for (final b in validatedData.budgets) {
        await _db.into(_db.budgetsTable).insert(b);
      }

      for (final r in validatedData.recurring) {
        await _db.into(_db.recurringTransactionsTable).insert(r);
      }

      for (final goal in validatedData.savingsGoals) {
        await _db.into(_db.savingsGoalsTable).insert(goal);
      }

      for (final tx in validatedData.transactions) {
        await _db.into(_db.transactionsTable).insert(tx);
      }

      for (final setting in validatedData.settings) {
        await _db.into(_db.appSettingsTable).insert(setting);
      }
    });
  }
}

class _ExportPayloadParams {
  final Map<String, dynamic> payload;
  final String passphrase;

  const _ExportPayloadParams({
    required this.payload,
    required this.passphrase,
  });
}

String _exportPayloadWorker(_ExportPayloadParams params) {
  final jsonString = jsonEncode(params.payload);
  return EncryptionService.encryptWithPassphrase(jsonString, params.passphrase);
}

class _ImportValidationParams {
  final String encryptedData;
  final String passphrase;

  const _ImportValidationParams({
    required this.encryptedData,
    required this.passphrase,
  });
}

class _ValidatedImportData {
  final List<Category> categories;
  final List<Merchant> merchants;
  final List<Budget> budgets;
  final List<RecurringTransactionData> recurring;
  final List<SavingsGoal> savingsGoals;
  final List<Transaction> transactions;
  final List<AppSetting> settings;

  const _ValidatedImportData({
    required this.categories,
    required this.merchants,
    required this.budgets,
    required this.recurring,
    required this.savingsGoals,
    required this.transactions,
    required this.settings,
  });
}

_ValidatedImportData _importValidationWorker(_ImportValidationParams params) {
  String jsonString;
  try {
    jsonString = EncryptionService.decryptWithPassphrase(params.encryptedData, params.passphrase);
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

  return _ValidatedImportData(
    categories: categories,
    merchants: merchants,
    budgets: budgets,
    recurring: recurring,
    savingsGoals: savingsGoals,
    transactions: transactions,
    settings: settings,
  );
}

