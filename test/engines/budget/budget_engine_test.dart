import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/engines/budget/budget_engine.dart';
import 'package:your_budget_manager/features/budgets/domain/repositories/budget_repository.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:your_budget_manager/features/budgets/domain/entities/budget.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}
class MockExpenseEngine extends Mock implements ExpenseEngine {}
class MockRecurringRepository extends Mock implements RecurringRepository {}
class FakeTransaction extends Fake implements Transaction {}
class FakeBudget extends Fake implements Budget {}

void main() {
  late BudgetEngine budgetEngine;
  late MockBudgetRepository mockBudgetRepo;
  late MockExpenseEngine mockExpenseEngine;
  late MockRecurringRepository mockRecurringRepo;

  setUpAll(() {
    registerFallbackValue(FakeBudget());
  });

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockExpenseEngine = MockExpenseEngine();
    mockRecurringRepo = MockRecurringRepository();

    budgetEngine = BudgetEngine(
      mockBudgetRepo,
      mockExpenseEngine,
      mockRecurringRepo,
    );
  });

  group('calculateDailyAllowance', () {
    test('normal case: remaining > 0, normal days left', () async {
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.income))
          .thenAnswer((_) async => 5000.0);
      
      when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => [
        RecurringTransaction(
          id: '1',
          amount: const Amount(1000.0),
          categoryId: 'c1',
          type: TransactionType.expense,
          frequency: RecurringFrequency.monthly,
          nextDate: DateTime.now(),
        ),
      ]);

      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.expense))
          .thenAnswer((_) async => 1000.0);

      final date = DateTime(2023, 10, 15); // 17 days left (31 - 15 + 1)
      final allowance = await budgetEngine.calculateDailyAllowance(date: date);

      expect(allowance.remaining, 3000.0);
      expect(allowance.daysLeft, 17);
      expect(allowance.amount, 3000.0 / 17);
      expect(allowance.isHealthy, true);
    });

    test('zero income case', () async {
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.income))
          .thenAnswer((_) async => 0.0);
      
      when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => []);

      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.expense))
          .thenAnswer((_) async => 100.0);

      final date = DateTime(2023, 10, 15);
      final allowance = await budgetEngine.calculateDailyAllowance(date: date);

      expect(allowance.remaining, -100.0);
      expect(allowance.amount, -100.0 / 17);
      expect(allowance.isHealthy, false);
    });

    test('overspent case', () async {
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.income))
          .thenAnswer((_) async => 1000.0);
      
      when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => []);

      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.expense))
          .thenAnswer((_) async => 1200.0);

      final date = DateTime(2023, 10, 15);
      final allowance = await budgetEngine.calculateDailyAllowance(date: date);

      expect(allowance.remaining, -200.0);
      expect(allowance.isHealthy, false);
    });

    test('last day of month', () async {
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.income))
          .thenAnswer((_) async => 1000.0);
      when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => []);
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.expense))
          .thenAnswer((_) async => 500.0);

      final date = DateTime(2023, 10, 31); // 1 day left
      final allowance = await budgetEngine.calculateDailyAllowance(date: date);

      expect(allowance.daysLeft, 1);
      expect(allowance.amount, 500.0);
    });

    test('first day of month', () async {
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.income))
          .thenAnswer((_) async => 1000.0);
      when(() => mockRecurringRepo.getActive()).thenAnswer((_) async => []);
      when(() => mockExpenseEngine.getMonthlyTotal(any(), type: TransactionType.expense))
          .thenAnswer((_) async => 0.0);

      final date = DateTime(2023, 10, 1); // 31 days left
      final allowance = await budgetEngine.calculateDailyAllowance(date: date);

      expect(allowance.daysLeft, 31);
      expect(allowance.amount, 1000.0 / 31);
    });
  });
}
