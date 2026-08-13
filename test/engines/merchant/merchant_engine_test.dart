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
    registerFallbackValue(PaymentMethod.unknown);
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
      amount: 49900,
      date: DateTime(2026, 8, 1),
      merchantName: 'Swiggy',
      merchantId: 'mer_swiggy',
      categoryId: CategoryEngine.catFood,
      originalSmsBody: 'Rs. 499 debited on Debit Card ending 4521 for Swiggy order',
      sourceApp: 'sms:swiggy',
      paymentMethod: PaymentMethod.debit_card,
      cardLast4: '4521',
    );

    final savedTx = Transaction(
      id: 'saved-tx-123',
      amount: const Amount(49900),
      date: DateTime(2026, 8, 1),
      categoryId: CategoryEngine.catFood,
      type: TransactionType.expense,
      note: 'Auto-tracked: Swiggy',
      sourceApp: 'sms:swiggy',
      paymentMethod: PaymentMethod.debit_card,
      cardLast4: '4521',
    );

    test('returns true on verified DB write and read-back match with paymentMethod and cardLast4', () async {
      when(() => mockExpenseEngine.addTransaction(
            amount: 49900,
            date: parsedTx.date,
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: 'Auto-tracked: Swiggy',
            sourceApp: 'sms:swiggy',
            paymentMethod: PaymentMethod.debit_card,
            cardLast4: '4521',
            merchantName: 'Swiggy',
          )).thenAnswer((_) async => savedTx);

      when(() => mockExpenseEngine.getTransactionById('saved-tx-123')).thenAnswer((_) async => savedTx);

      final success = await merchantEngine.confirmPendingTransaction(
        transaction: parsedTx,
        categoryId: CategoryEngine.catFood,
      );

      expect(success, isTrue);
      verify(() => mockExpenseEngine.addTransaction(
            amount: 49900,
            date: parsedTx.date,
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: 'Auto-tracked: Swiggy',
            sourceApp: 'sms:swiggy',
            paymentMethod: PaymentMethod.debit_card,
            cardLast4: '4521',
            merchantName: 'Swiggy',
          )).called(1);
      verify(() => mockExpenseEngine.getTransactionById('saved-tx-123')).called(1);
    });

    test('throws StateError when post-write read-back verification fails (row not found)', () async {
      when(() => mockExpenseEngine.addTransaction(
            amount: 49900,
            date: parsedTx.date,
            categoryId: CategoryEngine.catFood,
            type: TransactionType.expense,
            note: 'Auto-tracked: Swiggy',
            sourceApp: 'sms:swiggy',
            paymentMethod: any(named: 'paymentMethod'),
            cardLast4: any(named: 'cardLast4'),
            merchantName: any(named: 'merchantName'),
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
            sourceApp: any(named: 'sourceApp'),
            paymentMethod: any(named: 'paymentMethod'),
            cardLast4: any(named: 'cardLast4'),
            merchantName: any(named: 'merchantName'),
          )).thenThrow(Exception('Database insertion error'));

      expect(
        () => merchantEngine.confirmPendingTransaction(transaction: parsedTx),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MerchantEngine - Structured Payment Evidence Extraction', () {
    test('extracts UPI payment method from UPI Ref No', () {
      final msg = SmsMessage.fromJson({
        'id': 101,
        'body': 'Rs. 450.00 debited from A/c XX1234 on 12-Aug-26 via UPI Ref No 987654321 to Swiggy',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 45000);
      expect(parsed.paymentMethod, PaymentMethod.upi);
      expect(parsed.cardLast4, isNull);
      expect(parsed.sourceApp, 'sms:swiggy'); // sourceApp untouched
    });

    test('extracts UPI payment method from UPI/VPA pattern', () {
      final msg = SmsMessage.fromJson({
        'id': 102,
        'body': 'Paid Rs 250 to VPA merchant@okhdfcbank UPI/43219876/Order Ref 112233',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.paymentMethod, PaymentMethod.upi);
      expect(parsed.cardLast4, isNull);
    });

    test('extracts Debit Card and last-4 from HDFC Bank SMS', () {
      final msg = SmsMessage.fromJson({
        'id': 103,
        'body': 'HDFC Bank: Rs 1,250.00 debited from a/c using Debit Card ending 4521 at POS 9988',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 125000);
      expect(parsed.paymentMethod, PaymentMethod.debit_card);
      expect(parsed.cardLast4, '4521');
      expect(parsed.sourceApp, 'sms:hdfc');
    });

    test('extracts Credit Card and last-4 from ICICI Bank SMS', () {
      final msg = SmsMessage.fromJson({
        'id': 104,
        'body': 'INR 2,499.00 spent on ICICI Bank Credit Card no. XX8899 on 10-Aug-26 at Amazon',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 249900);
      expect(parsed.paymentMethod, PaymentMethod.credit_card);
      expect(parsed.cardLast4, '8899');
      expect(parsed.sourceApp, 'sms:amazon');
    });

    test('extracts Credit Card and last-4 from SBI Card SMS', () {
      final msg = SmsMessage.fromJson({
        'id': 105,
        'body': 'Spent Rs. 890.00 on SBI Credit Card ending 3344 at Blinkit',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 89000);
      expect(parsed.paymentMethod, PaymentMethod.credit_card);
      expect(parsed.cardLast4, '3344');
      expect(parsed.sourceApp, 'sms:blinkit');
    });

    test('extracts Debit Card and last-4 from Axis Bank SMS', () {
      final msg = SmsMessage.fromJson({
        'id': 106,
        'body': 'Axis Bank: INR 350 debited for transaction on Debit Card XX6712',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 35000);
      expect(parsed.paymentMethod, PaymentMethod.debit_card);
      expect(parsed.cardLast4, '6712');
      expect(parsed.sourceApp, 'sms:axis');
    });

    test('resolves to unknown paymentMethod when no structured payment evidence exists (A/c only)', () {
      final msg = SmsMessage.fromJson({
        'id': 107,
        'body': 'Dear Customer, your A/c XX9012 is debited for INR 1,500.00 on 11-Aug-26 towards Electricity Bill. Avl Bal INR 12,000.',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 150000);
      // Critical check: Must NOT guess UPI or Card just because it's a bank/utility SMS
      expect(parsed.paymentMethod, PaymentMethod.unknown);
      expect(parsed.cardLast4, isNull);
    });

    test('resolves to unknown paymentMethod when merchant SMS lacks payment instrument evidence', () {
      final msg = SmsMessage.fromJson({
        'id': 108,
        'body': 'Rs 299.00 debited from Bank A/c for order at Zepto. Thank you for shopping!',
        'date': 1786500000000,
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.amount, 29900);
      expect(parsed.merchantName, 'Zepto');
      expect(parsed.sourceApp, 'sms:zepto');
      // Critical check: Do NOT guess payment method from merchant
      expect(parsed.paymentMethod, PaymentMethod.unknown);
      expect(parsed.cardLast4, isNull);
    });

    test('handles duplicate-format edge cases across major bank templates', () {
      // HDFC duplicate format: "debited by Rs ... on Debit Card ending" vs "debited for INR ... via UPI"
      final hdfcDebit = merchantEngine.extractPaymentEvidence('HDFC Bank: Rs 500 debited from A/c XX1234 on Debit Card ending 1122');
      expect(hdfcDebit.method, PaymentMethod.debit_card);
      expect(hdfcDebit.cardLast4, '1122');

      final hdfcUpi = merchantEngine.extractPaymentEvidence('HDFC Bank: Rs 500 debited from A/c XX1234 via UPI: 123456');
      expect(hdfcUpi.method, PaymentMethod.upi);
      expect(hdfcUpi.cardLast4, isNull);

      final iciciCredit = merchantEngine.extractPaymentEvidence('ICICI Bank Credit Card XX9988 used for INR 750');
      expect(iciciCredit.method, PaymentMethod.credit_card);
      expect(iciciCredit.cardLast4, '9988');

      final sbiUnknown = merchantEngine.extractPaymentEvidence('Your A/c 12345678901 debited by Rs. 200.00 on 12-Aug-26. Ref No 001122');
      expect(sbiUnknown.method, PaymentMethod.unknown);
      expect(sbiUnknown.cardLast4, isNull);
    });
  });
}
