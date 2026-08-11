import 'package:drift/drift.dart';

import 'daos/budget_dao.dart';
import 'daos/category_dao.dart';
import 'daos/merchant_dao.dart';
import 'daos/recurring_transaction_dao.dart';
import 'daos/savings_goal_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/budgets_table.dart';
import 'tables/categories_table.dart';
import 'tables/merchants_table.dart';
import 'tables/recurring_transactions_table.dart';
import 'tables/savings_goals_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CategoriesTable,
    MerchantsTable,
    TransactionsTable,
    BudgetsTable,
    RecurringTransactionsTable,
    AppSettingsTable,
    SavingsGoalsTable,
  ],
  daos: [
    CategoryDao,
    MerchantDao,
    TransactionDao,
    BudgetDao,
    RecurringTransactionDao,
    SettingsDao,
    SavingsGoalDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // v1 → v2: savings_goals table added.
        if (from < 2) {
          await m.createTable(savingsGoalsTable);
        }

        // v2 → v4 (v3 was never shipped; version jumped 2 → 4):
        // recurring_transactions schema was completely redesigned.
        //
        // Old schema (v1/v2):
        //   id TEXT PK, name TEXT, amount REAL (rupees),
        //   type TEXT, categoryId TEXT (→ category_id), frequency TEXT,
        //   startDate INTEGER (unix ms), endDate INTEGER nullable (unix ms),
        //   nextDueDate INTEGER (unix ms),
        //   lastProcessedDate INTEGER nullable (unix ms),
        //   isActive BOOLEAN, note TEXT nullable,
        //   createdAt INTEGER (unix ms), updatedAt INTEGER (unix ms)
        //
        // New schema (v4):
        //   id TEXT PK, title TEXT, amountPaise INTEGER (rupees × 100),
        //   categoryId TEXT, type TEXT, frequency TEXT,
        //   intervalDays INTEGER nullable,
        //   startDate TEXT ('yyyy-MM-dd'), endDate TEXT nullable,
        //   nextDueDate TEXT ('yyyy-MM-dd'),
        //   lastGeneratedDate TEXT nullable ('yyyy-MM-dd'),
        //   isActive BOOLEAN, autoConfirm BOOLEAN,
        //   notes TEXT nullable,
        //   createdAt TEXT (ISO8601), updatedAt TEXT (ISO8601)
        //
        // Safe migration: create staging table → copy+transform → validate
        // row counts → drop old → rename staging. No data is lost.
        if (from < 4) {
          final hasOldTable = await _tableExists('recurring_transactions');

          if (hasOldTable) {
            final oldCount = await _rowCount('recurring_transactions');

            // 1. Create staging table matching the new v4 schema exactly.
            await customStatement('''
              CREATE TABLE IF NOT EXISTS recurring_transactions_v4 (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                amount_paise INTEGER NOT NULL,
                category_id TEXT NOT NULL REFERENCES categories(id),
                type TEXT NOT NULL,
                frequency TEXT NOT NULL,
                interval_days INTEGER,
                start_date TEXT NOT NULL,
                end_date TEXT,
                next_due_date TEXT NOT NULL,
                last_generated_date TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                auto_confirm INTEGER NOT NULL DEFAULT 0,
                notes TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');

            // 2. Copy and transform all existing rows.
            //    Column mappings:
            //      name                  → title           (identity)
            //      amount × 100          → amount_paise    (REAL rupees → INTEGER paise)
            //      category_id                             (identity)
            //      type, frequency                         (identity)
            //      NULL                  → interval_days   (new field; no source data)
            //      date(startDate/1000)  → start_date      (unix ms → yyyy-MM-dd)
            //      date(endDate/1000)    → end_date        (unix ms nullable)
            //      date(nextDueDate/1000)→ next_due_date   (unix ms → yyyy-MM-dd)
            //      date(lastProcessedDate/1000) → last_generated_date (unix ms nullable)
            //      isActive              → is_active       (identity)
            //      0                    → auto_confirm     (new field; safe default)
            //      note                  → notes           (identity)
            //      datetime(createdAt/1000) → created_at  (unix ms → ISO8601)
            //      datetime(updatedAt/1000) → updated_at  (unix ms → ISO8601)
            await customStatement('''
              INSERT OR IGNORE INTO recurring_transactions_v4 (
                id, title, amount_paise, category_id, type, frequency,
                interval_days, start_date, end_date, next_due_date,
                last_generated_date, is_active, auto_confirm, notes,
                created_at, updated_at
              )
              SELECT
                id,
                name,
                CAST(ROUND(amount * 100) AS INTEGER),
                category_id,
                type,
                frequency,
                NULL,
                date(start_date / 1000, 'unixepoch'),
                CASE WHEN end_date IS NULL THEN NULL
                     ELSE date(end_date / 1000, 'unixepoch') END,
                date(next_due_date / 1000, 'unixepoch'),
                CASE WHEN last_processed_date IS NULL THEN NULL
                     ELSE date(last_processed_date / 1000, 'unixepoch') END,
                is_active,
                0,
                note,
                datetime(created_at / 1000, 'unixepoch'),
                datetime(updated_at / 1000, 'unixepoch')
              FROM recurring_transactions
            ''');

            // 3. Validate: row counts must match before we destroy old table.
            final newCount = await _rowCount('recurring_transactions_v4');
            if (newCount != oldCount) {
              // Hard failure — do not drop the old table; preserve user data.
              await customStatement('DROP TABLE IF EXISTS recurring_transactions_v4;');
              throw StateError(
                'Migration v4: recurring_transactions row count mismatch. '
                'Expected $oldCount, migrated $newCount. '
                'Old table preserved; aborting to prevent data loss.',
              );
            }

            // 4. Drop old table (foreign_keys is OFF during migrations; re-enabled
            //    in beforeOpen, so references from transactions.recurring_id are
            //    not enforced here and won't block the drop).
            await customStatement('DROP TABLE recurring_transactions;');

            // 5. Promote staging table to canonical name.
            await customStatement(
              'ALTER TABLE recurring_transactions_v4 RENAME TO recurring_transactions;',
            );
          } else {
            // Old table absent (fresh install that somehow reached v4 upgrade path).
            // Create via Drift's migrator so generated code stays in sync.
            await m.createTable(recurringTransactionsTable);
          }

          // Add new columns to transactions table. Each is wrapped in try/catch
          // because a partially-completed prior migration may have already added
          // some of them, and "duplicate column" is not recoverable otherwise.
          try {
            await m.addColumn(transactionsTable, transactionsTable.isRecurring);
          } catch (_) {}
          try {
            await m.addColumn(transactionsTable, transactionsTable.isAutoCaptured);
          } catch (_) {}
          try {
            await m.addColumn(transactionsTable, transactionsTable.sourceApp);
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Returns true if a table named [tableName] exists in this database.
  Future<bool> _tableExists(String tableName) async {
    final rows = await customSelect(
      "SELECT COUNT(*) AS c FROM sqlite_master WHERE type='table' AND name=?",
      variables: [Variable.withString(tableName)],
    ).get();
    return rows.first.read<int>('c') > 0;
  }

  /// Returns the number of rows in [tableName].
  Future<int> _rowCount(String tableName) async {
    final rows = await customSelect(
      'SELECT COUNT(*) AS c FROM "$tableName"',
    ).get();
    return rows.first.read<int>('c');
  }
}
