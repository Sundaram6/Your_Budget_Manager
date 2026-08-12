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
        amount: const Amount(1000),
        date: DateTime.now(),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      ),
    );
    registerFallbackValue(PaymentMethod.cash);
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
    test('expense without category selection auto-defaults to cat_uncategorized and succeeds with default paymentMethod', () async {
      final dummyTx = Transaction(
        id: 'exp-uncat-1',
        amount: const Amount(10000),
        date: DateTime.now(),
        categoryId: CategoryEngine.catUncategorized,
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.cash,
      );

      when(() => mockExpenseEngine.addTransaction(
            amount: 10000,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catUncategorized,
            type: TransactionType.expense,
            note: any(named: 'note'),
            sourceApp: 'manual',
            paymentMethod: any(named: 'paymentMethod'),
          )).thenAnswer((_) async => dummyTx);

      final controller = container.read(addTransactionControllerProvider.notifier);
      controller.setAmount(10000);
      controller.setType(TransactionType.expense);

      final success = await controller.saveTransaction();

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 10000,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catUncategorized,
            type: TransactionType.expense,
            note: any(named: 'note'),
            sourceApp: 'manual',
            paymentMethod: PaymentMethod.cash,
          )).called(1);
    });

    test('income defaults category to cat_income', () async {
      final dummyTx = Transaction(
        id: 'inc-1',
        amount: const Amount(500000),
        date: DateTime.now(),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      when(() => mockExpenseEngine.addTransaction(
            amount: 500000,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catIncome,
            type: TransactionType.income,
            note: any(named: 'note'),
            sourceApp: 'manual',
            paymentMethod: any(named: 'paymentMethod'),
          )).thenAnswer((_) async => dummyTx);

      final controller = container.read(addTransactionControllerProvider.notifier);
      controller.setAmount(500000);
      controller.setType(TransactionType.income);

      final success = await controller.saveTransaction();

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 500000,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catIncome,
            type: TransactionType.income,
            note: any(named: 'note'),
            sourceApp: 'manual',
            paymentMethod: PaymentMethod.cash,
          )).called(1);
    });

    test('expense with category and custom payment method (UPI) selected succeeds', () async {
      final dummyTx = Transaction(
        id: 'exp-1',
        amount: const Amount(25000),
        date: DateTime.now(),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        paymentMethod: PaymentMethod.upi,
      );

      when(() => mockExpenseEngine.addTransaction(
            amount: 25000,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: any(named: 'note'),
            sourceApp: 'manual',
            paymentMethod: PaymentMethod.upi,
          )).thenAnswer((_) async => dummyTx);

      final controller = container.read(addTransactionControllerProvider.notifier);
      controller.setAmount(25000);
      controller.setType(TransactionType.expense);
      controller.setCategory(CategoryEngine.catFood);
      controller.setPaymentMethod(PaymentMethod.upi);

      final success = await controller.saveTransaction();

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 25000,
            date: any(named: 'date'),
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: any(named: 'note'),
            sourceApp: 'manual',
            paymentMethod: PaymentMethod.upi,
          )).called(1);
    });
  });
}
