import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/engines/savings/models/savings_goal.dart';

void main() {
  late AppDatabase db;
  late SavingsEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    engine = SavingsEngine(db.savingsGoalDao);
  });

  tearDown(() => db.close());

  group('SavingsEngine.createGoal', () {
    test('creates a goal with correct initial values', () async {
      await engine.createGoal(name: 'Emergency Fund', targetAmount: 100000);

      final goals = await db.savingsGoalDao.getAll();
      expect(goals.length, 1);
      expect(goals.first.name, 'Emergency Fund');
      expect(goals.first.targetAmount, 100000.0);
      expect(goals.first.currentAmount, 0.0);
      expect(goals.first.status, 'active');
    });

    test('throws on empty name', () {
      expect(
        () => engine.createGoal(name: '', targetAmount: 1000),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on zero target amount', () {
      expect(
        () => engine.createGoal(name: 'Goal', targetAmount: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('SavingsEngine.deposit', () {
    test('increases currentAmount', () async {
      await engine.createGoal(name: 'iPhone', targetAmount: 80000);
      final goals = await db.savingsGoalDao.getAll();
      final id = goals.first.id;

      await engine.deposit(id, 10000);

      final updated = await db.savingsGoalDao.getAll();
      expect(updated.first.currentAmount, 10000.0);
    });

    test('marks goal as completed when fully funded', () async {
      await engine.createGoal(name: 'Small Goal', targetAmount: 500);
      final goals = await db.savingsGoalDao.getAll();
      final id = goals.first.id;

      await engine.deposit(id, 500);

      final updated = await db.savingsGoalDao.getAll();
      expect(updated.first.status, 'completed');
    });
  });

  group('SavingsGoalModel.progress', () {
    test('returns 0.5 at half funded', () {
      final model = SavingsGoalModel(
        id: '1',
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 500,
        startDate: DateTime.now(),
        status: SavingsGoalStatus.active,
        iconName: 'savings',
        colorHex: '#FFD700',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(model.progress, 0.5);
    });

    test('clamps to 1.0 when over-funded', () {
      final model = SavingsGoalModel(
        id: '1',
        name: 'Test',
        targetAmount: 1000,
        currentAmount: 1500,
        startDate: DateTime.now(),
        status: SavingsGoalStatus.completed,
        iconName: 'savings',
        colorHex: '#FFD700',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(model.progress, 1.0);
    });
  });

  group('SavingsEngine.totalSaved', () {
    test('sums currentAmount across all goals', () async {
      await engine.createGoal(name: 'G1', targetAmount: 10000);
      await engine.createGoal(name: 'G2', targetAmount: 20000);
      final goals = await db.savingsGoalDao.getAll();
      await engine.deposit(goals[0].id, 1000);
      await engine.deposit(goals[1].id, 2000);

      final total = await engine.totalSaved();
      expect(total, 3000.0);
    });
  });
}
