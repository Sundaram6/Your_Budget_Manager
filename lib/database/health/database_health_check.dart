import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

import '../../engines/budget/budget_engine.dart';
import '../../engines/category/category_engine.dart';
import '../../engines/savings/savings_engine.dart';
import '../app_database.dart';

class DatabaseHealthCheck {
  final AppDatabase _db;
  final BudgetEngine? _budgetEngine;
  final SavingsEngine? _savingsEngine;
  final Logger _logger;

  DatabaseHealthCheck(
    this._db, {
    BudgetEngine? budgetEngine,
    SavingsEngine? savingsEngine,
    Logger? logger,
  })  : _budgetEngine = budgetEngine,
        _savingsEngine = savingsEngine,
        _logger = logger ?? Logger();

  /// Runs on EVERY app cold start before any transaction read or write.
  /// Guarantees that all 8 required fixed default categories exist, rolls forward monthly budget,
  /// and executes monthly auto-deductions for savings goals.
  Future<void> run() async {
    _logger.i('DatabaseHealthCheck: Running startup category health check...');

    final requiredDefaults = [
      (CategoryEngine.catGroceries, 'Groceries', 'shopping_cart', '4279286145'),
      (CategoryEngine.catShopping, 'Online Shopping', 'shopping_bag', '4287325686'),
      (CategoryEngine.catFood, 'Food Delivery', 'restaurant', '4294303243'),
      (CategoryEngine.catTransport, 'Transport', 'directions_car', '4282086134'),
      (CategoryEngine.catUtilities, 'Utilities', 'bolt', '4284704500'),
      (CategoryEngine.catEntertainment, 'Entertainment', 'movie', '4293675161'),
      (CategoryEngine.catIncome, 'Income', 'attach_money', '4279286145'),
      (CategoryEngine.catUncategorized, 'Uncategorized', 'help_outline', '4288453551'),
    ];

    await _db.transaction(() async {
      final existing = await _db.select(_db.categoriesTable).get();
      final existingIds = existing.map((c) => c.id).toSet();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final def in requiredDefaults) {
        final id = def.$1;
        final name = def.$2;
        final icon = def.$3;
        final color = def.$4;

        if (!existingIds.contains(id)) {
          _logger.w('Health check: created missing category $id ($name)');
          await _db.into(_db.categoriesTable).insert(
            CategoriesTableCompanion.insert(
              id: id,
              name: name,
              icon: icon,
              color: color,
              isDefault: const Value(true),
              sortOrder: const Value(0),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });

    if (_budgetEngine != null) {
      await _budgetEngine.handleMonthRollover();
      final now = DateTime.now();
      final budget = await _budgetEngine.getOverallBudget(now.month, now.year);
      if (_savingsEngine != null && budget != null) {
        await _savingsEngine.executeAutoDeductions(budget.id);
      }
    }

    _logger.i('DatabaseHealthCheck: Category health check, month rollover & auto-deductions completed successfully.');
  }
}
