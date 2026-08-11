import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import 'app_database.dart';

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
    final file = File(p.join(dbFolder.path, 'ybm_data.sqlite'));
    _db = AppDatabase(NativeDatabase.createInBackground(file));
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
            amount: tx.amountPaise / 100.0,
            type: tx.type,
            categoryId: tx.categoryId,
            date: dateMillis,
            note: Value(tx.notes),
            merchantName: Value(tx.title),
            isRecurring: Value(tx.isRecurring),
            recurringId: Value(tx.recurringId),
            isAutoCaptured: Value(tx.isAutoCaptured),
            sourceApp: Value(tx.sourceApp),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
          mode: InsertMode.insertOrReplace,
        );
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

  /// Returns true if a transaction with same amount, same calendar day, and
  /// note/merchantName containing [snippet] already exists.
  Future<bool> checkDuplicateTransaction({
    required double amountValue,
    required DateTime date,
    required String snippet,
  }) async {
    final dbInstance = await db;
    // Same day range in millis
    final dayStart = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final likeSnippet = '%${snippet.isNotEmpty ? snippet.substring(0, snippet.length.clamp(0, 20)) : ''}%';

    final rows = await dbInstance.customSelect(
      'SELECT id FROM transactions WHERE amount = ? AND date >= ? AND date <= ? AND (note LIKE ? OR merchant_name LIKE ?) LIMIT 1',
      variables: [
        Variable.withReal(amountValue),
        Variable.withInt(dayStart),
        Variable.withInt(dayEnd),
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
