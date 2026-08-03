import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine_provider.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/features/transactions/presentation/controllers/add_transaction_controller.dart';

class MockExpenseEngine extends Mock implements ExpenseEngine {}

void main() {
  late MockExpenseEngine mockExpenseEngine;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      Transaction(
        id: '1',
        amount: const Amount(10),
        date: DateTime.now(),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      ),
    );
  });

  setUp(() {
    mockExpenseEngine = MockExpenseEngine();
    container = ProviderContainer(
      overrides: [
        expenseEngineProvider.overrideWithValue(mockExpenseEngine),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AddTransactionController', () {
    test('expense without category selection auto-defaults to cat_uncategorized and succeeds', () async {
      final dummyTx = Transaction(
        id: 'exp-uncat-1',
        amount: const Amount(100.0),
        date: DateTime.now(),
        categoryId: CategoryEngine.catUncategorized,
        type: TransactionType.expense,
      );

      when(() => mockExpenseEngine.addTransaction(
            amount: 100.0,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catUncategorized,
            type: TransactionType.expense,
            note: any(named: 'note'),
          )).thenAnswer((_) async => dummyTx);

      final controller = container.read(addTransactionControllerProvider.notifier);
      controller.setAmount(100.0);
      controller.setType(TransactionType.expense);

      final success = await controller.saveTransaction();

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 100.0,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catUncategorized,
            type: TransactionType.expense,
            note: any(named: 'note'),
          )).called(1);
    });


    test('income defaults category to cat_income', () async {
      final dummyTx = Transaction(
        id: 'inc-1',
        amount: const Amount(5000.0),
        date: DateTime.now(),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      when(() => mockExpenseEngine.addTransaction(
            amount: 5000.0,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catIncome,
            type: TransactionType.income,
            note: any(named: 'note'),
          )).thenAnswer((_) async => dummyTx);

      final controller = container.read(addTransactionControllerProvider.notifier);
      controller.setAmount(5000.0);
      controller.setType(TransactionType.income);

      final success = await controller.saveTransaction();

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 5000.0,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catIncome,
            type: TransactionType.income,
            note: any(named: 'note'),
          )).called(1);
    });

    test('expense with category selected succeeds', () async {
      final dummyTx = Transaction(
        id: 'exp-1',
        amount: const Amount(250.0),
        date: DateTime.now(),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      when(() => mockExpenseEngine.addTransaction(
            amount: 250.0,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: any(named: 'note'),
          )).thenAnswer((_) async => dummyTx);

      final controller = container.read(addTransactionControllerProvider.notifier);
      controller.setAmount(250.0);
      controller.setType(TransactionType.expense);
      controller.setCategory(CategoryEngine.catFood);

      final success = await controller.saveTransaction();

      expect(success, isTrue);
    });
  });
}
