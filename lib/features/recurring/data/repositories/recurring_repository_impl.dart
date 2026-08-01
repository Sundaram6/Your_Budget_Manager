import '../../../../core/enums.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/recurring_transaction_dao.dart';
import '../../../transactions/domain/value_objects/amount.dart';
import '../../domain/entities/recurring_transaction.dart' as domain;
import '../../domain/repositories/recurring_repository.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringTransactionDao _dao;

  RecurringRepositoryImpl(this._dao);

  domain.RecurringTransaction _mapToDomain(db.RecurringTransaction entity) {
    return domain.RecurringTransaction(
      id: entity.id,
      amount: Amount(entity.amount),
      categoryId: entity.categoryId,
      type: TransactionType.values.firstWhere((e) => e.name == entity.type),
      frequency: RecurringFrequency.values.firstWhere((e) => e.name == entity.frequency),
      nextDate: DateTime.fromMillisecondsSinceEpoch(entity.nextDueDate),
      note: entity.note,
    );
  }

  db.RecurringTransaction _mapToDrift(domain.RecurringTransaction entity) {
    return db.RecurringTransaction(
      id: entity.id,
      name: entity.note ?? 'Recurring Transaction',
      amount: entity.amount.value.toDouble(),
      type: entity.type.name,
      categoryId: entity.categoryId,
      frequency: entity.frequency.name,
      startDate: DateTime.now().millisecondsSinceEpoch,
      nextDueDate: entity.nextDate.millisecondsSinceEpoch,
      isActive: true,
      note: entity.note,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Stream<List<domain.RecurringTransaction>> watchAll() {
    return _dao.watchAll().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Future<List<domain.RecurringTransaction>> getActive() async {
    final list = await _dao.getActive();
    return list.map(_mapToDomain).toList();
  }

  @override
  Future<List<domain.RecurringTransaction>> getDueTransactions(DateTime beforeDate) async {
    final list = await _dao.getDueTransactions(beforeDate);
    return list.map(_mapToDomain).toList();
  }

  @override
  Future<int> insert(domain.RecurringTransaction recurringTransaction) {
    return _dao.insert(_mapToDrift(recurringTransaction));
  }

  @override
  Future<bool> updateRecurringTransaction(domain.RecurringTransaction recurringTransaction) {
    return _dao.updateRecurringTransaction(_mapToDrift(recurringTransaction));
  }

  @override
  Future<int> deleteRecurringTransaction(domain.RecurringTransaction recurringTransaction) {
    return _dao.deleteRecurringTransaction(_mapToDrift(recurringTransaction));
  }
}
