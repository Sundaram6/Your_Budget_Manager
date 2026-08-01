import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/categories_table.dart';
import 'tables/merchants_table.dart';
import 'tables/transactions_table.dart';
import 'tables/budgets_table.dart';
import 'tables/recurring_transactions_table.dart';
import 'tables/app_settings_table.dart';

import 'daos/category_dao.dart';
import 'daos/merchant_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/recurring_transaction_dao.dart';
import 'daos/settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CategoriesTable,
    MerchantsTable,
    TransactionsTable,
    BudgetsTable,
    RecurringTransactionsTable,
    AppSettingsTable,
  ],
  daos: [
    CategoryDao,
    MerchantDao,
    TransactionDao,
    BudgetDao,
    RecurringTransactionDao,
    SettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
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
