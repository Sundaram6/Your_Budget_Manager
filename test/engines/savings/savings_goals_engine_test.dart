import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/features/savings/data/repositories/savings_goal_repository_impl.dart';

void main() {
  late AppDatabase db;
  late SavingsEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final repo = SavingsGoalRepositoryImpl(db.savingsGoalDao);
    engine = SavingsEngine(db.savingsGoalDao, repo);
  });

  tearDown(() => db.close());

  group('SavingsGoalsEngine Protocol Tests', () {
    test('1. createGoal creates goal with correct target in paise', () async {
      await engine.createGoal(
        name: 'Emergency Fund',
        targetAmountPaise: 500000, // ₹5,000 in paise
        autoDeduct: true,
        autoDeductAmountPaise: 100000, // ₹1,000/mo
      );

      final goals = await db.savingsGoalDao.getAll();
      expect(goals.length, 1);
      expect(goals.first.name, 'Emergency Fund');
      expect(goals.first.targetAmount, 500000);
      expect(goals.first.currentAmount, 0);
      expect(goals.first.autoDeduct, isTrue);
      expect(goals.first.autoDeductAmount, 100000);
    });

    test('2. contributeToGoal increments currentAmount in paise', () async {
      await engine.createGoal(
        name: 'iPhone 16',
        targetAmountPaise: 10000000, // ₹1,00,000
      );
      final goals = await db.savingsGoalDao.getAll();
      final id = goals.first.id;

      await engine.contributeToGoal(id, 50000); // add ₹500 in paise

      final updated = await db.savingsGoalDao.getAll();
      expect(updated.first.currentAmount, 50000);

      await engine.contributeToGoal(id, 100000); // add ₹1,000 in paise
      final updated2 = await db.savingsGoalDao.getAll();
      expect(updated2.first.currentAmount, 150000);
    });

    test('3. getGoalsForBudget returns only linked goals', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.into(db.budgetsTable).insert(BudgetsTableCompanion.insert(
        id: 'b_august_2026',
        name: const Value('August Budget'),
        amount: 2000000,
        month: 8,
        year: 2026,
        createdAt: now,
      ));
      await db.into(db.budgetsTable).insert(BudgetsTableCompanion.insert(
        id: 'b_september_2026',
        name: const Value('September Budget'),
        amount: 2000000,
        month: 9,
        year: 2026,
        createdAt: now,
      ));

      await engine.createGoal(
        name: 'Goal 1 Linked',
        targetAmountPaise: 200000,
        linkedBudgetId: 'b_august_2026',
      );
      await engine.createGoal(
        name: 'Goal 2 Unlinked',
        targetAmountPaise: 300000,
        linkedBudgetId: null,
      );
      await engine.createGoal(
        name: 'Goal 3 Other Budget',
        targetAmountPaise: 400000,
        linkedBudgetId: 'b_september_2026',
      );

      final linkedGoals = await engine.getGoalsForBudget('b_august_2026');
      expect(linkedGoals.length, 1);
      expect(linkedGoals.first.name, 'Goal 1 Linked');
    });

    test('4. calculate50_30_20 math is mathematically accurate', () {
      final monthlyIncomePaise = 5000000; // ₹50,000
      final breakdown = engine.calculate50_30_20(monthlyIncomePaise);

      expect(breakdown.needs, 2500000); // 50% = ₹25,000
      expect(breakdown.wants, 1500000); // 30% = ₹15,000
      expect(breakdown.savings, 1000000); // 20% = ₹10,000
      expect(breakdown.needs + breakdown.wants + breakdown.savings, monthlyIncomePaise);
    });

    test('5 & 6. executeAutoDeductions adds correct amount and skips already-deducted goals', () async {
      final budgetId = 'b_current';
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.into(db.budgetsTable).insert(BudgetsTableCompanion.insert(
        id: budgetId,
        name: const Value('Current Budget'),
        amount: 2000000,
        month: 8,
        year: 2026,
        createdAt: now,
      ));

      await engine.createGoal(
        name: 'Auto Goal 1',
        targetAmountPaise: 1000000,
        linkedBudgetId: budgetId,
        autoDeduct: true,
        autoDeductAmountPaise: 100000, // ₹1,000
      );

      // First execution in current month
      await engine.executeAutoDeductions(budgetId);

      final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());
      var goals = await db.savingsGoalDao.getAll();
      expect(goals.first.currentAmount, 100000);
      expect(goals.first.lastAutoDeductedMonth, currentMonthKey);

      // Second execution in same month MUST be skipped
      await engine.executeAutoDeductions(budgetId);
      goals = await db.savingsGoalDao.getAll();
      expect(goals.first.currentAmount, 100000); // no duplicate addition!
    });
  });
}
