import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/core/errors/app_exception.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockUuid extends Mock implements Uuid {}

void main() {
  late MockTransactionRepository repository;
  late MockUuid mockUuid;
  late ExpenseEngine engine;

  setUpAll(() {
    registerFallbackValue(
      Transaction(
        id: '1',
        amount: const Amount(1000),
        date: DateTime.now(),
        categoryId: 'cat1',
        type: TransactionType.expense,
      ),
    );
  });

  setUp(() {
    repository = MockTransactionRepository();
    mockUuid = MockUuid();
    engine = ExpenseEngine(repository, uuid: mockUuid);
  });

  group('ExpenseEngine', () {
    test('addTransaction throws AppException if amount <= 0', () async {
      expect(
        () => engine.addTransaction(
          amount: 0,
          date: DateTime.now(),
          categoryId: 'cat1',
          type: TransactionType.expense,
        ),
        throwsA(isA<AppException>()),
      );
      
      expect(
        () => engine.addTransaction(
          amount: -500,
          date: DateTime.now(),
          categoryId: 'cat1',
          type: TransactionType.expense,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('addTransaction creates transaction with generated UUID and calls insertTransaction', () async {
      const generatedUuid = 'generated-uuid';
      when(() => mockUuid.v4()).thenReturn(generatedUuid);
      when(() => repository.insertTransaction(any())).thenAnswer((_) async => 1);

      final date = DateTime.now();
      final result = await engine.addTransaction(
        amount: 10000,
        date: date,
        categoryId: 'cat1',
        type: TransactionType.expense,
      );

      expect(result.id, generatedUuid);
      expect(result.amount.value, 10000);
      expect(result.date, date);
      expect(result.categoryId, 'cat1');
      expect(result.type, TransactionType.expense);

      verify(() => repository.insertTransaction(result)).called(1);
    });

    test('updateTransaction throws AppException if amount <= 0', () async {
      final transaction = Transaction(
        id: '1',
        amount: const Amount(0),
        date: DateTime.now(),
        categoryId: 'cat1',
        type: TransactionType.expense,
      );
      
      expect(
        () => engine.updateTransaction(transaction),
        throwsA(isA<AppException>()),
      );
    });

    test('updateTransaction delegates to repository', () async {
      final transaction = Transaction(
        id: '1',
        amount: const Amount(1000),
        date: DateTime.now(),
        categoryId: 'cat1',
        type: TransactionType.expense,
      );
      
      when(() => repository.updateTransaction(transaction)).thenAnswer((_) async => true);
      
      final result = await engine.updateTransaction(transaction);
      expect(result, true);
      verify(() => repository.updateTransaction(transaction)).called(1);
    });

    test('deleteTransaction delegates to repository', () async {
      final transaction = Transaction(
        id: '1',
        amount: const Amount(1000),
        date: DateTime.now(),
        categoryId: 'cat1',
        type: TransactionType.expense,
      );
      
      when(() => repository.deleteTransaction(transaction)).thenAnswer((_) async => 1);
      
      final result = await engine.deleteTransaction(transaction);
      expect(result, 1);
      verify(() => repository.deleteTransaction(transaction)).called(1);
    });

    test('getTransactionById returns matching transaction', () async {
      final transaction = Transaction(
        id: 'target-id',
        amount: const Amount(1000),
        date: DateTime.now(),
        categoryId: 'cat1',
        type: TransactionType.expense,
      );
      
      when(() => repository.watchAllTransactions()).thenAnswer(
        (_) => Stream.value([
          Transaction(
            id: 'other-id',
            amount: const Amount(500),
            date: DateTime.now(),
            categoryId: 'cat2',
            type: TransactionType.income,
          ),
          transaction,
        ]),
      );
      
      final result = await engine.getTransactionById('target-id');
      expect(result, transaction);
    });

    test('watchTransactionsByMonth calls repository with correct date range', () {
      final month = DateTime(2023, 10, 15);
      final expectedStart = DateTime(2023, 10, 1);
      final expectedEnd = DateTime(2023, 11, 0, 23, 59, 59, 999);
      
      when(() => repository.watchTransactionsByDateRange(expectedStart, expectedEnd))
          .thenAnswer((_) => Stream.value([]));
          
      engine.watchTransactionsByMonth(month);
      
      verify(() => repository.watchTransactionsByDateRange(expectedStart, expectedEnd)).called(1);
    });

    test('getMonthlyTotal sums correctly with or without filtering in paise', () async {
      final month = DateTime(2023, 10, 15);
      final expectedStart = DateTime(2023, 10, 1);
      final expectedEnd = DateTime(2023, 11, 0, 23, 59, 59, 999);
      
      final transactions = [
        Transaction(id: '1', amount: const Amount(10000), date: month, categoryId: 'cat1', type: TransactionType.expense),
        Transaction(id: '2', amount: const Amount(5000), date: month, categoryId: 'cat2', type: TransactionType.income),
        Transaction(id: '3', amount: const Amount(20000), date: month, categoryId: 'cat3', type: TransactionType.expense),
      ];
      
      when(() => repository.watchTransactionsByDateRange(expectedStart, expectedEnd))
          .thenAnswer((_) => Stream.value(transactions));
          
      final totalUnfiltered = await engine.getMonthlyTotal(month);
      expect(totalUnfiltered, 35000);
      
      final totalExpense = await engine.getMonthlyTotal(month, type: TransactionType.expense);
      expect(totalExpense, 30000);
      
      final totalIncome = await engine.getMonthlyTotal(month, type: TransactionType.income);
      expect(totalIncome, 5000);
    });
  });
}
