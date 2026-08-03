import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/merchant/merchant_engine.dart';
import 'package:your_budget_manager/engines/sms/models/parsed_transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

class MockSmsQuery extends Mock implements SmsQuery {}

class MockExpenseEngine extends Mock implements ExpenseEngine {}

class MockLogger extends Mock implements Logger {}

void main() {
  late MockSmsQuery mockSmsQuery;
  late MockExpenseEngine mockExpenseEngine;
  late MockLogger mockLogger;
  late MerchantEngine merchantEngine;

  setUpAll(() {
    registerFallbackValue(TransactionType.expense);
  });

  setUp(() {
    mockSmsQuery = MockSmsQuery();
    mockExpenseEngine = MockExpenseEngine();
    mockLogger = MockLogger();
    merchantEngine = MerchantEngine(mockSmsQuery, mockLogger, mockExpenseEngine);
  });

  group('MerchantEngine - confirmPendingTransaction', () {
    final parsedTx = ParsedTransaction(
      smsId: 'sms-123',
      amount: 499.0,
      date: DateTime(2026, 8, 1),
      merchantName: 'Swiggy',
      merchantId: 'mer_swiggy',
      categoryId: CategoryEngine.catFood,
      originalSmsBody: 'Rs. 499 debited for Swiggy order',
    );

    final savedTx = Transaction(
      id: 'saved-tx-123',
      amount: const Amount(499.0),
      date: DateTime(2026, 8, 1),
      categoryId: CategoryEngine.catFood,
      type: TransactionType.expense,
      note: 'Auto-tracked: Swiggy',
    );

    test('returns true on verified DB write and read-back match', () async {
      when(() => mockExpenseEngine.addTransaction(
            amount: 499.0,
            date: parsedTx.date,
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: 'Auto-tracked: Swiggy',
          )).thenAnswer((_) async => savedTx);

      when(() => mockExpenseEngine.getTransactionById('saved-tx-123')).thenAnswer((_) async => savedTx);

      final success = await merchantEngine.confirmPendingTransaction(
        transaction: parsedTx,
        categoryId: CategoryEngine.catFood,
      );

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 499.0,
            date: parsedTx.date,
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: 'Auto-tracked: Swiggy',
          )).called(1);
      verify(() => mockExpenseEngine.getTransactionById('saved-tx-123')).called(1);
    });

    test('throws StateError when post-write read-back verification fails (row not found)', () async {
      when(() => mockExpenseEngine.addTransaction(
            amount: 499.0,
            date: parsedTx.date,
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: 'Auto-tracked: Swiggy',
          )).thenAnswer((_) async => savedTx);

      when(() => mockExpenseEngine.getTransactionById('saved-tx-123')).thenAnswer((_) async => null);

      expect(
        () => merchantEngine.confirmPendingTransaction(
          transaction: parsedTx,
          categoryId: CategoryEngine.catFood,
        ),
        throwsA(isA<StateError>()),
      );
    });


    test('rethrows exception when addTransaction throws error', () async {
      when(() => mockExpenseEngine.addTransaction(
            amount: any(named: 'amount'),
            date: any(named: 'date'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            note: any(named: 'note'),
          )).thenThrow(Exception('Database insertion error'));

      expect(
        () => merchantEngine.confirmPendingTransaction(transaction: parsedTx),
        throwsA(isA<Exception>()),
      );
    });
  });
}
