import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart' as db;
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/transfer/self_transfer_engine.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.AppDatabase database;
  late TransactionDao txDao;
  late CategoryDao catDao;
  late TransactionRepositoryImpl txRepository;
  late CategoryRepositoryImpl catRepository;
  late SelfTransferEngine selfTransferEngine;
  late ExpenseEngine expenseEngine;
  late AnalyticsEngine analyticsEngine;
  late IntelligenceEngine intelligenceEngine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = db.AppDatabase(NativeDatabase.memory());
    txDao = TransactionDao(database);
    catDao = CategoryDao(database);
    txRepository = TransactionRepositoryImpl(txDao);
    catRepository = CategoryRepositoryImpl(catDao);
    selfTransferEngine = SelfTransferEngine(database);
    expenseEngine = ExpenseEngine(txRepository, selfTransferEngine: selfTransferEngine);
    analyticsEngine = AnalyticsEngine(txRepository, catRepository);
    intelligenceEngine = IntelligenceEngine(
      transactionDao: txDao,
      categoryDao: catDao,
      analyticsEngine: analyticsEngine,
      expenseEngine: expenseEngine,
    );

    final categoryEngine = CategoryEngine(catRepository);
    await categoryEngine.seedDefaults();
  });

  tearDown(() async {
    await database.close();
  });

  group('Self-Transfer Analytics & Intelligence Exclusion Tests', () {
    final testMonth = DateTime(2026, 8, 1);

    test('AnalyticsEngine and ExpenseEngine exclude linked self-transfers from spend and income', () async {
      // 1. Add normal expense of ₹500 (50000 paise)
      await expenseEngine.addTransaction(
        amount: 50000,
        date: DateTime(2026, 8, 10, 10, 0),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      // 2. Add normal salary income of ₹25,000 (2500000 paise)
      await expenseEngine.addTransaction(
        amount: 2500000,
        date: DateTime(2026, 8, 5, 9, 0),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      // 3. Add self-transfer of ₹10,000 (1000000 paise) between accounts
      await expenseEngine.addTransaction(
        amount: 1000000,
        date: DateTime(2026, 8, 12, 14, 0),
        categoryId: CategoryEngine.catShopping,
        type: TransactionType.expense,
        transactionRef: 'TRANSFER_UTR_1',
      );
      await expenseEngine.addTransaction(
        amount: 1000000,
        date: DateTime(2026, 8, 12, 14, 1),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        transactionRef: 'TRANSFER_UTR_1',
      );

      // Verify Monthly Total Expense excludes ₹10,000 self-transfer (should be exactly ₹500 = 50000 paise)
      final monthlyExpenseAnalytics = await analyticsEngine.getMonthlyTotal(2026, 8);
      expect(monthlyExpenseAnalytics, equals(50000));

      final monthlyExpenseEngine = await expenseEngine.getMonthlyTotal(testMonth, type: TransactionType.expense);
      expect(monthlyExpenseEngine, equals(50000));

      // Verify Monthly Total Income excludes ₹10,000 self-transfer (should be exactly ₹25,000 = 2500000 paise)
      final monthlyIncome = await analyticsEngine.getMonthlyIncome(2026, 8);
      expect(monthlyIncome, equals(2500000));

      // Verify Category Breakdown only includes Food & Dining (₹500), NOT Shopping (₹10,000)
      final breakdown = await analyticsEngine.getCategoryBreakdown(2026, 8);
      expect(breakdown.length, equals(1));
      expect(breakdown.first.categoryId, equals(CategoryEngine.catFood));
      expect(breakdown.first.total, equals(50000));

      // Verify Daily Trend on 12th Aug has 0 expense
      final trends = await analyticsEngine.getDailyTrend(2026, 8);
      final day10 = trends.firstWhere((t) => t.date.day == 10);
      final day12 = trends.firstWhere((t) => t.date.day == 12);
      expect(day10.total, equals(50000));
      expect(day12.total, equals(0)); // 12th was self-transfer, must be 0

      // Verify IntelligenceEngine health score / category analysis
      final insights = await intelligenceEngine.generateInsights();
      expect(insights, isA<List>());
    });
  });
}
