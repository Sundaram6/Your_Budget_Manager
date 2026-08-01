import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';

void main() {
  late AppDatabase database;
  late TransactionDao transactionDao;
  late CategoryDao categoryDao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    transactionDao = database.transactionDao;
    categoryDao = database.categoryDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and retrieve transactions', () async {
    // Insert category first to satisfy foreign key
    await categoryDao.insertCategory(
      CategoriesTableCompanion.insert(
        id: 'cat1',
        name: 'Food',
        icon: 'fastfood',
        color: 'red',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    await transactionDao.insertTransaction(
      TransactionsTableCompanion.insert(
        id: 'txn1',
        amount: 100.0,
        type: 'expense',
        categoryId: 'cat1',
        date: 2000,
        createdAt: 2000,
        updatedAt: 2000,
      ),
    );

    final transactions = await transactionDao.watchAllTransactions().first;
    expect(transactions.length, 1);
    expect(transactions.first.id, 'txn1');
    expect(transactions.first.amount, 100.0);
  });
}
