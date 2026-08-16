import 'package:drift/native.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/engines/analytics/analytics_engine.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/merchant/merchant_engine.dart';
import 'package:your_budget_manager/engines/sms/models/parsed_transaction.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';

class MockSmsQuery extends Mock implements SmsQuery {}
class MockLogger extends Mock implements Logger {}

SmsMessage makeSms(String body, {String address = 'VM-BANK', int id = 1, DateTime? date}) {
  return SmsMessage.fromJson({
    '_id': id,
    'address': address,
    'body': body,
    'date': (date ?? DateTime(2026, 8, 15, 14, 30)).millisecondsSinceEpoch,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CategoryDao categoryDao;
  late TransactionDao transactionDao;
  late CategoryRepositoryImpl categoryRepo;
  late TransactionRepositoryImpl transactionRepo;
  late CategoryEngine categoryEngine;
  late ExpenseEngine expenseEngine;
  late AnalyticsEngine analyticsEngine;
  late MerchantEngine merchantEngine;
  late MockSmsQuery mockSmsQuery;
  late MockLogger mockLogger;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);

    categoryDao = CategoryDao(db);
    transactionDao = TransactionDao(db);
    categoryRepo = CategoryRepositoryImpl(categoryDao);
    transactionRepo = TransactionRepositoryImpl(transactionDao);
    categoryEngine = CategoryEngine(categoryRepo);
    await categoryEngine.seedDefaults();

    expenseEngine = ExpenseEngine(transactionRepo);
    analyticsEngine = AnalyticsEngine(transactionRepo, categoryRepo);

    mockSmsQuery = MockSmsQuery();
    mockLogger = MockLogger();
    merchantEngine = MerchantEngine(mockSmsQuery, mockLogger, expenseEngine);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 22: Credit Transaction Tracking & Extraction Tests', () {
    test('HDFC Bank credit SMS is parsed with type: income, accountLast4, transactionRef', () {
      final sms = makeSms(
        'A/c *1234 credited with Rs 5,000.00 on 15-Aug-2026 by UPI. UPI Ref: 423512345678. Bal: Rs 45,000.',
        address: 'VK-HDFCBK',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(500000)); // 5000 * 100 paise
      expect(parsed.accountLast4, equals('1234'));
      expect(parsed.cardLast4, isNull);
      expect(parsed.transactionRef, equals('423512345678'));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('ICICI Bank credit SMS is parsed with type: income, accountLast4, transactionRef', () {
      final sms = makeSms(
        'Dear Customer, your A/c ending in 5678 has been credited with INR 2,500.00 on 15-Aug-2026. Ref no: 987654321. Avail Bal: INR 12,000.',
        address: 'AD-ICICIB',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(250000));
      expect(parsed.accountLast4, equals('5678'));
      expect(parsed.cardLast4, isNull);
      expect(parsed.transactionRef, equals('987654321'));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('SBI Bank credit SMS with UPI/CR format is parsed correctly', () {
      final sms = makeSms(
        'Your A/c XX9012 is credited by Rs 10,000 on 15-Aug-2026 (UPI/CR/423512345678/John Doe). Bal: Rs 25,000.',
        address: 'JM-SBIINB',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(1000000));
      expect(parsed.accountLast4, equals('9012'));
      expect(parsed.cardLast4, isNull);
      expect(parsed.transactionRef, equals('423512345678'));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('Axis Bank NEFT credit SMS extracts NEFT UTR and accountLast4', () {
      final sms = makeSms(
        'Axis Bank: A/c no. 3456 credited with INR 1,200.50 on 15-Aug-2026 via NEFT. UTR: AXIS00098765. Avail Bal: INR 8,000.',
        address: 'BP-AXISBK',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(120050));
      expect(parsed.accountLast4, equals('3456'));
      expect(parsed.transactionRef, equals('AXIS00098765'));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('Google Pay received payment SMS is parsed as type: income', () {
      final sms = makeSms(
        'Received Rs. 750 from Rahul Sharma on Google Pay. UPI Ref: 1122334455',
        address: 'GPAY',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(75000));
      expect(parsed.transactionRef, equals('1122334455'));
      expect(parsed.merchantName, contains('Rahul Sharma'));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('PhonePe received money SMS is parsed as type: income', () {
      final sms = makeSms(
        'You received Rs 350 from Priya via PhonePe. Txn ID: T240815123456',
        address: 'PHONEPE',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(35000));
      expect(parsed.transactionRef, equals('T240815123456'));
      expect(parsed.merchantName, contains('Priya'));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('Paytm wallet cashback SMS is parsed as type: income', () {
      final sms = makeSms(
        'Rs 150 credited to your Paytm wallet - cashback received for order',
        address: 'PAYTM',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(15000));
      expect(parsed.categoryId, equals(CategoryEngine.catIncome));
    });

    test('Card refund SMS is parsed as type: income', () {
      final sms = makeSms(
        'Refund of Rs. 499.00 on Credit Card ending 4521 from Swiggy has been credited.',
        address: 'HDFCBK',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(49900));
      expect(parsed.cardLast4, equals('4521'));
      expect(parsed.paymentMethod, equals(PaymentMethod.credit_card));
    });
  });

  group('Phase 22: Regression & Distinct Extractor Separation Tests', () {
    test('Debit SMS parsing remains fully functional with type: expense', () {
      final sms = makeSms(
        'Rs. 450.00 debited from A/c *1234 on 15-Aug-2026 on Debit Card ending 8899 for Swiggy order. UPI Ref: 9988776655.',
        address: 'HDFCBK',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.expense));
      expect(parsed.amount, equals(45000));
      expect(parsed.merchantName, equals('Swiggy'));
      expect(parsed.categoryId, equals(CategoryEngine.catFood));
      expect(parsed.cardLast4, equals('8899'));
      expect(parsed.accountLast4, equals('1234'));
      expect(parsed.transactionRef, equals('9988776655'));
    });

    test('accountLast4 and cardLast4 extractors do not collide on card-only SMS', () {
      final sms = makeSms(
        'Paid Rs. 1,200 on Credit Card ending 9944 at Amazon India.',
        address: 'SBICARD',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.cardLast4, equals('9944'));
      expect(parsed.accountLast4, isNull, reason: 'Card ending must not be falsely parsed as bank account');
    });

    test('accountLast4 and cardLast4 extractors do not collide on account-only SMS', () {
      final sms = makeSms(
        'Your A/c *7711 was debited by Rs. 300 for UPI txn to Blinkit. UPI Ref: 334455.',
        address: 'ICICIB',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);
      expect(parsed!.accountLast4, equals('7711'));
      expect(parsed.cardLast4, isNull, reason: 'A/c *7711 must not be falsely parsed as cardLast4');
    });
  });

  group('Phase 22: End-to-End DB Storage, Deduplication & Analytics Integration', () {
    test('Confirmed credit transaction saves to DB with type: income, accountLast4, and transactionRef', () async {
      final sms = makeSms(
        'A/c *4455 credited with Rs 25,000 on 15-Aug-2026. Ref: SALARYAUG26.',
        address: 'HDFCBK',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);

      final success = await merchantEngine.confirmPendingTransaction(transaction: parsed!);
      expect(success, isTrue);

      final txs = await transactionDao.watchAllTransactions().first;
      expect(txs.length, equals(1));
      final dbTx = txs.first;
      expect(dbTx.type, equals('income'));
      expect(dbTx.amount, equals(2500000));
      expect(dbTx.accountLast4, equals('4455'));
      expect(dbTx.transactionRef, equals('SALARYAUG26'));
      expect(dbTx.sourceMessageId, equals(parsed.smsId));
    });

    test('Deduplication prevents re-inserting the same credit SMS', () async {
      final sms = makeSms(
        'A/c *4455 credited with Rs 500 on 15-Aug-2026. Ref: REF112233.',
        address: 'HDFCBK',
      );

      final parsed = merchantEngine.parseSingleSms(sms);
      expect(parsed, isNotNull);

      // First confirmation
      final firstSave = await merchantEngine.confirmPendingTransaction(transaction: parsed!);
      expect(firstSave, isTrue);

      // Check duplicate check
      final isDup = await DatabaseHelper.instance.checkDuplicateTransaction(
        amountValue: parsed.amount,
        date: parsed.date,
        snippet: parsed.merchantName,
        sourceMessageId: parsed.smsId,
      );
      expect(isDup, isTrue, reason: 'checkDuplicateTransaction must identify identical sourceMessageId for credit');
    });

    test('Monthly analytics correctly computes totalIncome and leaves totalExpense unaffected', () async {
      // 1. Add an expense (Swiggy Rs 500)
      final expenseSms = makeSms(
        'Paid Rs. 500 at Swiggy on Debit Card ending 1234.',
        id: 101,
        address: 'HDFCBK',
        date: DateTime(2026, 8, 10),
      );
      final parsedExpense = merchantEngine.parseSingleSms(expenseSms)!;
      await merchantEngine.confirmPendingTransaction(transaction: parsedExpense);

      // 2. Add an income (Salary Rs 50,000)
      final creditSms = makeSms(
        'A/c *1234 credited with Rs 50,000 on 10-Aug-2026. Ref: SALARY.',
        id: 102,
        address: 'HDFCBK',
        date: DateTime(2026, 8, 10),
      );
      final parsedCredit = merchantEngine.parseSingleSms(creditSms)!;
      await merchantEngine.confirmPendingTransaction(transaction: parsedCredit);

      // 3. Verify Analytics calculations
      final totalExpense = await analyticsEngine.getMonthlyTotal(2026, 8);
      final totalIncome = await analyticsEngine.getMonthlyIncome(2026, 8);

      expect(totalExpense, equals(50000)); // Rs 500
      expect(totalIncome, equals(5000000)); // Rs 50,000
    });
  });
}
