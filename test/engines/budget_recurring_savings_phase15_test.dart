import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/savings/data/repositories/savings_goal_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart' as domain_tx;
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';
import 'package:your_budget_manager/repositories/recurring_repository.dart';

import 'package:your_budget_manager/database/health/database_health_check.dart';

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

  group('Phase 15: BudgetEngine Recurring & Savings Commitments', () {
    test('Baseline: budget with posted transactions only (zero recurring/savings)', () async {
      final now = DateTime(2026, 8, 15);

      // Set budget: ₹50,000 (5,000,000 paise)
      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Insert 1 posted expense transaction: ₹10,000 (1,000,000 paise)
      await txRepo.insertTransaction(
        domain_tx.Transaction(
          id: 'tx_1',
          amount: const Amount(1000000),
          date: DateTime(2026, 8, 10),
          categoryId: 'cat_food',
          type: TransactionType.expense,
          paymentMethod: PaymentMethod.debit_card,
        ),
      );

      final progress = await budgetEngine.calculateBudgetProgress(date: now);
      expect(progress, isNotNull);
      expect(progress!.limit, equals(5000000));
      expect(progress.spent, equals(1000000));
      expect(progress.committedRecurring, equals(0));
      expect(progress.committedSavings, equals(0));
      expect(progress.totalCommitted, equals(1000000));
      expect(progress.remaining, equals(4000000));
      expect(progress.isOverBudget, isFalse);

      final allowance = await budgetEngine.calculateDailyAllowance(date: now);
      expect(allowance, isNotNull);
      expect(allowance!.isOverBudget, isFalse);
      expect(allowance.remaining, equals(4000000));
      // Days left in Aug (31 - 15 + 1 = 17 days): 4,000,000 ~/ 17 = 235,294 paise (~₹2,352/day)
      expect(allowance.amount, equals(4000000 ~/ 17));
    });

    test('Upcoming recurring payments factor into committed spend and reduce daily allowance', () async {
      final now = DateTime(2026, 8, 15);

      // Set budget: ₹50,000 (5,000,000 paise)
      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Posted spend: ₹10,000
      await txRepo.insertTransaction(
        domain_tx.Transaction(
          id: 'tx_1',
          amount: const Amount(1000000),
          date: DateTime(2026, 8, 10),
          categoryId: 'cat_food',
          type: TransactionType.expense,
          paymentMethod: PaymentMethod.debit_card,
        ),
      );

      // Active upcoming recurring expense: Rent ₹20,000 due on Aug 25
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_rent',
          title: 'Apartment Rent',
          amountPaise: 2000000,
          categoryId: 'cat_utilities',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 25),
          nextDueDate: DateTime(2026, 8, 25),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final progress = await budgetEngine.calculateBudgetProgress(date: now);
      expect(progress, isNotNull);
      expect(progress!.spent, equals(1000000)); // ₹10,000
      expect(progress.committedRecurring, equals(2000000)); // ₹20,000
      expect(progress.committedSavings, equals(0));
      expect(progress.totalCommitted, equals(3000000)); // ₹30,000 total committed
      expect(progress.remaining, equals(2000000)); // ₹20,000 effective remaining
      expect(progress.isOverBudget, isFalse);

      final allowance = await budgetEngine.calculateDailyAllowance(date: now);
      expect(allowance, isNotNull);
      expect(allowance!.isOverBudget, isFalse);
      expect(allowance.remaining, equals(2000000));
      // 2,000,000 ~/ 17 = 117,647 paise (~₹1,176/day)
      expect(allowance.amount, equals(2000000 ~/ 17));
    });

    test('Inactive / paused recurring payments are excluded from committed spend', () async {
      final now = DateTime(2026, 8, 15);

      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Inactive recurring: Gym ₹3,000
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_gym',
          title: 'Gym Membership',
          amountPaise: 300000,
          categoryId: 'cat_health',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 20),
          nextDueDate: DateTime(2026, 8, 20),
          isActive: false, // PAUSED / INACTIVE
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final upcoming = await budgetEngine.getUpcomingRecurringSpend(date: now);
      expect(upcoming, equals(0));
    });

    test('Active auto-deduct savings goal factors into committed spend', () async {
      final now = DateTime(2026, 8, 15);

      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Active savings goal: ₹100,000 target, ₹5,000/mo auto-deduct (not yet deducted in Aug)
      await savingsEngine.createGoal(
        name: 'Emergency Fund',
        targetAmountPaise: 10000000,
        autoDeduct: true,
        autoDeductAmountPaise: 500000,
      );

      final committedSavings = await budgetEngine.getCommittedSavings(date: now);
      expect(committedSavings, equals(500000)); // ₹5,000

      final progress = await budgetEngine.calculateBudgetProgress(date: now);
      expect(progress!.committedSavings, equals(500000));
      expect(progress.totalCommitted, equals(500000));
      expect(progress.remaining, equals(4500000));
    });

    test('Goal already auto-deducted this month is excluded to avoid double-counting', () async {
      final now = DateTime(2026, 8, 15);
      final currentMonthKey = DateFormat('yyyy-MM').format(now);

      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Create goal
      await savingsEngine.createGoal(
        name: 'Trip Fund',
        targetAmountPaise: 5000000,
        autoDeduct: true,
        autoDeductAmountPaise: 500000,
      );

      final goals = await savingsEngine.watchGoals().first;
      final goal = goals.first;

      // Simulate that auto-deduction already ran for this month (monthKey = 2026-08)
      await db.savingsGoalDao.recordAutoDeduction(goal.id, currentMonthKey, 500000);

      // Committed savings should now be 0 since this month is already deducted
      final committedSavings = await budgetEngine.getCommittedSavings(date: now);
      expect(committedSavings, equals(0));
    });

    test('Completed savings goal is excluded from future commitments', () async {
      final now = DateTime(2026, 8, 15);

      // Create goal with target ₹50,000, currently ₹50,000 (completed)
      await savingsEngine.createGoal(
        name: 'Laptop Fund',
        targetAmountPaise: 5000000,
        autoDeduct: true,
        autoDeductAmountPaise: 1000000,
      );

      final goals = await savingsEngine.watchGoals().first;
      final goal = goals.first;

      // Complete the goal
      await savingsEngine.contributeToGoal(goal.id, 5000000);

      final committedSavings = await budgetEngine.getCommittedSavings(date: now);
      expect(committedSavings, equals(0));
    });

    test('Over-committed budget surfaces signed negative remaining and isOverBudget=true', () async {
      final now = DateTime(2026, 8, 15);

      // Budget: ₹30,000 (3,000,000 paise)
      await budgetEngine.setMonthlyBudget(
        amountPaise: 3000000,
        month: 8,
        year: 2026,
      );

      // Spent: ₹15,000
      await txRepo.insertTransaction(
        domain_tx.Transaction(
          id: 'tx_1',
          amount: const Amount(1500000),
          date: DateTime(2026, 8, 10),
          categoryId: 'cat_food',
          type: TransactionType.expense,
          paymentMethod: PaymentMethod.debit_card,
        ),
      );

      // Recurring Rent due Aug 25: ₹20,000
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_rent',
          title: 'Rent',
          amountPaise: 2000000,
          categoryId: 'cat_utilities',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 25),
          nextDueDate: DateTime(2026, 8, 25),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Savings auto-deduct: ₹5,000
      await savingsEngine.createGoal(
        name: 'Savings',
        targetAmountPaise: 10000000,
        autoDeduct: true,
        autoDeductAmountPaise: 500000,
      );

      // Total committed: 15,000 + 20,000 + 5,000 = ₹40,000 (Over budget by ₹10,000!)
      final progress = await budgetEngine.calculateBudgetProgress(date: now);
      expect(progress, isNotNull);
      expect(progress!.limit, equals(3000000));
      expect(progress.spent, equals(1500000));
      expect(progress.committedRecurring, equals(2000000));
      expect(progress.committedSavings, equals(500000));
      expect(progress.totalCommitted, equals(4000000));
      expect(progress.remaining, equals(-1000000)); // Signed negative: -₹10,000
      expect(progress.isOverBudget, isTrue);
      expect(progress.percentage, greaterThan(1.0));

      final allowance = await budgetEngine.calculateDailyAllowance(date: now);
      expect(allowance, isNotNull);
      expect(allowance!.amount, equals(0));
      expect(allowance.isOverBudget, isTrue);
      expect(allowance.remaining, equals(-1000000));
      expect(allowance.message, contains('Budget over-committed by ₹10,000'));
    });
  });

  group('Phase 15: AnalyticsEngine Recurring Commitments & Savings', () {
    test('getRecurringCommitments calculates normalized monthly total and upcoming total', () async {
      // Monthly Netflix ₹500 due Aug 20
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_netflix',
          title: 'Netflix',
          amountPaise: 50000,
          categoryId: 'cat_entertainment',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 20),
          nextDueDate: DateTime(2026, 8, 20),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Weekly Grocery ₹1,000 (weekly normalized to monthly: 1000 * 52 / 12 = 4333.33 -> 433333 paise)
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_grocery',
          title: 'Weekly Grocery',
          amountPaise: 100000,
          categoryId: 'cat_food',
          type: 'expense',
          frequency: 'weekly',
          startDate: DateTime(2026, 8, 1),
          nextDueDate: DateTime(2026, 8, 22),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final summary = await analyticsEngine.getRecurringCommitments(year: 2026, month: 8);
      expect(summary.recurringCount, equals(2));
      expect(summary.totalMonthlyRecurringPaise, greaterThan(0));
      expect(summary.upcomingRecurringThisMonthPaise, greaterThan(0));
    });

    test('getSavingsAnalytics aggregates active goals, saved total, target total, and auto-save amount', () async {
      await savingsEngine.createGoal(
        name: 'Car Fund',
        targetAmountPaise: 50000000, // ₹500,000
        autoDeduct: true,
        autoDeductAmountPaise: 1000000, // ₹10,000/mo
      );

      await savingsEngine.createGoal(
        name: 'Vacation',
        targetAmountPaise: 20000000, // ₹200,000
        autoDeduct: false, // Manual
      );

      final goals = await savingsEngine.watchGoals().first;
      await savingsEngine.contributeToGoal(goals.first.id, 5000000); // ₹50,000 saved

      final summary = await analyticsEngine.getSavingsAnalytics();
      expect(summary.totalGoalsCount, equals(2));
      expect(summary.activeGoalsCount, equals(2));
      expect(summary.totalSavedPaise, equals(5000000));
      expect(summary.totalTargetPaise, equals(70000000));
      expect(summary.monthlyCommittedAutoSavePaise, equals(1000000));
      expect(summary.overallProgressPercent, closeTo(7.14, 0.1));
    });

    test('getTotalCommittedMonthlySpend sums posted spend + upcoming recurring + committed auto-save', () async {
      // Posted spend: ₹5,000
      await txRepo.insertTransaction(
        domain_tx.Transaction(
          id: 'tx_1',
          amount: const Amount(500000),
          date: DateTime(2026, 8, 5),
          categoryId: 'cat_food',
          type: TransactionType.expense,
          paymentMethod: PaymentMethod.debit_card,
        ),
      );

      // Upcoming recurring: ₹10,000
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_sub',
          title: 'Annual Sub',
          amountPaise: 1000000,
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

      // Committed auto-save: ₹3,000
      await savingsEngine.createGoal(
        name: 'Goal',
        targetAmountPaise: 10000000,
        autoDeduct: true,
        autoDeductAmountPaise: 300000,
      );

      final totalCommitted = await analyticsEngine.getTotalCommittedMonthlySpend(2026, 8);
      // 5,000 + 10,000 + 3,000 = ₹18,000 (1,800,000 paise)
      expect(totalCommitted, equals(1800000));
    });
  });

  group('Phase 15: IntelligenceEngine Recurring & Savings Insights', () {
    test('Health score reflects commitment strain and automated savings discipline', () async {
      // Budget ₹50,000
      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Active automated savings goal -> gives +10 discipline bonus
      await savingsEngine.createGoal(
        name: 'House Downpayment',
        targetAmountPaise: 100000000,
        autoDeduct: true,
        autoDeductAmountPaise: 1000000,
      );

      final score = await intelligenceEngine.calculateBudgetHealthScore();
      expect(score, equals(100)); // Healthy score
    });

    test('generateInsights includes upcoming recurring bills and savings velocity insights', () async {
      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000,
        month: 8,
        year: 2026,
      );

      // Upcoming bill due Aug 25
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_broadband',
          title: 'Broadband',
          amountPaise: 150000,
          categoryId: 'cat_utilities',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 25),
          nextDueDate: DateTime(2026, 8, 25),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Active auto-deduct goal
      await savingsEngine.createGoal(
        name: 'Retirement',
        targetAmountPaise: 50000000,
        autoDeduct: true,
        autoDeductAmountPaise: 200000,
      );

      final insights = await intelligenceEngine.generateInsights();
      expect(insights, isNotEmpty);

      final hasRecurringInsight = insights.any((i) => i.id.contains('recurring') || i.title.contains('Recurring'));
      expect(hasRecurringInsight, isTrue);

      final hasSavingsInsight = insights.any((i) => i.id.contains('savings') || i.title.contains('Saving'));
      expect(hasSavingsInsight, isTrue);
    });

    test('getDailyAdvice communicates upcoming commitments and remaining funds', () async {
      await budgetEngine.setMonthlyBudget(
        amountPaise: 5000000, // ₹50,000
        month: 8,
        year: 2026,
      );

      // Recurring bills due
      await recurringRepo.insert(
        RecurringTransactionModel(
          id: 'rec_emi',
          title: 'Car Loan EMI',
          amountPaise: 1500000, // ₹15,000
          categoryId: 'cat_utilities',
          type: 'expense',
          frequency: 'monthly',
          startDate: DateTime(2026, 1, 28),
          nextDueDate: DateTime(2026, 8, 28),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final advice = await intelligenceEngine.getDailyAdvice();
      expect(advice, isNotEmpty);
      expect(advice, isNot(contains('NaN')));
    });
  });
}
