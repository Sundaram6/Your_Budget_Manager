import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = TransactionRepositoryImpl(db.transactionDao);

    // Seed category
    await db.into(db.categoriesTable).insert(
      const Category(
        id: 'cat-food',
        name: 'Food',
        icon: 'utensils',
        color: '#FF5722',
        isDefault: true,
        sortOrder: 0,
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    // Seed recurring transaction rule
    await db.into(db.recurringTransactionsTable).insert(
      const RecurringTransactionData(
        id: 'rec-swiggy',
        title: 'Swiggy Weekly',
        amountPaise: 25000,
        categoryId: 'cat-food',
        type: 'expense',
        frequency: 'weekly',
        intervalDays: null,
        startDate: '2026-08-01',
        endDate: null,
        nextDueDate: '2026-08-15',
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: null,
        createdAt: '2026-08-01T00:00:00.000',
        updatedAt: '2026-08-01T00:00:00.000',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('updating a transaction preserves isRecurring, recurringId, createdAt, and merchantName', () async {
    const originalCreatedAt = 1700000000000;
    const initialDbTx = Transaction(
      id: 'txn-1',
      amount: 25000,
      type: 'expense',
      categoryId: 'cat-food',
      date: 1700000000000,
      note: 'Original note',
      merchantName: 'Swiggy',
      merchantId: null,
      isRecurring: true,
      recurringId: 'rec-swiggy',
      isAutoCaptured: true,
      sourceApp: 'sms:hdfc',
      paymentMethod: 'upi',
      cardLast4: null,
      createdAt: originalCreatedAt,
      updatedAt: originalCreatedAt,
    );

    // Insert directly into DB (e.g. from recurring engine or SMS engine)
    await db.into(db.transactionsTable).insert(initialDbTx);

    // Fetch as domain transaction via repository
    final domainTransactions = await repository.watchAllTransactions().first;
    expect(domainTransactions.length, 1);
    final domainTx = domainTransactions.first;

    // Update only the note field on the domain entity
    final updatedDomainTx = domainTx.copyWith(note: 'Updated note by user');
    await repository.updateTransaction(updatedDomainTx);

    // Read raw row from DB
    final rawDbTx = (await db.select(db.transactionsTable).get()).first;

    // Check if metadata was corrupted:
    print('DB after update: isRecurring=${rawDbTx.isRecurring}, recurringId=${rawDbTx.recurringId}, createdAt=${rawDbTx.createdAt}, merchantName=${rawDbTx.merchantName}');

    expect(rawDbTx.note, 'Updated note by user');
    // If bug exists, isRecurring will be false and recurringId will be null and createdAt will be changed
    expect(rawDbTx.isRecurring, isTrue, reason: 'isRecurring should remain true after note edit');
    expect(rawDbTx.recurringId, 'rec-swiggy', reason: 'recurringId should remain intact after note edit');
    expect(rawDbTx.createdAt, originalCreatedAt, reason: 'createdAt should remain original timestamp');
    expect(rawDbTx.merchantName, 'Swiggy', reason: 'merchantName should remain intact');
  });
}
