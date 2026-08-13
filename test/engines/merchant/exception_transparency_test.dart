import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/merchant/merchant_engine.dart';
import 'package:your_budget_manager/engines/sms/models/parsed_transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

class MockExpenseEngine extends Mock implements ExpenseEngine {}

void main() {
  late MockExpenseEngine mockExpenseEngine;
  late MerchantEngine merchantEngine;

  setUpAll(() {
    registerFallbackValue(TransactionType.expense);
    registerFallbackValue(PaymentMethod.unknown);
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockExpenseEngine = MockExpenseEngine();
    merchantEngine = MerchantEngine(SmsQuery(), Logger(), mockExpenseEngine);
  });

  group('Exception Transparency Tests', () {
    test('confirmPendingTransaction throws exception when ExpenseEngine.addTransaction fails (e.g. Foreign Key SqliteException)', () async {
      final tx = ParsedTransaction(
        smsId: 'test-sms-1',
        amount: 50000,
        date: DateTime.now(),
        merchantName: 'Zepto',
        merchantId: 'mer_zepto',
        categoryId: 'cat_invalid_foreign_key',
        originalSmsBody: 'Paid 500',
        sourceApp: 'sms:unknown',
      );

      when(() => mockExpenseEngine.addTransaction(
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        type: any(named: 'type'),
        note: any(named: 'note'),
        sourceApp: any(named: 'sourceApp'),
        paymentMethod: any(named: 'paymentMethod'),
        cardLast4: any(named: 'cardLast4'),
        merchantName: any(named: 'merchantName'),
        recurrenceOccurrenceKey: any(named: 'recurrenceOccurrenceKey'),
        sourceMessageId: any(named: 'sourceMessageId'),
      )).thenThrow(const FormatException('SqliteException(787): FOREIGN KEY constraint failed'));

      expect(
        () => merchantEngine.confirmPendingTransaction(transaction: tx),
        throwsA(isA<FormatException>()),
      );
    });

    test('confirmPendingTransaction throws StateError when post-write DB read-back verification fails', () async {
      final tx = ParsedTransaction(
        smsId: 'test-sms-2',
        amount: 25000,
        date: DateTime.now(),
        merchantName: 'Dmart',
        merchantId: 'mer_dmart',
        categoryId: 'cat_groceries',
        originalSmsBody: 'Paid 250',
        sourceApp: 'sms:dmart',
      );

      final dummySaved = Transaction(
        id: 'saved-id-999',
        amount: const Amount(25000),
        date: DateTime.now(),
        categoryId: 'cat_groceries',
        type: TransactionType.expense,
        sourceApp: 'sms:dmart',
      );

      when(() => mockExpenseEngine.addTransaction(
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        categoryId: any(named: 'categoryId'),
        type: any(named: 'type'),
        note: any(named: 'note'),
        sourceApp: any(named: 'sourceApp'),
        paymentMethod: any(named: 'paymentMethod'),
        cardLast4: any(named: 'cardLast4'),
        merchantName: any(named: 'merchantName'),
        recurrenceOccurrenceKey: any(named: 'recurrenceOccurrenceKey'),
        sourceMessageId: any(named: 'sourceMessageId'),
      )).thenAnswer((_) async => dummySaved);

      // Simulate post-write read-back returning null (row missing in DB)
      when(() => mockExpenseEngine.getTransactionById('saved-id-999')).thenAnswer((_) async => null);

      expect(
        () => merchantEngine.confirmPendingTransaction(transaction: tx),
        throwsA(isA<StateError>()),
      );
    });
  });
}
