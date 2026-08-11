import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3_lib;
import 'package:your_budget_manager/database/app_database.dart';

/// Migration regression tests for AppDatabase.
///
/// Schema history (established from git log):
///   v1 – initial release; recurring_transactions uses:
///         name TEXT, amount REAL (rupees), unix-ms integers for all dates,
///         lastProcessedDate column, note column.
///   v2 – savings_goals table added; recurring_transactions unchanged.
///   [v3 was never shipped; DB version jumped 2 → 4]
///   v4 – recurring_transactions completely redesigned:
///         title TEXT, amountPaise INTEGER, text-dates (yyyy-MM-dd / ISO8601),
///         lastGeneratedDate, notes, intervalDays, autoConfirm columns.
///
/// Each test group primes an on-disk SQLite file with the old schema + data,
/// then opens it through AppDatabase (schemaVersion=4) and asserts that every
/// record survives the migration with correct transformed values.
void main() {
  // ---------------------------------------------------------------------------
  // v1 → v4
  // ---------------------------------------------------------------------------
  group('Database migration – v1 to v4', () {
    late AppDatabase db;
    late String dbPath;

    setUp(() {
      dbPath = _createTempFilePath();
      final raw = sqlite3_lib.sqlite3.open(dbPath);
      _buildV1Schema(raw);
      _seedV1Data(raw);
      raw.dispose();

      db = AppDatabase(NativeDatabase(File(dbPath)));
    });

    tearDown(() async {
      await db.close();
      try { File(dbPath).deleteSync(); } catch (_) {}
    });

    test('recurring_transactions rows survive with correct field values', () async {
      final rows = await db.recurringTransactionDao.getActive();

      expect(rows.length, 2, reason: 'Both seeded recurring records must survive');

      // --- Rent record ---
      final rent = rows.firstWhere((r) => r.id == 'rec_rent');
      expect(rent.title, 'Rent',
          reason: 'name column must be mapped to title');
      // 15000.0 rupees * 100 = 1500000 paise
      expect(rent.amountPaise, 1500000,
          reason: 'REAL rupees must be converted to INTEGER paise');
      expect(rent.type, 'expense');
      expect(rent.categoryId, 'cat_food');
      expect(rent.frequency, 'monthly');
      expect(rent.intervalDays, equals(null),
          reason: 'intervalDays is new; no v1 source — must be null');
      // startDate unix ms 1704067200000 → '2024-01-01'
      expect(rent.startDate, '2024-01-01',
          reason: 'unix ms must convert to yyyy-MM-dd');
      expect(rent.endDate, equals(null),
          reason: 'null end_date must remain null');
      // nextDueDate 1753920000000 → '2026-08-01' (2026-07-31 UTC midnight)
      // SQLite date(1753920000000/1000,'unixepoch') = date(1753920000,'unixepoch')
      expect(rent.nextDueDate, isNotEmpty);
      expect(rent.lastGeneratedDate, equals(null),
          reason: 'null lastProcessedDate → null lastGeneratedDate');
      expect(rent.isActive, equals(true));
      expect(rent.autoConfirm, equals(false),
          reason: 'autoConfirm must default to false for all migrated rows');
      expect(rent.notes, 'Monthly rent payment',
          reason: 'note must map to notes');
      // createdAt must be a non-empty ISO8601 string starting with '2024-'
      expect(rent.createdAt, startsWith('2024-'));

      // --- Salary record ---
      final salary = rows.firstWhere((r) => r.id == 'rec_salary');
      expect(salary.title, 'Salary');
      expect(salary.amountPaise, 8000000); // 80000 * 100
      expect(salary.type, 'income');
      expect(salary.notes, equals(null), reason: 'null note must remain null');
    });

    test('transactions survive with new columns defaulted correctly', () async {
      final txns = await db.transactionDao.watchAllTransactions().first;
      expect(txns.length, 3, reason: 'All seeded transactions must survive');

      final grocery = txns.firstWhere((t) => t.id == 'txn_grocery');
      expect(grocery.amount, 250.0);
      expect(grocery.categoryId, 'cat_food');
      expect(grocery.type, 'expense');
      // New v4 columns must have their schema-defined defaults:
      expect(grocery.isRecurring, equals(false));
      expect(grocery.isAutoCaptured, equals(false));
      expect(grocery.sourceApp, equals(null));
    });

    test('categories survive unchanged', () async {
      final cats = await db.categoryDao.watchAllCategories().first;
      expect(cats.length, 2);
      expect(cats.map((c) => c.id).toSet(), {'cat_food', 'cat_transport'});
    });

    test('budgets survive unchanged', () async {
      final budgets = await db.budgetDao.watchAllBudgets().first;
      expect(budgets.length, 1);
      expect(budgets.first.id, 'budget_aug');
      expect(budgets.first.amount, 200000);
    });
  });

  // ---------------------------------------------------------------------------
  // v2 → v4
  // ---------------------------------------------------------------------------
  group('Database migration – v2 to v4', () {
    late AppDatabase db;
    late String dbPath;

    setUp(() {
      dbPath = _createTempFilePath();
      final raw = sqlite3_lib.sqlite3.open(dbPath);
      _buildV2Schema(raw);
      _seedV2Data(raw);
      raw.dispose();

      db = AppDatabase(NativeDatabase(File(dbPath)));
    });

    tearDown(() async {
      await db.close();
      try { File(dbPath).deleteSync(); } catch (_) {}
    });

    test('recurring records survive v2 to v4', () async {
      final rows = await db.recurringTransactionDao.getActive();
      expect(rows.length, 1);
      expect(rows.first.id, 'rec_netflix');
      expect(rows.first.title, 'Netflix');
      expect(rows.first.amountPaise, 64900, // 649.0 * 100
          reason: '649.0 rupees must become 64900 paise');
      expect(rows.first.frequency, 'monthly');
      expect(rows.first.startDate, '2025-01-15',
          reason: 'unix ms must convert to yyyy-MM-dd');
    });

    test('savings_goals survive v2 to v4', () async {
      final goals = await db.savingsGoalDao.watchAll().first;
      expect(goals.length, 1);
      expect(goals.first.id, 'goal_emergency');
      expect(goals.first.name, 'Emergency Fund');
    });
  });

  // ---------------------------------------------------------------------------
  // Fresh install
  // ---------------------------------------------------------------------------
  group('Fresh install – onCreate path', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async => db.close());

    test('all tables exist and are empty after fresh install', () async {
      expect(await db.categoryDao.watchAllCategories().first, hasLength(0));
      expect(await db.recurringTransactionDao.getActive(), hasLength(0));
      expect(await db.transactionDao.watchAllTransactions().first, hasLength(0));
      expect(await db.budgetDao.watchAllBudgets().first, hasLength(0));
      expect(await db.savingsGoalDao.watchAll().first, hasLength(0));
    });
  });
}

// =============================================================================
// Helpers – schema builders and data seeders
// =============================================================================

String _createTempFilePath() {
  final dir = Directory.systemTemp;
  final name =
      'ybm_migtest_${DateTime.now().microsecondsSinceEpoch}.db';
  return '${dir.path}${Platform.pathSeparator}$name';
}

/// Creates the v1 production schema in [db] and sets user_version=1.
void _buildV1Schema(sqlite3_lib.Database db) {
  db.execute('PRAGMA user_version = 1');
  db.execute('''
    CREATE TABLE categories (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE merchants (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      default_category_id TEXT REFERENCES categories(id),
      match_pattern TEXT,
      icon TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  // Old v1/v2 recurring schema (name, amount REAL, unix-ms integers)
  db.execute('''
    CREATE TABLE recurring_transactions (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category_id TEXT NOT NULL REFERENCES categories(id),
      frequency TEXT NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER,
      next_due_date INTEGER NOT NULL,
      last_processed_date INTEGER,
      is_active INTEGER NOT NULL DEFAULT 1,
      note TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE transactions (
      id TEXT NOT NULL PRIMARY KEY,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category_id TEXT NOT NULL REFERENCES categories(id),
      date INTEGER NOT NULL,
      note TEXT,
      merchant_name TEXT,
      merchant_id TEXT REFERENCES merchants(id),
      recurring_id TEXT REFERENCES recurring_transactions(id),
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE budgets (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL DEFAULT "Monthly Budget",
      category_id TEXT,
      amount INTEGER NOT NULL,
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      type TEXT NOT NULL DEFAULT "monthly"
    )
  ''');
  db.execute('''
    CREATE TABLE app_settings (
      key TEXT NOT NULL PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
}

/// Seeds representative v1 user data.
void _seedV1Data(sqlite3_lib.Database db) {
  db.execute(
    "INSERT INTO categories VALUES ('cat_food','Food','restaurant','#FF5722',1,1,1704067200000,1704067200000),"
    "('cat_transport','Transport','directions_car','#2196F3',1,2,1704067200000,1704067200000)",
  );

  // 2024-01-01 00:00:00 UTC = 1704067200000 ms
  // 2026-08-01 00:00:00 UTC = 1753920000000 ms
  db.execute(
    "INSERT INTO recurring_transactions VALUES "
    "('rec_rent','Rent',15000.0,'expense','cat_food','monthly',"
    " 1704067200000,NULL,1753920000000,NULL,1,'Monthly rent payment',"
    " 1704067200000,1704067200000),"
    "('rec_salary','Salary',80000.0,'income','cat_food','monthly',"
    " 1704067200000,NULL,1753920000000,NULL,1,NULL,"
    " 1704067200000,1704067200000)",
  );

  db.execute(
    "INSERT INTO transactions VALUES "
    "('txn_grocery',250.0,'expense','cat_food',1704067200000,'Grocery run','BigBazaar',NULL,NULL,1704067200000,1704067200000),"
    "('txn_bus',50.0,'expense','cat_transport',1704153600000,NULL,NULL,NULL,NULL,1704153600000,1704153600000),"
    "('txn_salary',80000.0,'income','cat_food',1704067200000,'January salary',NULL,NULL,'rec_salary',1704067200000,1704067200000)",
  );

  db.execute(
    "INSERT INTO budgets VALUES ('budget_aug','Monthly Budget','cat_food',200000,8,2026,1704067200000,'monthly')",
  );
}

/// Creates the v2 schema (v1 + savings_goals), sets user_version=2.
void _buildV2Schema(sqlite3_lib.Database db) {
  _buildV1Schema(db);
  db.execute('PRAGMA user_version = 2');
  db.execute('''
    CREATE TABLE savings_goals (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      target_amount INTEGER NOT NULL,
      current_amount INTEGER NOT NULL DEFAULT 0,
      deadline INTEGER,
      budget_id TEXT REFERENCES budgets(id),
      auto_deduct INTEGER NOT NULL DEFAULT 0,
      auto_deduct_amount INTEGER,
      last_auto_deducted_month TEXT,
      category_id TEXT REFERENCES categories(id),
      target_date INTEGER,
      start_date INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT "active",
      icon_name TEXT NOT NULL DEFAULT "savings",
      color_hex TEXT NOT NULL DEFAULT "#FFD700",
      note TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
}

/// Seeds v2 data: one recurring + one savings goal.
void _seedV2Data(sqlite3_lib.Database db) {
  db.execute(
    "INSERT INTO categories VALUES ('cat_food','Food','restaurant','#FF5722',1,1,1704067200000,1704067200000)",
  );

  // 2025-01-15 00:00:00 UTC ≈ 1736899200000 ms
  db.execute(
    "INSERT INTO recurring_transactions VALUES "
    "('rec_netflix','Netflix',649.0,'expense','cat_food','monthly',"
    " 1736899200000,NULL,1753920000000,NULL,1,NULL,"
    " 1736899200000,1736899200000)",
  );

  db.execute(
    "INSERT INTO savings_goals VALUES "
    "('goal_emergency','Emergency Fund',500000,50000,NULL,NULL,"
    " 0,NULL,NULL,NULL,NULL,1704067200000,'active','savings','#FFD700',"
    " NULL,1704067200000,1704067200000)",
  );
}
