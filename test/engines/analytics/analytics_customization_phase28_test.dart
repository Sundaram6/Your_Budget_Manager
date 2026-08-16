import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/analytics/providers/analytics_customization_provider.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart' as domain_tx;
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl txRepo;
  late CategoryRepositoryImpl catRepo;
  late AnalyticsEngine analyticsEngine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseHealthCheck(db).run();
    DatabaseHelper.instance.setDatabase(db);

    txRepo = TransactionRepositoryImpl(db.transactionDao);
    catRepo = CategoryRepositoryImpl(db.categoryDao);
    analyticsEngine = AnalyticsEngine(txRepo, catRepo);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> addExpense(int amountPaise, DateTime date, String categoryId) async {
    await txRepo.insertTransaction(domain_tx.Transaction(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}_$categoryId',
      amount: Amount(amountPaise),
      date: date,
      categoryId: categoryId,
      type: TransactionType.expense,
    ));
  }

  group('Phase 28: Category Breakdown Dynamic Filtering & Percentage Recalculation', () {
    test('Breakdown with all categories visible sums to 100%', () async {
      final now = DateTime(2026, 8, 15);
      // Food: ₹5,000, Shopping: ₹3,000, Transport: ₹2,000 (Total ₹10,000)
      await addExpense(500000, now, 'cat_food');
      await addExpense(300000, now, 'cat_shopping');
      await addExpense(200000, now, 'cat_transport');

      final breakdown = await analyticsEngine.getCategoryBreakdown(now.year, now.month);
      expect(breakdown.length, equals(3));

      final totalPercentage = breakdown.fold<double>(0, (sum, b) => sum + b.percentage);
      expect(totalPercentage, closeTo(100.0, 0.01));

      expect(breakdown.firstWhere((b) => b.categoryId == 'cat_food').percentage, closeTo(50.0, 0.01));
      expect(breakdown.firstWhere((b) => b.categoryId == 'cat_shopping').percentage, closeTo(30.0, 0.01));
      expect(breakdown.firstWhere((b) => b.categoryId == 'cat_transport').percentage, closeTo(20.0, 0.01));
    });

    test('Hiding Food (50%) recalculates Shopping & Transport to sum to 100%', () async {
      final now = DateTime(2026, 8, 15);
      await addExpense(500000, now, 'cat_food');
      await addExpense(300000, now, 'cat_shopping');
      await addExpense(200000, now, 'cat_transport');

      // Hide Food
      final breakdown = await analyticsEngine.getCategoryBreakdown(
        now.year,
        now.month,
        hiddenCategoryIds: {'cat_food'},
      );

      expect(breakdown.length, equals(2));
      expect(breakdown.any((b) => b.categoryId == 'cat_food'), isFalse);

      final totalPercentage = breakdown.fold<double>(0, (sum, b) => sum + b.percentage);
      expect(totalPercentage, closeTo(100.0, 0.01));

      // Shopping: 3000 / 5000 = 60%, Transport: 2000 / 5000 = 40%
      expect(breakdown.firstWhere((b) => b.categoryId == 'cat_shopping').percentage, closeTo(60.0, 0.01));
      expect(breakdown.firstWhere((b) => b.categoryId == 'cat_transport').percentage, closeTo(40.0, 0.01));
    });

    test('Hiding all categories returns empty list safely without division by zero', () async {
      final now = DateTime(2026, 8, 15);
      await addExpense(500000, now, 'cat_food');
      await addExpense(300000, now, 'cat_shopping');

      final breakdown = await analyticsEngine.getCategoryBreakdown(
        now.year,
        now.month,
        hiddenCategoryIds: {'cat_food', 'cat_shopping', 'cat_transport'},
      );

      expect(breakdown, isEmpty);
    });

    test('Zero transactions in period returns empty list', () async {
      final now = DateTime(2026, 8, 15);
      final breakdown = await analyticsEngine.getCategoryBreakdown(now.year, now.month);
      expect(breakdown, isEmpty);
    });
  });

  group('Phase 28: AnalyticsHiddenCategoriesNotifier & Persistence Tests', () {
    test('Toggle category adds and removes from hidden set', () async {
      final container = ProviderContainer();
      final notifier = container.read(analyticsHiddenCategoriesProvider.notifier);
      expect(container.read(analyticsHiddenCategoriesProvider), isEmpty);

      await notifier.toggleCategory('cat_food');
      expect(container.read(analyticsHiddenCategoriesProvider), contains('cat_food'));
      expect(notifier.isHidden('cat_food'), isTrue);

      await notifier.toggleCategory('cat_shopping');
      expect(container.read(analyticsHiddenCategoriesProvider), contains('cat_food'));
      expect(container.read(analyticsHiddenCategoriesProvider), contains('cat_shopping'));

      await notifier.toggleCategory('cat_food');
      expect(container.read(analyticsHiddenCategoriesProvider).contains('cat_food'), isFalse);
      expect(container.read(analyticsHiddenCategoriesProvider), contains('cat_shopping'));
      container.dispose();
    });

    test('SharedPreferences persistence survives fresh container instantiation', () async {
      final container1 = ProviderContainer();
      final notifier1 = container1.read(analyticsHiddenCategoriesProvider.notifier);
      await notifier1.hideCategory('cat_groceries');
      await notifier1.hideCategory('cat_entertainment');
      container1.dispose();

      // Create second container to simulate app restart
      final container2 = ProviderContainer();
      container2.read(analyticsHiddenCategoriesProvider);
      // Allow microtask / async load from prefs to settle
      await Future.delayed(const Duration(milliseconds: 50));

      expect(container2.read(analyticsHiddenCategoriesProvider), contains('cat_groceries'));
      expect(container2.read(analyticsHiddenCategoriesProvider), contains('cat_entertainment'));
      container2.dispose();
    });

    test('Reset clears all hidden categories', () async {
      final container = ProviderContainer();
      final notifier = container.read(analyticsHiddenCategoriesProvider.notifier);
      await notifier.setHiddenCategories({'cat_food', 'cat_shopping'});
      expect(container.read(analyticsHiddenCategoriesProvider).length, equals(2));

      await notifier.reset();
      expect(container.read(analyticsHiddenCategoriesProvider), isEmpty);
      container.dispose();
    });
  });
}
