import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/recurring/recurring_engine.dart';
import 'package:your_budget_manager/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:your_budget_manager/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

class MockRecurringRepository extends Mock implements RecurringRepository {}
class MockExpenseEngine extends Mock implements ExpenseEngine {}
class FakeRecurringTransaction extends Fake implements RecurringTransaction {}

void main() {
  late RecurringEngine engine;
  late MockRecurringRepository repository;
  late MockExpenseEngine expenseEngine;

  setUpAll(() {
    registerFallbackValue(FakeRecurringTransaction());
    registerFallbackValue(TransactionType.expense);
  });

  setUp(() {
    repository = MockRecurringRepository();
    expenseEngine = MockExpenseEngine();
    engine = RecurringEngine(repository, expenseEngine);
  });

  group('processDueTransactions', () {
    test('does nothing when no due transactions', () async {
      when(() => repository.getDueTransactions(any())).thenAnswer((_) async => []);

      await engine.processDueTransactions();

      verifyNever(() => expenseEngine.addTransaction(
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        type: any(named: 'type'),
        note: any(named: 'note'),
      ));
      verifyNever(() => repository.updateRecurringTransaction(any()));
    });

    test('processes single due item correctly (daily)', () async {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(hours: 12));
      final recurring = RecurringTransaction(
        id: '1',
        amount: const Amount(100),
        categoryId: 'cat1',
        type: TransactionType.expense,
        frequency: RecurringFrequency.daily,
        nextDate: pastDate,
      );

      when(() => repository.getDueTransactions(any()))
          .thenAnswer((_) async => [recurring]);
      
      when(() => expenseEngine.addTransaction(
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        type: any(named: 'type'),
        note: any(named: 'note'),
      )).thenAnswer((_) async => Transaction(
        id: 'tx1',
        amount: const Amount(100),
        date: pastDate,
        categoryId: 'cat1',
        type: TransactionType.expense,
      ));

      when(() => repository.updateRecurringTransaction(any()))
          .thenAnswer((_) async => true);

      await engine.processDueTransactions();

      verify(() => expenseEngine.addTransaction(
        amount: 100.0,
        date: pastDate,
        categoryId: 'cat1',
        type: TransactionType.expense,
        note: null,
      )).called(1);

      final captured = verify(() => repository.updateRecurringTransaction(captureAny())).captured.first as RecurringTransaction;
      
      expect(captured.nextDate.isAfter(now), isTrue);
    });

    test('processes multiple due items correctly', () async {
      final now = DateTime.now();
      final pastDate1 = now.subtract(const Duration(days: 10)); // Over 1 week
      final pastDate2 = now.subtract(const Duration(days: 40)); // Over 1 month

      final recurring1 = RecurringTransaction(
        id: '1',
        amount: const Amount(100),
        categoryId: 'cat1',
        type: TransactionType.expense,
        frequency: RecurringFrequency.weekly,
        nextDate: pastDate1,
      );

      final recurring2 = RecurringTransaction(
        id: '2',
        amount: const Amount(200),
        categoryId: 'cat2',
        type: TransactionType.expense,
        frequency: RecurringFrequency.monthly,
        nextDate: pastDate2,
      );

      when(() => repository.getDueTransactions(any()))
          .thenAnswer((_) async => [recurring1, recurring2]);
      
      when(() => expenseEngine.addTransaction(
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        type: any(named: 'type'),
        note: any(named: 'note'),
      )).thenAnswer((_) async => Transaction(
        id: 'tx1',
        amount: const Amount(100),
        date: pastDate1,
        categoryId: 'cat1',
        type: TransactionType.expense,
      ));

      when(() => repository.updateRecurringTransaction(any()))
          .thenAnswer((_) async => true);

      await engine.processDueTransactions();

      verify(() => expenseEngine.addTransaction(
        amount: 100.0,
        date: pastDate1,
        categoryId: 'cat1',
        type: TransactionType.expense,
        note: null,
      )).called(1);

      verify(() => expenseEngine.addTransaction(
        amount: 200.0,
        date: pastDate2,
        categoryId: 'cat2',
        type: TransactionType.expense,
        note: null,
      )).called(1);

      final captures = verify(() => repository.updateRecurringTransaction(captureAny())).captured;
      expect(captures.length, 2);
      
      final cap1 = captures[0] as RecurringTransaction;
      final cap2 = captures[1] as RecurringTransaction;

      expect(cap1.nextDate.isAfter(now), isTrue);
      expect(cap2.nextDate.isAfter(now), isTrue);
    });
  });
}
