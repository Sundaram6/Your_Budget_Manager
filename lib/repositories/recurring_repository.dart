import '../database/database_helper.dart';
import '../models/recurring_transaction.dart';

class RecurringRepository {
  static final RecurringRepository instance = RecurringRepository._init();

  RecurringRepository._init();

  Stream<List<RecurringTransactionModel>> watchAll() {
    return DatabaseHelper.instance.watchAllRecurringTransactions();
  }

  Future<RecurringTransactionModel?> getById(String id) {
    return DatabaseHelper.instance.getRecurringTransactionById(id);
  }

  Future<int> insert(RecurringTransactionModel model) {
    return DatabaseHelper.instance.insertRecurringTransaction(model);
  }

  Future<int> update(RecurringTransactionModel model) {
    return DatabaseHelper.instance.insertRecurringTransaction(model);
  }

  Future<int> delete(String id) {
    return DatabaseHelper.instance.deleteRecurringTransaction(id);
  }
}
