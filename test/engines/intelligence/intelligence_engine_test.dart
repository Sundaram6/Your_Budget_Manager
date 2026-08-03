import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/budget_dao.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/database/daos/savings_goal_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/intelligence/intelligence_engine.dart';
import 'package:your_budget_manager/engines/intelligence/models/ai_insight.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:your_budget_manager/features/savings/data/repositories/savings_goal_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';

void main() {
  late AppDatabase db;
  late BudgetDao budgetDao;
  late TransactionDao transactionDao;
  late CategoryDao categoryDao;
  late SavingsGoalDao savingsGoalDao;
  late BudgetRepositoryImpl budgetRepo;
  late TransactionRepositoryImpl transactionRepo;
  late SavingsGoalRepositoryImpl savingsRepo;
  late BudgetEngine budgetEngine;
  late SavingsEngine savingsEngine;
  late ExpenseEngine expenseEngine;
  late IntelligenceEngine intelligenceEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseHealthCheck(db).run();
    budgetDao = BudgetDao(db);
    transactionDao = TransactionDao(db);
    categoryDao = CategoryDao(db);
    savingsGoalDao = SavingsGoalDao(db);

    budgetRepo = BudgetRepositoryImpl(budgetDao);
    transactionRepo = TransactionRepositoryImpl(transactionDao);
    savingsRepo = SavingsGoalRepositoryImpl(savingsGoalDao);

    expenseEngine = ExpenseEngine(transactionRepo);
    budgetEngine = BudgetEngine(budgetRepo, expenseEngine);
    savingsEngine = SavingsEngine(savingsGoalDao, savingsRepo);

    intelligenceEngine = IntelligenceEngine(
      budgetEngine: budgetEngine,
      savingsEngine: savingsEngine,
      expenseEngine: expenseEngine,
      transactionDao: transactionDao,
      categoryDao: categoryDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('calculateBudgetHealthScore returns 100 when under budget with active savings goal', () async {
    final now = DateTime.now();
    await budgetEngine.setMonthlyBudget(amountPaise: 2000000, month: now.month, year: now.year); // ₹20,000
    await savingsEngine.createGoal(name: 'Emergency Fund', targetAmountPaise: 5000000); // ₹50,000

    final score = await intelligenceEngine.calculateBudgetHealthScore();
    expect(score, equals(100));
  });

  test('calculateBudgetHealthScore returns <50 when over budget', () async {
    final now = DateTime.now();
    await budgetEngine.setMonthlyBudget(amountPaise: 500000, month: now.month, year: now.year); // ₹5,000

    final catId = 'cat_food';

    await expenseEngine.addTransaction(
      amount: 6000.0,
      date: now,
      categoryId: catId,
      type: TransactionType.expense,
    );

    final score = await intelligenceEngine.calculateBudgetHealthScore();
    expect(score, lessThan(50));
  });

  test('analyzeCategorySpending creates category warning when spending > 40% in one category', () async {
    final now = DateTime.now();
    final catId = 'cat_food';

    await expenseEngine.addTransaction(
      amount: 5000.0,
      date: now,
      categoryId: catId,
      type: TransactionType.expense,
    );

    await expenseEngine.addTransaction(
      amount: 5000.0,
      date: now,
      categoryId: catId,
      type: TransactionType.expense,
    );

    final insights = await intelligenceEngine.analyzeCategorySpending();
    expect(insights.any((i) => i.type == InsightType.warning), isTrue);
  });

  test('getDailyAdvice returns over-budget message when budget exceeded', () async {
    final now = DateTime.now();
    await budgetEngine.setMonthlyBudget(amountPaise: 100000, month: now.month, year: now.year); // ₹1,000

    final catId = 'cat_shopping';

    await expenseEngine.addTransaction(
      amount: 1500.0,
      date: now,
      categoryId: catId,
      type: TransactionType.expense,
    );

    final advice = await intelligenceEngine.getDailyAdvice();
    expect(advice, contains('Budget exceeded'));
  });

  test('getDailyAdvice returns on-track message when budget healthy', () async {
    final now = DateTime.now();
    await budgetEngine.setMonthlyBudget(amountPaise: 3000000, month: now.month, year: now.year); // ₹30,000

    final advice = await intelligenceEngine.getDailyAdvice();
    expect(advice, contains('on track'));
  });

  test('generateSavingsRecommendations suggests goal creation when no goals exist', () async {
    final recommendations = await intelligenceEngine.generateSavingsRecommendations();
    expect(recommendations.any((r) => r.id == 'savings_create_goal'), isTrue);
  });
}
