import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/budget_dao.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';

void main() {
  late AppDatabase database;
  late BudgetDao budgetDao;
  late CategoryDao categoryDao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    budgetDao = database.budgetDao;
    categoryDao = database.categoryDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('insert and retrieve budgets', () async {
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

    await budgetDao.insertBudget(
      BudgetsTableCompanion.insert(
        id: 'budget1',
        categoryId: const Value('cat1'),
        amount: 50000, // ₹500 in paise
        month: 8,
        year: 2026,
        createdAt: 1000,
      ),
    );

    final budgets = await budgetDao.watchAllBudgets().first;
    expect(budgets.length, 1);
    expect(budgets.first.id, 'budget1');
    expect(budgets.first.amount, 50000);
    expect(budgets.first.month, 8);
    expect(budgets.first.year, 2026);
  });
}
