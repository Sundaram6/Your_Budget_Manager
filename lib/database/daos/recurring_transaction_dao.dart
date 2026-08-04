import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recurring_transactions_table.dart';

part 'recurring_transaction_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactionsTable])
class RecurringTransactionDao extends DatabaseAccessor<AppDatabase> with _$RecurringTransactionDaoMixin {
  RecurringTransactionDao(super.db);

  Stream<List<RecurringTransactionData>> watchAll() => select(recurringTransactionsTable).watch();

  Future<List<RecurringTransactionData>> getActive() {
    return (select(recurringTransactionsTable)..where((t) => t.isActive.equals(true))).get();
  }

  Future<List<RecurringTransactionData>> getDueTransactions(String beforeDateStr) {
    return (select(recurringTransactionsTable)..where((t) => t.nextDueDate.isSmallerOrEqualValue(beforeDateStr) & t.isActive.equals(true))).get();
  }

  Future<int> insert(Insertable<RecurringTransactionData> recurringTransaction) => into(recurringTransactionsTable).insert(recurringTransaction);

  Future<bool> updateRecurringTransaction(Insertable<RecurringTransactionData> recurringTransaction) => update(recurringTransactionsTable).replace(recurringTransaction);

  Future<int> deleteRecurringTransaction(Insertable<RecurringTransactionData> recurringTransaction) => delete(recurringTransactionsTable).delete(recurringTransaction);
}
