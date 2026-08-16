import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../core/security/database_key_service.dart';
import 'app_database.dart';
import 'encryption_migration.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static AppDatabase? _db;

  DatabaseHelper._init();

  /// Returns the canonical [AppDatabase] instance.
  ///
  /// In the main UI isolate, the database instance MUST be supplied by
  /// `appDatabaseProvider` via [setDatabase]. If accessed before initialization,
  /// this throws a [StateError] to prevent accidental secondary connection creation.
  Future<AppDatabase> get db async {
    if (_db != null) return _db!;
    throw StateError(
      'DatabaseHelper accessed before appDatabaseProvider initialized. '
      'All database operations in the main isolate must use the single canonical '
      'AppDatabase provided by appDatabaseProvider.',
    );
  }

  /// Explicitly initializes an independent database connection for background isolates
  /// (e.g. WorkManager `callbackDispatcher`) where no Riverpod `ProviderContainer` exists.
  ///
  /// This should ONLY be called from background isolate entry points.
  static Future<void> initForBackgroundIsolate() async {
    if (_db != null) return;
    final dbFolder = await getApplicationDocumentsDirectory();
    final plainFile = File(p.join(dbFolder.path, 'ybm_data.sqlite'));
    final cryptFile = File(p.join(dbFolder.path, 'ybm_data_enc.sqlite'));

    final keyService = DatabaseKeyService();
    final key = await keyService.getOrCreateDbKey();

    await EncryptionMigration.encryptExistingDatabaseIfNeeded(
      plaintextFile: plainFile,
      encryptedFile: cryptFile,
      key: key,
    );

    final escapedKey = EncryptionMigration.escapeSqlString(key);

    _db = AppDatabase(
      NativeDatabase.createInBackground(
        cryptFile,
        setup: (rawDb) {
          EncryptionMigration.verifyCipherSupport(
            rawDb,
            context: 'background isolate DatabaseHelper',
          );
          rawDb.execute("PRAGMA key = '$escapedKey';");
        },
      ),
    );
  }

  /// Sets the canonical database instance provided by `appDatabaseProvider`.
  void setDatabase(AppDatabase database) {
    _db = database;
  }

  /// Resets the cached database handle. Intended for testing only.
  @visibleForTesting
  static void resetForTesting() {
    _db = null;
  }

  Stream<List<RecurringTransactionModel>> watchAllRecurringTransactions() async* {
    final dbInstance = await db;
    yield* dbInstance.customSelect(
      'SELECT * FROM recurring_transactions ORDER BY next_due_date ASC',
      readsFrom: {dbInstance.recurringTransactionsTable},
    ).watch().map((rows) {
      return rows.map((r) {
        final data = Map<String, dynamic>.from(r.data);
        if (data['is_active'] is int) {
          data['is_active'] = (data['is_active'] as int) == 1;
        }
        if (data['auto_confirm'] is int) {
          data['auto_confirm'] = (data['auto_confirm'] as int) == 1;
        }
        return RecurringTransactionModel.fromJson(data);
      }).toList();
    });
  }

  Future<List<RecurringTransactionModel>> getDueRecurringTransactions(String todayStr) async {
    final dbInstance = await db;
    final rows = await dbInstance.customSelect(
      'SELECT * FROM recurring_transactions WHERE is_active = 1 AND next_due_date <= ? ORDER BY next_due_date ASC',
      variables: [Variable.withString(todayStr)],
    ).get();

    return rows.map((r) {
      final data = Map<String, dynamic>.from(r.data);
      if (data['is_active'] is int) {
        data['is_active'] = (data['is_active'] as int) == 1;
      }
      if (data['auto_confirm'] is int) {
        data['auto_confirm'] = (data['auto_confirm'] as int) == 1;
      }
      return RecurringTransactionModel.fromJson(data);
    }).toList();
  }

  Future<RecurringTransactionModel?> getRecurringTransactionById(String id) async {
    final dbInstance = await db;
    final rows = await dbInstance.customSelect(
      'SELECT * FROM recurring_transactions WHERE id = ? LIMIT 1',
      variables: [Variable.withString(id)],
    ).get();

    if (rows.isEmpty) return null;
    final data = Map<String, dynamic>.from(rows.first.data);
    if (data['is_active'] is int) {
      data['is_active'] = (data['is_active'] as int) == 1;
    }
    if (data['auto_confirm'] is int) {
      data['auto_confirm'] = (data['auto_confirm'] as int) == 1;
    }
    return RecurringTransactionModel.fromJson(data);
  }

  Future<void> insertTransaction(TransactionModel tx) async {
    final dbInstance = await db;
    final dateMillis = tx.date.millisecondsSinceEpoch;
    final nowMillis = (tx.createdAt ?? DateTime.now()).millisecondsSinceEpoch;

    await dbInstance.into(dbInstance.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            id: tx.id,
            amount: tx.amountPaise,
            type: tx.type,
            categoryId: tx.categoryId,
            date: dateMillis,
            note: Value(tx.notes),
            merchantName: Value(tx.title),
            isRecurring: Value(tx.isRecurring),
            recurringId: Value(tx.recurringId),
            recurrenceOccurrenceKey: Value(tx.recurrenceOccurrenceKey),
            sourceMessageId: Value(tx.sourceMessageId),
            isAutoCaptured: Value(tx.isAutoCaptured),
            sourceApp: Value(tx.sourceApp),
            paymentMethod: Value(tx.paymentMethod),
            cardLast4: Value(tx.cardLast4),
            accountLast4: Value(tx.accountLast4),
            transactionRef: Value(tx.transactionRef),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Atomically inserts a recurring transaction occurrence and advances the schedule.
  /// Idempotent: if an occurrence with [occurrenceKey] already exists, skips insert but still advances schedule.
  Future<bool> generateRecurringOccurrence({
    required TransactionModel transaction,
    required String occurrenceKey,
    required String recurringId,
    required String nextDueDate,
    String? lastGeneratedDate,
    required String updatedAt,
  }) async {
    final dbInstance = await db;
    return await dbInstance.transaction(() async {
      final existing = await (dbInstance.select(dbInstance.transactionsTable)
            ..where((tbl) => tbl.recurrenceOccurrenceKey.equals(occurrenceKey)))
          .get();

      bool inserted = false;
      if (existing.isEmpty) {
        final dateMillis = transaction.date.millisecondsSinceEpoch;
        final nowMillis = (transaction.createdAt ?? DateTime.now()).millisecondsSinceEpoch;

        await dbInstance.into(dbInstance.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                id: transaction.id,
                amount: transaction.amountPaise,
                type: transaction.type,
                categoryId: transaction.categoryId,
                date: dateMillis,
                note: Value(transaction.notes),
                merchantName: Value(transaction.title),
                isRecurring: const Value(true),
                recurringId: Value(recurringId),
                recurrenceOccurrenceKey: Value(occurrenceKey),
                sourceMessageId: Value(transaction.sourceMessageId),
                isAutoCaptured: Value(transaction.isAutoCaptured),
                sourceApp: Value(transaction.sourceApp),
                paymentMethod: Value(transaction.paymentMethod),
                cardLast4: Value(transaction.cardLast4),
                accountLast4: Value(transaction.accountLast4),
                transactionRef: Value(transaction.transactionRef),
                transferPairId: Value(transaction.transferPairId),
                createdAt: nowMillis,
                updatedAt: nowMillis,
              ),
              mode: InsertMode.insertOrReplace,
            );
        inserted = true;
      }

      await dbInstance.customStatement(
        'UPDATE recurring_transactions SET next_due_date = ?, last_generated_date = ?, updated_at = ? WHERE id = ?',
        [nextDueDate, lastGeneratedDate, updatedAt, recurringId],
      );
      dbInstance.markTablesUpdated({dbInstance.recurringTransactionsTable});

      return inserted;
    });
  }

  Future<void> updateRecurringTransactionDates({
    required String id,
    required String nextDueDate,
    String? lastGeneratedDate,
    required String updatedAt,
  }) async {
    final dbInstance = await db;
    await dbInstance.customStatement(
      'UPDATE recurring_transactions SET next_due_date = ?, last_generated_date = ?, updated_at = ? WHERE id = ?',
      [nextDueDate, lastGeneratedDate, updatedAt, id],
    );
    dbInstance.markTablesUpdated({dbInstance.recurringTransactionsTable});
  }

  Future<int> insertRecurringTransaction(RecurringTransactionModel rt) async {
    final dbInstance = await db;
    final json = rt.toJson();
    await dbInstance.customStatement(
      '''
      INSERT OR REPLACE INTO recurring_transactions (
        id, title, amount_paise, category_id, type, frequency, interval_days,
        start_date, end_date, next_due_date, last_generated_date, is_active,
        auto_confirm, notes, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        json['id'],
        json['title'],
        json['amount_paise'],
        json['category_id'],
        json['type'],
        json['frequency'],
        json['interval_days'],
        json['start_date'],
        json['end_date'],
        json['next_due_date'],
        json['last_generated_date'],
        json['is_active'] == true ? 1 : 0,
        json['auto_confirm'] == true ? 1 : 0,
        json['notes'],
        json['created_at'],
        json['updated_at'],
      ],
    );
    dbInstance.markTablesUpdated({dbInstance.recurringTransactionsTable});
    return 1;
  }

  /// Returns true if a transaction with same durable sourceMessageId exists (primary authoritative check),
  /// OR if a transaction with same amount, matching timestamp window (±2 minutes),
  /// and matching merchant/note already exists (secondary legacy/unhashed safety net).
  Future<bool> checkDuplicateTransaction({
    required int amountValue,
    required DateTime date,
    required String snippet,
    String? sourceMessageId,
  }) async {
    final dbInstance = await db;

    // 1. Primary authoritative check: durable source message identity
    if (sourceMessageId != null && sourceMessageId.trim().isNotEmpty) {
      final rows = await dbInstance.customSelect(
        'SELECT id FROM transactions WHERE source_message_id = ? LIMIT 1',
        variables: [Variable.withString(sourceMessageId.trim())],
      ).get();
      if (rows.isNotEmpty) {
        return true; // Authoritative match -> Early return immediately!
      }
    }

    // 2. Secondary heuristic safety net (for pre-v9 legacy unhashed transactions):
    // Proximate window: within 2 minutes of the transaction timestamp
    final targetMillis = date.millisecondsSinceEpoch;
    final windowStart = targetMillis - 120000;
    final windowEnd = targetMillis + 120000;
    final cleanSnippet = snippet.trim();
    final likeSnippet = '%${cleanSnippet.isNotEmpty ? cleanSnippet.substring(0, cleanSnippet.length.clamp(0, 30)) : ''}%';

    final rows = await dbInstance.customSelect(
      'SELECT id FROM transactions WHERE amount = ? AND date >= ? AND date <= ? AND (note LIKE ? OR merchant_name LIKE ?) LIMIT 1',
      variables: [
        Variable.withInt(amountValue),
        Variable.withInt(windowStart),
        Variable.withInt(windowEnd),
        Variable.withString(likeSnippet),
        Variable.withString(likeSnippet),
      ],
    ).get();

    return rows.isNotEmpty;
  }

  Future<int> deleteRecurringTransaction(String id) async {
    final dbInstance = await db;
    await dbInstance.transaction(() async {
      await dbInstance.customStatement(
        'UPDATE transactions SET recurring_id = NULL WHERE recurring_id = ?',
        [id],
      );
      await dbInstance.customStatement(
        'DELETE FROM recurring_transactions WHERE id = ?',
        [id],
      );
    });
    dbInstance.markTablesUpdated({
      dbInstance.recurringTransactionsTable,
      dbInstance.transactionsTable,
    });
    return 1;
  }
}
