import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

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
        if (from < 2) {
          await m.createTable(savingsGoalsTable);
        }
        if (from < 4) {
          await customStatement('DROP TABLE IF EXISTS recurring_transactions;');
          await m.createTable(recurringTransactionsTable);
          await m.addColumn(transactionsTable, transactionsTable.isRecurring);
          await m.addColumn(transactionsTable, transactionsTable.isAutoCaptured);
          await m.addColumn(transactionsTable, transactionsTable.sourceApp);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static AppDatabase openEncrypted(String dbPath, String encryptionKey) {
    final file = File(dbPath);
    return AppDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute('PRAGMA key = "$encryptionKey";');
        },
      ),
    );
  }
}
