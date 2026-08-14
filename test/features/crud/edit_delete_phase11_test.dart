import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/daos/savings_goal_dao.dart';
import 'package:your_budget_manager/database/daos/transaction_dao.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/database/health/database_health_check.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/savings/savings_engine.dart';
import 'package:your_budget_manager/features/savings/data/repositories/savings_goal_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';
import 'package:your_budget_manager/repositories/recurring_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TransactionDao transactionDao;
  late TransactionRepositoryImpl transactionRepo;
  late ExpenseEngine expenseEngine;
  late SavingsGoalDao savingsGoalDao;
  late SavingsGoalRepositoryImpl savingsGoalRepo;
  late SavingsEngine savingsEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);
    await DatabaseHealthCheck(db).run();
    transactionDao = TransactionDao(db);
    transactionRepo = TransactionRepositoryImpl(transactionDao);
    expenseEngine = ExpenseEngine(transactionRepo);

    savingsGoalDao = SavingsGoalDao(db);
    savingsGoalRepo = SavingsGoalRepositoryImpl(savingsGoalDao);
    savingsEngine = SavingsEngine(savingsGoalDao, savingsGoalRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 11: Transactions Edit & Delete', () {
    test('Edit transaction preserves all non-edited metadata fields', () async {
      final now = DateTime(2026, 8, 15, 10, 30);
      final recurringId = 'rec_test_123';

      await RecurringRepository.instance.insert(
        RecurringTransactionModel(
          id: recurringId,
          title: 'Lunch Plan',
          amountPaise: 25000,
          categoryId: 'cat_food',
          type: 'expense',
          frequency: 'daily',
          startDate: now,
          nextDueDate: now,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final createdTx = await expenseEngine.addTransaction(
        amount: 25000, // ₹250.00
        date: now,
        categoryId: 'cat_food',
        type: TransactionType.expense,
        note: 'Original lunch note',
        sourceApp: 'sms_auto',
        paymentMethod: PaymentMethod.upi,
        cardLast4: '4321',
        isRecurring: true,
        recurringId: recurringId,
        merchantName: 'Swiggy',
        recurrenceOccurrenceKey: 'rec_test_123:2026-08-15',
        sourceMessageId: 'sms_sha256_abcdef1234567890',
        createdAt: 1700000000000,
      );

      // Edit amount, category, and note
      final updatedTx = createdTx.copyWith(
        amount: const Amount(35000), // ₹350.00
        categoryId: 'cat_food',
        note: 'Updated dinner note',
        updatedAt: 1700000050000,
      );

      final updateSuccess = await expenseEngine.updateTransaction(updatedTx);
      expect(updateSuccess, isTrue);

      final fetched = await expenseEngine.getTransactionById(createdTx.id);
      expect(fetched, isNotNull);
      expect(fetched!.amount.value, 35000);
      expect(fetched.categoryId, 'cat_food');
      expect(fetched.note, 'Updated dinner note');

      // Crucial: verify all non-edited metadata was preserved 100% losslessly
      expect(fetched.sourceApp, 'sms_auto');
      expect(fetched.paymentMethod, PaymentMethod.upi);
      expect(fetched.cardLast4, '4321');
      expect(fetched.isRecurring, isTrue);
      expect(fetched.recurringId, recurringId);
      expect(fetched.merchantName, 'Swiggy');
      expect(fetched.recurrenceOccurrenceKey, 'rec_test_123:2026-08-15');
      expect(fetched.sourceMessageId, 'sms_sha256_abcdef1234567890');
      expect(fetched.createdAt, 1700000000000);
    });

    test('Delete transaction removes record and updates monthly totals', () async {
      final month = DateTime(2026, 8, 1);
      final tx1 = await expenseEngine.addTransaction(
        amount: 10000, // ₹100.00
        date: DateTime(2026, 8, 5),
        categoryId: 'cat_groceries',
        type: TransactionType.expense,
      );
      final tx2 = await expenseEngine.addTransaction(
        amount: 20000, // ₹200.00
        date: DateTime(2026, 8, 10),
        categoryId: 'cat_utilities',
        type: TransactionType.expense,
      );

      var total = await expenseEngine.getMonthlyTotal(month, type: TransactionType.expense);
      expect(total, 30000); // ₹300.00

      // Delete tx1
      final rowsDeleted = await expenseEngine.deleteTransaction(tx1);
      expect(rowsDeleted, 1);

      // Verify tx1 is gone
      final fetched1 = await expenseEngine.getTransactionById(tx1.id);
      expect(fetched1, isNull);

      // Verify tx2 remains
      final fetched2 = await expenseEngine.getTransactionById(tx2.id);
      expect(fetched2, isNotNull);

      // Verify updated monthly total
      total = await expenseEngine.getMonthlyTotal(month, type: TransactionType.expense);
      expect(total, 20000); // ₹200.00
    });
  });

  group('Phase 11: Recurring Transactions Edit & Delete', () {
    test('Edit recurring transaction updates recurring rule parameters', () async {
      final now = DateTime(2026, 8, 1);
      final initial = RecurringTransactionModel(
        id: 'rec_fiber_net',
        title: 'Broadband Bill',
        amountPaise: 99900, // ₹999.00
        categoryId: 'cat_utilities',
        type: 'expense',
        frequency: 'monthly',
        startDate: now,
        nextDueDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await RecurringRepository.instance.insert(initial);

      // Edit recurring rule: change title, amount, frequency
      final updated = initial.copyWith(
        title: 'Gigabit Fiber Internet',
        amountPaise: 149900, // ₹1499.00
        frequency: 'biweekly',
        updatedAt: DateTime(2026, 8, 2),
      );

      await RecurringRepository.instance.update(updated);

      final fetched = await RecurringRepository.instance.getById('rec_fiber_net');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Gigabit Fiber Internet');
      expect(fetched.amountPaise, 149900);
      expect(fetched.frequency, 'biweekly');
    });

    test('Delete recurring transaction unlinks historical transactions rather than deleting them', () async {
      final now = DateTime(2026, 8, 1);
      final recurringId = 'rec_subscription_1';
      final recurring = RecurringTransactionModel(
        id: recurringId,
        title: 'OTT Subscription',
        amountPaise: 49900,
        categoryId: 'cat_entertainment',
        type: 'expense',
        frequency: 'monthly',
        startDate: now,
        nextDueDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await RecurringRepository.instance.insert(recurring);

      // Generate a historical transaction linked to this recurring rule
      final historicalTx = await expenseEngine.addTransaction(
        amount: 49900,
        date: now,
        categoryId: 'cat_entertainment',
        type: TransactionType.expense,
        isRecurring: true,
        recurringId: recurringId,
        note: 'Auto-generated July occurrence',
      );

      expect(historicalTx.recurringId, recurringId);

      // Delete recurring rule
      await RecurringRepository.instance.delete(recurringId);

      // 1. Confirm recurring rule is deleted
      final recurringCheck = await RecurringRepository.instance.getById(recurringId);
      expect(recurringCheck, isNull);

      // 2. Confirm historical transaction survives and recurringId is safely unlinked (null)
      final txCheck = await expenseEngine.getTransactionById(historicalTx.id);
      expect(txCheck, isNotNull);
      expect(txCheck!.recurringId, isNull);
      expect(txCheck.amount.value, 49900);
      expect(txCheck.note, 'Auto-generated July occurrence');
    });
  });

  group('Phase 11: Savings Goals Edit & Delete', () {
    test('Edit savings goal updates parameters atomically while preserving currentAmount', () async {
      final now = DateTime(2026, 8, 1);
      await savingsEngine.createGoal(
        name: 'New Car',
        targetAmountPaise: 50000000, // ₹5,00,000
        deadline: DateTime(2027, 8, 1),
        autoDeduct: false,
      );

      final allGoals = await savingsEngine.watchGoals().first;
      expect(allGoals.length, 1);
      final goalId = allGoals.first.id;

      // Add a deposit
      await savingsEngine.contributeToGoal(goalId, 10000000); // ₹1,00,000 deposited

      // Edit goal name, target amount, and enable autoDeduct
      final updateResult = await savingsEngine.updateGoal(
        id: goalId,
        name: 'Electric SUV',
        targetAmountPaise: 60000000, // ₹6,00,000
        deadline: DateTime(2028, 1, 1),
        autoDeduct: true,
        autoDeductAmountPaise: 2500000, // ₹25,000
      );
      expect(updateResult, isTrue);

      final updatedGoal = await savingsEngine.watchGoal(goalId).first;
      expect(updatedGoal, isNotNull);
      expect(updatedGoal!.name, 'Electric SUV');
      expect(updatedGoal.targetAmount, 60000000);
      expect(updatedGoal.autoDeduct, isTrue);
      expect(updatedGoal.autoDeductAmount, 2500000);

      // Crucial: confirm accumulated currentAmount was not reset
      expect(updatedGoal.currentAmount, 10000000);
    });

    test('Delete savings goal removes goal from database streams', () async {
      await savingsEngine.createGoal(
        name: 'Trip to Tokyo',
        targetAmountPaise: 20000000,
      );

      var goals = await savingsEngine.watchGoals().first;
      expect(goals.length, 1);
      final goalId = goals.first.id;

      await savingsEngine.deleteGoal(goalId);

      goals = await savingsEngine.watchGoals().first;
      expect(goals, isEmpty);

      final singleGoal = await savingsEngine.watchGoal(goalId).first;
      expect(singleGoal, isNull);
    });
  });
}
