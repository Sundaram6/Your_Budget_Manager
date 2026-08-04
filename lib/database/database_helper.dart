import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import 'app_database.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static AppDatabase? _db;

  DatabaseHelper._init();

  Future<AppDatabase> get db async {
    if (_db != null) return _db!;
    _db = await _initDB('ybm_data.sqlite');
    return _db!;
  }

  Future<AppDatabase> _initDB(String filePath) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, filePath));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  void setDatabase(AppDatabase database) {
    _db = database;
  }

  Future<List<RecurringTransactionModel>> getDueRecurringTransactions(String todayStr) async {
    final dbInstance = await db;
    final rows = await dbInstance.customSelect(
      'SELECT * FROM recurring_transactions WHERE is_active = 1 AND next_due_date <= ? ORDER BY next_due_date ASC',
      variables: [Variable.withString(todayStr)],
    ).get();

    return rows.map((r) {
      final data = Map<String, dynamic>.from(r.data);
      // Ensure boolean values are converted from int if stored as 0/1 in SQLite
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
    return 1;
  }
}
