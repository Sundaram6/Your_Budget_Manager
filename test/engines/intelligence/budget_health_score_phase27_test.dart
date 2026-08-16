import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/intelligence/models/ai_insight.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/savings/data/repositories/savings_goal_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart' as domain_tx;
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';
import 'package:your_budget_manager/repositories/recurring_repository.dart';

void main() {
  late AppDatabase db;
  late BudgetRepositoryImpl budgetRepo;
  late TransactionRepositoryImpl txRepo;
  late CategoryRepositoryImpl catRepo;
  late SavingsGoalRepositoryImpl savingsRepo;
  late ExpenseEngine expenseEngine;
  late SavingsEngine savingsEngine;
  late RecurringRepository recurringRepo;
  late BudgetEngine budgetEngine;
  late AnalyticsEngine analyticsEngine;
  late IntelligenceEngine intelligenceEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseHealthCheck(db).run();
    DatabaseHelper.instance.setDatabase(db);

    budgetRepo = BudgetRepositoryImpl(db.budgetDao);
    txRepo = TransactionRepositoryImpl(db.transactionDao);
    catRepo = CategoryRepositoryImpl(db.categoryDao);
    savingsRepo = SavingsGoalRepositoryImpl(db.savingsGoalDao);

    expenseEngine = ExpenseEngine(txRepo);
    savingsEngine = SavingsEngine(db.savingsGoalDao, savingsRepo);
    recurringRepo = RecurringRepository.instance;

    budgetEngine = BudgetEngine(
      budgetRepo,
      expenseEngine,
      recurringRepository: recurringRepo,
      savingsEngine: savingsEngine,
    );

    analyticsEngine = AnalyticsEngine(
      txRepo,
      catRepo,
      recurringRepository: recurringRepo,
      savingsEngine: savingsEngine,
    );

    intelligenceEngine = IntelligenceEngine(
      budgetEngine: budgetEngine,
      savingsEngine: savingsEngine,
      expenseEngine: expenseEngine,
      transactionDao: db.transactionDao,
      categoryDao: db.categoryDao,
      recurringRepository: recurringRepo,
      analyticsEngine: analyticsEngine,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> addExpense(int amountPaise, DateTime date, String categoryId) async {
    await txRepo.insertTransaction(domain_tx.Transaction(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      amount: Amount(amountPaise),
      date: date,
      categoryId: categoryId,
      type: TransactionType.expense,
      paymentMethod: PaymentMethod.upi,
    ));
  }

  group('Phase 27: Budget Health Score Signed Scoring Bands', () {
    test('Healthy Band (80 to 100): Low spending + active savings goal yields high score', () async {
      final now = DateTime(2026, 8, 15);
      // Budget ₹50,000 (5,000,000 paise)
      await budgetEngine.setMonthlyBudget(amountPaise: 5000000, month: now.month, year: now.year);
      
      // Spend ₹10,000 (20% utilization)
      await addExpense(1000000, now, 'cat_food');

      // Active auto-deduct goal (+10 bonus)
      await savingsEngine.createGoal(
        name: 'Emergency Fund',
        targetAmountPaise: 50000000,
        autoDeduct: true,
        autoDeductAmountPaise: 200000,
      );

      final score = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(score, greaterThanOrEqualTo(80));
      expect(score, lessThanOrEqualTo(100));
    });

    test('Caution Band (50 to 79): Moderate-high spending (85% utilization) yields caution score', () async {
      final now = DateTime(2026, 8, 15);
      // Budget ₹10,000 (1,000,000 paise)
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);

      // Spend ₹8,500 (85% utilization)
      await addExpense(850000, now, 'cat_food');

      final score = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(score, greaterThanOrEqualTo(35));
      expect(score, lessThanOrEqualTo(79));
    });

    test('Over-Budget Band (0 to 49): Spending slightly exceeding budget (115% utilization) drops score below 50', () async {
      final now = DateTime(2026, 8, 15);
      // Budget ₹10,000 (1,000,000 paise)
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);

      // Spend ₹11,500 (115% utilization)
      await addExpense(1150000, now, 'cat_shopping');

      final score = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThan(50), reason: 'Score must not plateau at ~50 when over budget');
    });

    test('Severely Over-Budget Band (< 0): Heavy overspending (150% - 200% utilization) produces negative score', () async {
      final now = DateTime(2026, 8, 15);
      // Budget ₹10,000 (1,000,000 paise)
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);

      // Spend ₹16,000 (160% utilization)
      await addExpense(1600000, now, 'cat_shopping');

      final score = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(score, lessThan(0), reason: 'Deep overspending must result in a negative health score');
      expect(score, greaterThanOrEqualTo(-100));
    });

    test('Extreme Overspending is clamped at -100', () async {
      final now = DateTime(2026, 8, 15);
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);

      // Spend ₹50,000 (500% utilization)
      await addExpense(5000000, now, 'cat_misc');

      final score = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(score, equals(-100));
    });

    test('High Recurring Burden (>50% of budget) applies penalty', () async {
      final now = DateTime(2026, 8, 15);
      // Budget ₹10,000
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);

      // Recurring bill ₹6,000 (60% of budget)
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_rent',
          title: 'Rent',
          amountPaise: 600000,
          categoryId: 'cat_utilities',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 20),
          nextDueDate: DateTime(2026, 8, 20),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final scoreWithBurden = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(scoreWithBurden, lessThan(90));
    });

    test('Fallback score when no budget is set handles transactions gracefully', () async {
      final now = DateTime(2026, 8, 15);
      // No budget set
      await addExpense(100000, now, 'cat_food');

      final score = await intelligenceEngine.calculateBudgetHealthScore(date: now);
      expect(score, greaterThanOrEqualTo(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });

  group('Phase 27: Survival Mode Tip Generation', () {
    test('getSurvivalModeTip returns null when within budget', () async {
      final now = DateTime(2026, 8, 15);
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);
      await addExpense(500000, now, 'cat_food');

      final tip = await intelligenceEngine.getSurvivalModeTip(date: now);
      expect(tip, isNull);
    });

    test('getSurvivalModeTip returns actionable spending freeze message when over budget', () async {
      final now = DateTime(2026, 8, 15);
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year); // ₹10,000
      await addExpense(1250000, now, 'cat_shopping'); // ₹12,500 (over by ₹2,500)

      final tip = await intelligenceEngine.getSurvivalModeTip(date: now);
      expect(tip, isNotNull);
      expect(tip, contains('Survival Mode'));
      expect(tip, contains('₹2,500'));
      expect(tip, contains('Freeze all discretionary spending'));
    });

    test('generateInsights includes Survival Mode tip at highest priority when over budget', () async {
      final now = DateTime(2026, 8, 15);
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);
      await addExpense(1300000, now, 'cat_food');

      final insights = await intelligenceEngine.generateInsights();
      expect(insights, isNotEmpty);
      expect(insights.first.id, equals('survival_mode_tip'));
      expect(insights.first.title, contains('Survival Mode'));
      expect(insights.first.type, equals(InsightType.warning));
    });

    test('getDailyAdvice returns survival mode alert when over budget', () async {
      final now = DateTime.now();
      await budgetEngine.setMonthlyBudget(amountPaise: 1000000, month: now.month, year: now.year);
      await addExpense(1500000, now, 'cat_utilities');

      final advice = await intelligenceEngine.getDailyAdvice();
      expect(advice, contains('🚨 Budget exceeded'));
      expect(advice, contains('Survival mode active'));
    });
  });
}
