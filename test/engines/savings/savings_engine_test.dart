import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('SavingsEngine.createGoal', () {
    test('creates a goal with correct initial values', () async {
      await engine.createGoal(name: 'Emergency Fund', targetAmountPaise: 10000000);

      final goals = await db.savingsGoalDao.getAll();
      expect(goals.length, 1);
      expect(goals.first.name, 'Emergency Fund');
      expect(goals.first.targetAmount, 10000000);
      expect(goals.first.currentAmount, 0);
      expect(goals.first.status, 'active');
    });

    test('throws on empty name', () {
      expect(
        () => engine.createGoal(name: '', targetAmountPaise: 100000),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on zero target amount', () {
      expect(
        () => engine.createGoal(name: 'Goal', targetAmountPaise: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('SavingsEngine.contributeToGoal', () {
    test('increases currentAmount', () async {
      await engine.createGoal(name: 'iPhone', targetAmountPaise: 8000000);
      final goals = await db.savingsGoalDao.getAll();
      final id = goals.first.id;

      await engine.contributeToGoal(id, 1000000);

      final updated = await db.savingsGoalDao.getAll();
      expect(updated.first.currentAmount, 1000000);
    });

    test('marks goal as completed when fully funded', () async {
      await engine.createGoal(name: 'Small Goal', targetAmountPaise: 50000);
      final goals = await db.savingsGoalDao.getAll();
      final id = goals.first.id;

      await engine.contributeToGoal(id, 50000);

      final updated = await db.savingsGoalDao.getAll();
      expect(updated.first.status, 'completed');
    });
  });

  group('SavingsEngine.getTotalSavings', () {
    test('sums currentAmount across all goals', () async {
      await engine.createGoal(name: 'G1', targetAmountPaise: 1000000);
      await engine.createGoal(name: 'G2', targetAmountPaise: 2000000);
      final goals = await db.savingsGoalDao.getAll();
      await engine.contributeToGoal(goals[0].id, 100000);
      await engine.contributeToGoal(goals[1].id, 200000);

      final total = await engine.getTotalSavings();
      expect(total, 300000);
    });
  });
}
