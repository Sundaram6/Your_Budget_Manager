import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/merchant/merchant_engine.dart';
import 'package:your_budget_manager/engines/sms/sms_auto_tracker.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';

class MockSmsQuery extends Mock implements SmsQuery {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TransactionRepositoryImpl repository;
  late ExpenseEngine expenseEngine;
  late MerchantEngine merchantEngine;
  late MockSmsQuery mockSmsQuery;

  setUpAll(() {
    registerFallbackValue(TransactionType.expense);
    registerFallbackValue(PaymentMethod.unknown);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return 1; // PermissionStatus.granted (index 1)
        }
        if (methodCall.method == 'requestPermissions') {
          return {0: 1}; // Granted
        }
        return null;
      },
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);
    repository = TransactionRepositoryImpl(db.transactionDao);
    expenseEngine = ExpenseEngine(repository);
    mockSmsQuery = MockSmsQuery();
    merchantEngine = MerchantEngine(mockSmsQuery, Logger(), expenseEngine);

    // Seed default categories
    for (final cat in [
      CategoryEngine.catGroceries,
      CategoryEngine.catShopping,
      CategoryEngine.catFood,
      CategoryEngine.catTransport,
      CategoryEngine.catUtilities,
      CategoryEngine.catEntertainment,
      CategoryEngine.catIncome,
      CategoryEngine.catUncategorized,
    ]) {
      await db.into(db.categoriesTable).insert(
            Category(
              id: cat,
              name: cat,
              icon: 'category',
              color: '#000000',
              isDefault: true,
              sortOrder: 0,
              createdAt: 1000,
              updatedAt: 1000,
            ),
            mode: drift.InsertMode.insertOrIgnore,
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 8: SMS Capture Idempotency - Deterministic Source Identity', () {
    test('generateDurableSmsId produces identical deterministic identity across calls and system times', () {
      final msg1 = SmsMessage.fromJson({
        '_id': 4521,
        'address': 'VK-HDFCBK',
        'date': 1785500000000,
        'body': 'Rs 450.00 debited from HDFC Bank A/C **1234 to Swiggy on 10-Aug-2026 via UPI. Ref 623456.',
      });

      final msg2 = SmsMessage.fromJson({
        '_id': 4521,
        'address': 'vk-hdfcbk', // Case normalization test
        'date': 1785500000000,
        'body': 'Rs 450.00 debited from HDFC Bank A/C **1234 to Swiggy on 10-Aug-2026 via UPI. Ref 623456.',
      });

      final id1 = MerchantEngine.generateDurableSmsId(msg1);
      final id2 = MerchantEngine.generateDurableSmsId(msg2);

      expect(id1, startsWith('sms_sha256_'));
      expect(id1, equals(id2), reason: 'Identical message attributes must yield identical deterministic SHA-256 identity');
    });

    test('generateDurableSmsId differentiates distinct messages with identical bodies but different IDs or timestamps', () {
      final msgA = SmsMessage.fromJson({
        '_id': 101,
        'address': 'VK-HDFCBK',
        'date': 1785500000000,
        'body': 'Rs 100.00 debited via UPI to Tea Stall.',
      });

      final msgB = SmsMessage.fromJson({
        '_id': 102,
        'address': 'VK-HDFCBK',
        'date': 1785500000000,
        'body': 'Rs 100.00 debited via UPI to Tea Stall.',
      });

      final idA = MerchantEngine.generateDurableSmsId(msgA);
      final idB = MerchantEngine.generateDurableSmsId(msgB);

      expect(idA, isNot(equals(idB)), reason: 'Distinct Android telephony IDs must yield distinct identities even with same body and date');
    });

    test('generateDurableSmsId handles null / missing properties safely without crashing', () {
      final emptyMsg = SmsMessage.fromJson({});
      final id = MerchantEngine.generateDurableSmsId(emptyMsg);

      expect(id, startsWith('sms_sha256_'));
      expect(id.length, greaterThan(20));
    });
  });

  group('Phase 8: SMS Capture Idempotency - Same SMS Processed Twice & DB Unique Constraint', () {
    test('Processing same SMS twice results in single saved transaction and zero duplicates', () async {
      final msg = SmsMessage.fromJson({
        '_id': 9001,
        'address': 'AD-ICICIB',
        'date': 1786000000000,
        'body': 'Dear Customer, INR 1,250.00 debited from ICICI Bank A/C XX4321 on 12-Aug-2026 to Uber. UPI Ref 998877.',
      });

      final parsed = merchantEngine.parseSingleSms(msg);
      expect(parsed, isNotNull);
      expect(parsed!.smsId, startsWith('sms_sha256_'));

      // 1. First confirmation
      final isDup1 = await DatabaseHelper.instance.checkDuplicateTransaction(
        amountValue: parsed.amount,
        date: parsed.date,
        snippet: parsed.merchantName,
        sourceMessageId: parsed.smsId,
      );
      expect(isDup1, isFalse);

      final success1 = await merchantEngine.confirmPendingTransaction(transaction: parsed);
      expect(success1, isTrue);

      final txCount1 = await (db.select(db.transactionsTable)
            ..where((t) => t.sourceMessageId.equals(parsed.smsId)))
          .get();
      expect(txCount1.length, equals(1));

      // 2. Second confirmation attempt (same SMS re-processed)
      final isDup2 = await DatabaseHelper.instance.checkDuplicateTransaction(
        amountValue: parsed.amount,
        date: parsed.date,
        snippet: parsed.merchantName,
        sourceMessageId: parsed.smsId,
      );
      expect(isDup2, isTrue, reason: 'Authoritative primary sourceMessageId check must return true immediately');

      // Total rows in DB remains exactly 1
      final allRows = await db.select(db.transactionsTable).get();
      expect(allRows.length, equals(1));
    });

    test('SQLite partial unique index rejects direct duplicate insert with same source_message_id', () async {
      const duplicateSourceId = 'sms_sha256_test_unique_key_123';

      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: 'tx_p8_1',
              amount: 50000,
              type: 'expense',
              categoryId: CategoryEngine.catFood,
              date: 1786000000000,
              sourceMessageId: const drift.Value(duplicateSourceId),
              createdAt: 1000,
              updatedAt: 1000,
            ),
          );

      // Second direct insert with the same non-null sourceMessageId must fail unique constraint
      expect(
        () => db.into(db.transactionsTable).insert(
              TransactionsTableCompanion.insert(
                id: 'tx_p8_2',
                amount: 50000,
                type: 'expense',
                categoryId: CategoryEngine.catFood,
                date: 1786000000000,
                sourceMessageId: const drift.Value(duplicateSourceId),
                createdAt: 1000,
                updatedAt: 1000,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );

      // Multiple NULL source_message_id rows are allowed by the partial unique index
      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: 'tx_p8_null_1',
              amount: 30000,
              type: 'expense',
              categoryId: CategoryEngine.catFood,
              date: 1786000000000,
              sourceMessageId: const drift.Value(null),
              createdAt: 1000,
              updatedAt: 1000,
            ),
          );
      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: 'tx_p8_null_2',
              amount: 40000,
              type: 'expense',
              categoryId: CategoryEngine.catFood,
              date: 1786000000000,
              sourceMessageId: const drift.Value(null),
              createdAt: 1000,
              updatedAt: 1000,
            ),
          );

      final nullRows = await (db.select(db.transactionsTable)
            ..where((t) => t.sourceMessageId.isNull()))
          .get();
      expect(nullRows.length, equals(2));
    });
  });

  group('Phase 8: SMS Capture Idempotency - Retry, Replay & Mixed Legacy Inbox Rescan', () {
    test('WorkManager retry / cursor replay does not create duplicate transactions', () async {
      final msg1 = SmsMessage.fromJson({
        '_id': 501,
        'address': 'VK-HDFCBK',
        'date': 1786000100000,
        'body': 'Rs 300.00 debited from HDFC Bank A/C **1234 to Starbucks on 12-Aug-2026 via UPI. Ref 111111.',
      });
      final msg2 = SmsMessage.fromJson({
        '_id': 502,
        'address': 'VK-HDFCBK',
        'date': 1786000200000,
        'body': 'Rs 600.00 debited from HDFC Bank A/C **1234 to Zomato on 12-Aug-2026 via UPI. Ref 222222.',
      });

      when(() => mockSmsQuery.querySms(kinds: [SmsQueryKind.inbox])).thenAnswer((_) async => [msg1, msg2]);

      final tracker = SmsAutoTracker(
        merchantEngine: merchantEngine,
        smsQuery: mockSmsQuery,
      );

      // First run: processes both messages
      final count1 = await tracker.processBackgroundQueue();
      expect(count1, equals(2));

      final allTxs = await db.select(db.transactionsTable).get();
      expect(allTxs.length, equals(2));

      // Simulate WorkManager retry or partial cursor reset back to timestamp 0
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('sms_last_check_timestamp', 0);

      final count2 = await tracker.processBackgroundQueue();
      expect(count2, equals(0), reason: 'Replay of existing inbox messages must yield 0 new transactions');

      final allTxsAfter = await db.select(db.transactionsTable).get();
      expect(allTxsAfter.length, equals(2), reason: 'Zero duplicate rows in SQLite');
    });

    test('Full inbox re-scan against mixed legacy (NULL source_message_id) and hashed DB correctly deduplicates both', () async {
      // 1. Seed legacy transaction (NULL source_message_id) created before Phase 8
      final legacyDate = DateTime(2026, 8, 10, 14, 30);
      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: 'legacy_tx_1',
              amount: 45000, // ₹450
              type: 'expense',
              categoryId: CategoryEngine.catFood,
              date: legacyDate.millisecondsSinceEpoch,
              note: const drift.Value('Auto-tracked: Swiggy'),
              merchantName: const drift.Value('Swiggy'),
              sourceApp: const drift.Value('sms:upi'),
              sourceMessageId: const drift.Value(null), // Legacy NULL!
              createdAt: legacyDate.millisecondsSinceEpoch,
              updatedAt: legacyDate.millisecondsSinceEpoch,
            ),
          );

      // 2. Seed modern Phase 8 transaction (with source_message_id)
      final modernDate = DateTime(2026, 8, 11, 18, 00);
      final modernMsg = SmsMessage.fromJson({
        '_id': 8801,
        'address': 'AD-ICICIB',
        'date': modernDate.millisecondsSinceEpoch,
        'body': 'INR 900.00 debited from ICICI Bank A/C XX4321 on 11-Aug-2026 to Uber. Ref 777.',
      });
      final modernSmsId = MerchantEngine.generateDurableSmsId(modernMsg);

      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion.insert(
              id: 'modern_tx_1',
              amount: 90000, // ₹900
              type: 'expense',
              categoryId: CategoryEngine.catTransport,
              date: modernDate.millisecondsSinceEpoch,
              note: const drift.Value('Auto-tracked: Uber'),
              merchantName: const drift.Value('Uber'),
              sourceApp: const drift.Value('sms:upi'),
              sourceMessageId: drift.Value(modernSmsId),
              createdAt: modernDate.millisecondsSinceEpoch,
              updatedAt: modernDate.millisecondsSinceEpoch,
            ),
          );

      // Verify DB starts with 2 rows (1 legacy NULL, 1 hashed)
      final initialRows = await db.select(db.transactionsTable).get();
      expect(initialRows.length, equals(2));

      // 3. Prepare full inbox containing:
      // - Legacy SMS matching legacy_tx_1
      // - Modern SMS matching modern_tx_1
      // - Brand new SMS not yet captured
      final legacySms = SmsMessage.fromJson({
        '_id': 7001,
        'address': 'VK-HDFCBK',
        'date': legacyDate.millisecondsSinceEpoch,
        'body': 'Rs 450.00 debited from HDFC Bank to Swiggy on 10-Aug-2026 via UPI. Ref 12345.',
      });

      final newSms = SmsMessage.fromJson({
        '_id': 9901,
        'address': 'VK-SBIPSG',
        'date': DateTime(2026, 8, 12, 10, 0).millisecondsSinceEpoch,
        'body': 'Rs 1,500.00 debited from SBI A/C 9876 to Supermarket on 12-Aug-2026. Ref 555.',
      });

      when(() => mockSmsQuery.querySms(kinds: [SmsQueryKind.inbox])).thenAnswer(
        (_) async => [legacySms, modernMsg, newSms],
      );

      final tracker = SmsAutoTracker(
        merchantEngine: merchantEngine,
        smsQuery: mockSmsQuery,
      );

      final importedCount = await tracker.processBackgroundQueue();
      expect(importedCount, equals(1), reason: 'Only the 1 new SMS should be imported; legacy and hashed must both be deduplicated');

      final finalRows = await db.select(db.transactionsTable).get();
      expect(finalRows.length, equals(3), reason: 'Total rows must be exactly 3 (1 legacy + 1 existing hashed + 1 newly imported)');
    });
  });
}
