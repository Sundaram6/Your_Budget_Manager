import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<Transaction>> watchAllTransactions() => select(transactionsTable).watch();

  Stream<List<Transaction>> watchTransactionsByDateRange(DateTime start, DateTime end) {
    return (select(transactionsTable)..where((t) => t.date.isBetweenValues(start.millisecondsSinceEpoch, end.millisecondsSinceEpoch))).watch();
  }

  Stream<List<Transaction>> watchTransactionsByCategory(String categoryId) {
    return (select(transactionsTable)..where((t) => t.categoryId.equals(categoryId))).watch();
  }

  Future<int> insertTransaction(Insertable<Transaction> transaction) => into(transactionsTable).insert(transaction);

  Future<bool> updateTransaction(Insertable<Transaction> transaction) => update(transactionsTable).replace(transaction);

  Future<int> deleteTransaction(Insertable<Transaction> transaction) => delete(transactionsTable).delete(transaction);
}
