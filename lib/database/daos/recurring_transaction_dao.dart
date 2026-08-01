import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recurring_transactions_table.dart';

part 'recurring_transaction_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactionsTable])
class RecurringTransactionDao extends DatabaseAccessor<AppDatabase> with _$RecurringTransactionDaoMixin {
  RecurringTransactionDao(super.db);

  Stream<List<RecurringTransaction>> watchAll() => select(recurringTransactionsTable).watch();

  Future<List<RecurringTransaction>> getActive() {
    return (select(recurringTransactionsTable)..where((t) => t.isActive.equals(true))).get();
  }

  Future<List<RecurringTransaction>> getDueTransactions(DateTime beforeDate) {
    return (select(recurringTransactionsTable)..where((t) => t.nextDueDate.isSmallerOrEqualValue(beforeDate.millisecondsSinceEpoch) & t.isActive.equals(true))).get();
  }

  Future<int> insert(Insertable<RecurringTransaction> recurringTransaction) => into(recurringTransactionsTable).insert(recurringTransaction);

  Future<bool> updateRecurringTransaction(Insertable<RecurringTransaction> recurringTransaction) => update(recurringTransactionsTable).replace(recurringTransaction);

  Future<int> deleteRecurringTransaction(Insertable<RecurringTransaction> recurringTransaction) => delete(recurringTransactionsTable).delete(recurringTransaction);
}
