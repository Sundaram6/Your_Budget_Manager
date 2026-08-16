import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart' as db;
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/transfer/models/transfer_match_result.dart';
import 'package:your_budget_manager/engines/transfer/self_transfer_engine.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.AppDatabase database;
  late SelfTransferEngine engine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = db.AppDatabase(NativeDatabase.memory());
    engine = SelfTransferEngine(database);

    final catDao = CategoryDao(database);
    final catRepo = CategoryRepositoryImpl(catDao);
    final categoryEngine = CategoryEngine(catRepo);
    await categoryEngine.seedDefaults();
  });

  tearDown(() async {
    await database.close();
  });

  group('SelfTransferEngine.evaluateMatch Unit Tests', () {
    final baseTime = DateTime(2026, 8, 16, 12, 0, 0);

    test('matches opposite type, exact amount, within 5 minutes', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(250000), // ₹2,500
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        sourceApp: 'sms:hdfc',
        accountLast4: '1234',
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(250000), // ₹2,500
        date: baseTime.add(const Duration(minutes: 2)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        sourceApp: 'sms:icici',
        accountLast4: '5678',
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNotNull);
      expect(result!.confidence, TransferConfidence.high); // cross-bank high confidence
    });

    test('rejects same transaction types (both expense)', () {
      final tx1 = Transaction(
        id: 'tx_1',
        amount: const Amount(10000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final tx2 = Transaction(
        id: 'tx_2',
        amount: const Amount(10000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final result = engine.evaluateMatch(tx1, tx2);
      expect(result, isNull);
    });

    test('rejects same transaction types (both income)', () {
      final tx1 = Transaction(
        id: 'tx_1',
        amount: const Amount(10000),
        date: baseTime,
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final tx2 = Transaction(
        id: 'tx_2',
        amount: const Amount(10000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final result = engine.evaluateMatch(tx1, tx2);
      expect(result, isNull);
    });

    test('rejects mismatched amounts (near miss ₹500 vs ₹501)', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(50000), // ₹500.00
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(50100), // ₹501.00
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNull);
    });

    test('rejects time difference greater than 5-minute window', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(100000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(100000),
        date: baseTime.add(const Duration(minutes: 5, seconds: 2)), // 5m 2s > 5m
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNull);
    });

    test('matches on boundary at 4m 59s', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(100000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(100000),
        date: baseTime.add(const Duration(minutes: 4, seconds: 59)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNotNull);
    });

    test('rejects matching against self', () {
      final tx = Transaction(
        id: 'tx_1',
        amount: const Amount(10000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );

      final result = engine.evaluateMatch(tx, tx);
      expect(result, isNull);
    });

    test('rejects already linked transactions', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(100000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transferPairId: 'tf_existing_pair',
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(100000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNull);
    });

    test('high confidence when transactionRef / UTR matches', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(100000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transactionRef: 'UPI/523412349000',
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(100000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        transactionRef: 'UPI/523412349000',
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNotNull);
      expect(result!.confidence, TransferConfidence.high);
      expect(result.reason, contains('Matching reference'));
    });

    test('high confidence when cross-account last4 is mentioned in note', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(100000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        accountLast4: '4321',
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(100000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        note: 'Received from A/c ending 4321',
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNotNull);
      expect(result!.confidence, TransferConfidence.high);
      expect(result.reason, contains('Cross-account reference'));
    });

    test('suggested (low confidence) when amount and time match but no shared refs', () {
      final debit = Transaction(
        id: 'tx_debit_1',
        amount: const Amount(50000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        merchantName: 'Tea Stall',
      );

      final credit = Transaction(
        id: 'tx_credit_1',
        amount: const Amount(50000),
        date: baseTime.add(const Duration(minutes: 2)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        merchantName: 'Friend Payment',
      );

      final result = engine.evaluateMatch(debit, credit);
      expect(result, isNotNull);
      expect(result!.confidence, TransferConfidence.suggested);
      expect(result.isAutoLinked, isFalse);
    });
  });

  group('SelfTransferEngine Database Operations & Scan Tests', () {
    final baseTime = DateTime(2026, 8, 16, 14, 0, 0);

    test('scanAndProcess auto-links high-confidence match in SQLite', () async {
      // 1. Insert existing credit
      await database.into(database.transactionsTable).insert(
        db.TransactionsTableCompanion.insert(
          id: 'credit_row_1',
          amount: 500000, // ₹5,000
          type: 'income',
          categoryId: CategoryEngine.catIncome,
          date: baseTime.millisecondsSinceEpoch,
          transactionRef: const Value('UTR99887766'),
          createdAt: baseTime.millisecondsSinceEpoch,
          updatedAt: baseTime.millisecondsSinceEpoch,
        ),
      );

      // 2. Incoming debit matching UTR99887766 1 min later
      final debitTx = Transaction(
        id: 'debit_row_1',
        amount: const Amount(500000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transactionRef: 'UTR99887766',
      );
      await database.into(database.transactionsTable).insert(
        db.TransactionsTableCompanion.insert(
          id: debitTx.id,
          amount: debitTx.amount.value,
          type: debitTx.type.name,
          categoryId: debitTx.categoryId,
          date: debitTx.date.millisecondsSinceEpoch,
          transactionRef: Value(debitTx.transactionRef),
          createdAt: debitTx.date.millisecondsSinceEpoch,
          updatedAt: debitTx.date.millisecondsSinceEpoch,
        ),
      );

      final scanResult = await engine.scanAndProcess(debitTx);
      expect(scanResult, isNotNull);
      expect(scanResult!.confidence, TransferConfidence.high);
      expect(scanResult.isAutoLinked, isTrue);

      // Verify both rows have the same non-null transfer_pair_id in DB
      final rows = await database.select(database.transactionsTable).get();
      final row1 = rows.firstWhere((r) => r.id == 'credit_row_1');
      final row2 = rows.firstWhere((r) => r.id == 'debit_row_1');

      expect(row1.transferPairId, isNotNull);
      expect(row2.transferPairId, isNotNull);
      expect(row1.transferPairId, equals(row2.transferPairId));
      expect(row1.transferPairId, startsWith('tf_'));
    });

    test('linkPair and unlinkPair manage transfer pair state atomically', () async {
      await database.into(database.transactionsTable).insert(
        db.TransactionsTableCompanion.insert(
          id: 'row_a',
          amount: 30000,
          type: 'expense',
          categoryId: CategoryEngine.catFood,
          date: baseTime.millisecondsSinceEpoch,
          createdAt: baseTime.millisecondsSinceEpoch,
          updatedAt: baseTime.millisecondsSinceEpoch,
        ),
      );
      await database.into(database.transactionsTable).insert(
        db.TransactionsTableCompanion.insert(
          id: 'row_b',
          amount: 30000,
          type: 'income',
          categoryId: CategoryEngine.catIncome,
          date: baseTime.millisecondsSinceEpoch,
          createdAt: baseTime.millisecondsSinceEpoch,
          updatedAt: baseTime.millisecondsSinceEpoch,
        ),
      );

      final pairId = await engine.linkPair('row_a', 'row_b');
      expect(pairId, startsWith('tf_'));

      var rows = await database.select(database.transactionsTable).get();
      expect(rows.firstWhere((r) => r.id == 'row_a').transferPairId, equals(pairId));
      expect(rows.firstWhere((r) => r.id == 'row_b').transferPairId, equals(pairId));

      // Unlink pair
      await engine.unlinkPair(pairId);

      rows = await database.select(database.transactionsTable).get();
      expect(rows.firstWhere((r) => r.id == 'row_a').transferPairId, isNull);
      expect(rows.firstWhere((r) => r.id == 'row_b').transferPairId, isNull);
    });

    test('getCounterpart returns counterpart transaction entity', () async {
      await database.into(database.transactionsTable).insert(
        db.TransactionsTableCompanion.insert(
          id: 'row_1',
          amount: 45000,
          type: 'expense',
          categoryId: CategoryEngine.catFood,
          date: baseTime.millisecondsSinceEpoch,
          transferPairId: const Value('tf_test_pair'),
          createdAt: baseTime.millisecondsSinceEpoch,
          updatedAt: baseTime.millisecondsSinceEpoch,
        ),
      );
      await database.into(database.transactionsTable).insert(
        db.TransactionsTableCompanion.insert(
          id: 'row_2',
          amount: 45000,
          type: 'income',
          categoryId: CategoryEngine.catIncome,
          date: baseTime.millisecondsSinceEpoch,
          transferPairId: const Value('tf_test_pair'),
          createdAt: baseTime.millisecondsSinceEpoch,
          updatedAt: baseTime.millisecondsSinceEpoch,
        ),
      );

      final tx1 = Transaction(
        id: 'row_1',
        amount: const Amount(45000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transferPairId: 'tf_test_pair',
      );

      final counterpart = await engine.getCounterpart(tx1);
      expect(counterpart, isNotNull);
      expect(counterpart!.id, equals('row_2'));
      expect(counterpart.type, equals(TransactionType.income));
    });

    test('dismissSuggestion persists and suppresses future suggestion prompts', () async {
      final debit = Transaction(
        id: 'tx_sug_1',
        amount: const Amount(12000),
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
      );
      final credit = Transaction(
        id: 'tx_sug_2',
        amount: const Amount(12000),
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
      );

      final sug = TransferSuggestion(
        sourceTransaction: debit,
        candidateTransaction: credit,
        reason: 'Suggested test',
        createdAt: DateTime.now(),
      );

      expect(await engine.isSuggestionDismissed(sug.pairKey), isFalse);

      await engine.dismissSuggestion(sug.pairKey);

      expect(await engine.isSuggestionDismissed(sug.pairKey), isTrue);
    });
  });
}
