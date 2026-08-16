import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart' as db;
import 'package:your_budget_manager/database/daos/category_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/transfer/self_transfer_engine.dart';
import 'package:your_budget_manager/features/categories/data/repositories/category_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.AppDatabase database;
  late TransactionDao dao;
  late TransactionRepositoryImpl repository;
  late SelfTransferEngine selfTransferEngine;
  late ExpenseEngine expenseEngine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = db.AppDatabase(NativeDatabase.memory());
    dao = TransactionDao(database);
    repository = TransactionRepositoryImpl(dao);
    selfTransferEngine = SelfTransferEngine(database);
    expenseEngine = ExpenseEngine(repository, selfTransferEngine: selfTransferEngine);

    final catDao = CategoryDao(database);
    final catRepo = CategoryRepositoryImpl(catDao);
    final categoryEngine = CategoryEngine(catRepo);
    await categoryEngine.seedDefaults();
  });

  tearDown(() async {
    await database.close();
  });

  group('Self-Transfer Lifecycle & Cascade Unlinking Tests', () {
    final baseTime = DateTime(2026, 8, 16, 15, 0, 0);

    test('manual entry of debit and credit with shared ref auto-links via ExpenseEngine', () async {
      // 1. Enter debit side
      final debit = await expenseEngine.addTransaction(
        amount: 250000, // ₹2,500
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transactionRef: 'REF123456',
        sourceApp: 'manual',
      );
      expect(debit.isSelfTransfer, isFalse);

      // 2. Enter credit side 2 minutes later
      final credit = await expenseEngine.addTransaction(
        amount: 250000,
        date: baseTime.add(const Duration(minutes: 2)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        transactionRef: 'REF123456',
        sourceApp: 'manual',
      );

      // Credit returned from addTransaction has transferPairId set
      expect(credit.isSelfTransfer, isTrue);
      expect(credit.transferPairId, isNotNull);

      // Fetch debit from DB to verify it was also updated
      final updatedDebit = await expenseEngine.getTransactionById(debit.id);
      expect(updatedDebit, isNotNull);
      expect(updatedDebit!.isSelfTransfer, isTrue);
      expect(updatedDebit.transferPairId, equals(credit.transferPairId));
    });

    test('single-sided transaction (unpaired) stays a normal transaction without error', () async {
      final tx = await expenseEngine.addTransaction(
        amount: 100000,
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        sourceApp: 'sms:hdfc',
      );

      expect(tx.isSelfTransfer, isFalse);
      expect(tx.transferPairId, isNull);

      final fetched = await expenseEngine.getTransactionById(tx.id);
      expect(fetched, isNotNull);
      expect(fetched!.isSelfTransfer, isFalse);
    });

    test('deleting one side of a linked pair unlinks the remaining side (no dangling reference)', () async {
      // 1. Create linked pair
      final debit = await expenseEngine.addTransaction(
        amount: 150000,
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transactionRef: 'UTR_DEL_TEST',
      );
      final credit = await expenseEngine.addTransaction(
        amount: 150000,
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        transactionRef: 'UTR_DEL_TEST',
      );

      final refreshedDebit = await expenseEngine.getTransactionById(debit.id);
      expect(refreshedDebit!.isSelfTransfer, isTrue);

      // 2. Delete the credit side
      await expenseEngine.deleteTransaction(credit);

      // Credit row is deleted
      final creditInDb = await expenseEngine.getTransactionById(credit.id);
      expect(creditInDb, isNull);

      // Remaining debit row is now unlinked (transferPairId == null)
      final debitInDb = await expenseEngine.getTransactionById(debit.id);
      expect(debitInDb, isNotNull);
      expect(debitInDb!.isSelfTransfer, isFalse);
      expect(debitInDb.transferPairId, isNull);
    });

    test('editing amount on one side of a linked pair unlinks both transactions', () async {
      // 1. Create linked pair
      final debit = await expenseEngine.addTransaction(
        amount: 300000,
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transactionRef: 'UTR_EDIT_TEST',
      );
      final credit = await expenseEngine.addTransaction(
        amount: 300000,
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        transactionRef: 'UTR_EDIT_TEST',
      );

      final refreshedDebit = await expenseEngine.getTransactionById(debit.id);
      expect(refreshedDebit!.isSelfTransfer, isTrue);

      // 2. Edit amount of debit to ₹3,500 (350000 paise)
      final editedDebit = refreshedDebit.copyWith(amount: const Amount(350000));
      await expenseEngine.updateTransaction(editedDebit);

      // Both transactions should now be unlinked
      final updatedDebitInDb = await expenseEngine.getTransactionById(debit.id);
      final updatedCreditInDb = await expenseEngine.getTransactionById(credit.id);

      expect(updatedDebitInDb!.isSelfTransfer, isFalse);
      expect(updatedDebitInDb.transferPairId, isNull);
      expect(updatedDebitInDb.amount.value, equals(350000));

      expect(updatedCreditInDb!.isSelfTransfer, isFalse);
      expect(updatedCreditInDb.transferPairId, isNull);
    });

    test('editing type on one side of a linked pair unlinks both transactions', () async {
      // 1. Create linked pair
      final debit = await expenseEngine.addTransaction(
        amount: 400000,
        date: baseTime,
        categoryId: CategoryEngine.catFood,
        type: TransactionType.expense,
        transactionRef: 'UTR_TYPE_TEST',
      );
      await expenseEngine.addTransaction(
        amount: 400000,
        date: baseTime.add(const Duration(minutes: 1)),
        categoryId: CategoryEngine.catIncome,
        type: TransactionType.income,
        transactionRef: 'UTR_TYPE_TEST',
      );

      final refreshedDebit = await expenseEngine.getTransactionById(debit.id);
      expect(refreshedDebit!.isSelfTransfer, isTrue);

      // 2. Edit type of debit from expense to income
      final editedDebit = refreshedDebit.copyWith(type: TransactionType.income);
      await expenseEngine.updateTransaction(editedDebit);

      final updatedDebitInDb = await expenseEngine.getTransactionById(debit.id);
      expect(updatedDebitInDb!.isSelfTransfer, isFalse);
      expect(updatedDebitInDb.transferPairId, isNull);
    });
  });
}
