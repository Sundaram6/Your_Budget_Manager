import '../entities/recurring_transaction.dart';

abstract class RecurringRepository {
  Stream<List<RecurringTransaction>> watchAll();
  Future<List<RecurringTransaction>> getActive();
  Future<List<RecurringTransaction>> getDueTransactions(DateTime beforeDate);
  Future<int> insert(RecurringTransaction recurringTransaction);
  Future<bool> updateRecurringTransaction(RecurringTransaction recurringTransaction);
  Future<int> deleteRecurringTransaction(RecurringTransaction recurringTransaction);
}
