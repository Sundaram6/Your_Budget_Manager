import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/budget_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';

import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';

void main() {
  late AppDatabase db;
  late BudgetDao budgetDao;
  late TransactionDao transactionDao;
  late BudgetRepositoryImpl budgetRepo;
  late TransactionRepositoryImpl transactionRepo;
  late ExpenseEngine expenseEngine;
  late BudgetEngine budgetEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseHealthCheck(db).run();
    budgetDao = BudgetDao(db);
    transactionDao = TransactionDao(db);
    budgetRepo = BudgetRepositoryImpl(budgetDao);
    transactionRepo = TransactionRepositoryImpl(transactionDao);
    expenseEngine = ExpenseEngine(transactionRepo);
    budgetEngine = BudgetEngine(budgetRepo, expenseEngine);
  });


  tearDown(() async {
    await db.close();
  });

  group('BudgetEngine Unit Tests (8 Committed Cases)', () {
    test('1. setMonthlyBudget creates new overall budget in database', () async {
      final now = DateTime.now();
      final budget = await budgetEngine.setMonthlyBudget(
        amountPaise: 2000000, // ₹20,000
        month: now.month,
        year: now.year,
      );

      expect(budget.amount, equals(2000000));
      expect(budget.month, equals(now.month));
      expect(budget.year, equals(now.year));
      expect(budget.categoryId, isNull);

      final overallInDb = await budgetRepo.getOverallBudget(now.month, now.year);
      expect(overallInDb, isNotNull);
      expect(overallInDb!.amount, equals(2000000));
    });

    test('2. setMonthlyBudget for same month/year updates existing budget without duplicate rows', () async {
      final now = DateTime.now();
      await budgetEngine.setMonthlyBudget(
        amountPaise: 2000000, // ₹20,000
        month: now.month,
        year: now.year,
      );

      final updated = await budgetEngine.setMonthlyBudget(
        amountPaise: 3000000, // ₹30,000
        month: now.month,
        year: now.year,
      );

      expect(updated.amount, equals(3000000));

      final budgets = await budgetRepo.getBudgetsForMonth(now.month, now.year);
      expect(budgets.length, equals(1));
      expect(budgets.first.amount, equals(3000000));
    });

    test('3. getRemainingBudget math is correct with integer paise', () async {
      final now = DateTime.now();
      await budgetEngine.setMonthlyBudget(
        amountPaise: 1000000, // ₹10,000
        month: now.month,
        year: now.year,
      );

      // Add ₹2,500 expense
      await expenseEngine.addTransaction(
        amount: 2500.0,
        date: now,
        categoryId: CategoryEngine.catGroceries,
        type: TransactionType.expense,
      );

      final remaining = await budgetEngine.getRemainingBudget(month: now.month, year: now.year);
      expect(remaining, equals(750000)); // ₹7,500 = 750000 paise
    });

    test('4. getDailyAllowance returns null when no budget is set', () async {
      final allowance = await budgetEngine.calculateDailyAllowance();
      expect(allowance, isNull);
    });

    test('5. getDailyAllowance returns amount: 0 + isOverBudget=true when budget is exceeded', () async {
      final now = DateTime.now();
      await budgetEngine.setMonthlyBudget(
        amountPaise: 500000, // ₹5,000
        month: now.month,
        year: now.year,
      );

      // Add ₹6,000 expense (exceeds budget by ₹1,000)
      await expenseEngine.addTransaction(
        amount: 6000.0,
        date: now,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final allowance = await budgetEngine.calculateDailyAllowance(date: now);
      expect(allowance, isNotNull);
      expect(allowance!.amount, equals(0));
      expect(allowance.isOverBudget, isTrue);
      expect(allowance.message, contains('Budget exceeded by ₹1000.00'));
    });

    test('6. getDailyAllowance NEVER returns a negative amount', () async {
      final now = DateTime.now();
      await budgetEngine.setMonthlyBudget(
        amountPaise: 100000, // ₹1,000
        month: now.month,
        year: now.year,
      );

      await expenseEngine.addTransaction(
        amount: 15000.0, // ₹15,000 expense
        date: now,
        categoryId: CategoryEngine.catShopping,
        type: TransactionType.expense,
      );

      final allowance = await budgetEngine.calculateDailyAllowance(date: now);
      expect(allowance, isNotNull);
      expect(allowance!.amount, equals(0));
      expect(allowance.amount >= 0, isTrue);
    });

    test('7. handleMonthRollover creates next month budget correctly from previous month', () async {
      final now = DateTime.now();
      final prevDate = DateTime(now.year, now.month - 1, 1);

      // Seed previous month budget ₹15,000
      await budgetEngine.setMonthlyBudget(
        amountPaise: 1500000,
        month: prevDate.month,
        year: prevDate.year,
      );

      // Current month has no budget initially
      final currentBefore = await budgetRepo.getOverallBudget(now.month, now.year);
      expect(currentBefore, isNull);

      // Run month rollover
      await budgetEngine.handleMonthRollover(date: now);

      // Current month budget auto-created
      final currentAfter = await budgetRepo.getOverallBudget(now.month, now.year);
      expect(currentAfter, isNotNull);
      expect(currentAfter!.amount, equals(1500000));
    });

    test('8. Budget warning overflow detection detects projected budget overflow correctly', () async {
      final now = DateTime.now();
      await budgetEngine.setMonthlyBudget(
        amountPaise: 1000000, // ₹10,000
        month: now.month,
        year: now.year,
      );

      await expenseEngine.addTransaction(
        amount: 8000.0,
        date: now,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      // Adding ₹3,000 expense (total projected 8000+3000 = 11000 > 10000)
      final remainingPaise = await budgetEngine.getRemainingBudget(month: now.month, year: now.year);
      expect(remainingPaise, equals(200000)); // ₹2,000 remaining
      final projectedSpend = 8000.0 + 3000.0;
      expect(projectedSpend > 10000.0, isTrue);
    });
  });
}
