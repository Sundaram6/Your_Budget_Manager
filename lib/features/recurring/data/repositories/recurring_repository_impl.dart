import '../../../../core/enums.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/recurring_transaction_dao.dart';
import '../../../transactions/domain/value_objects/amount.dart';
import '../../domain/entities/recurring_transaction.dart' as domain;
import '../../domain/repositories/recurring_repository.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final RecurringTransactionDao _dao;

  RecurringRepositoryImpl(this._dao);

  domain.RecurringTransaction _mapToDomain(db.RecurringTransactionData entity) {
    return domain.RecurringTransaction(
      id: entity.id,
      amount: Amount(entity.amountPaise / 100.0),
      categoryId: entity.categoryId,
      type: TransactionType.values.firstWhere((e) => e.name == entity.type, orElse: () => TransactionType.expense),
      frequency: RecurringFrequency.values.firstWhere((e) => e.name == entity.frequency, orElse: () => RecurringFrequency.monthly),
      nextDate: DateTime.tryParse(entity.nextDueDate) ?? DateTime.now(),
      note: entity.notes,
    );
  }

  db.RecurringTransactionData _mapToDrift(domain.RecurringTransaction entity) {
    final now = DateTime.now();
    final yyyyMmDd = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final nextYyyyMmDd = '${entity.nextDate.year.toString().padLeft(4, '0')}-${entity.nextDate.month.toString().padLeft(2, '0')}-${entity.nextDate.day.toString().padLeft(2, '0')}';
    return db.RecurringTransactionData(
      id: entity.id,
      title: entity.note ?? 'Recurring Transaction',
      amountPaise: (entity.amount.value * 100).round(),
      type: entity.type.name,
      categoryId: entity.categoryId,
      frequency: entity.frequency.name,
      startDate: yyyyMmDd,
      nextDueDate: nextYyyyMmDd,
      isActive: true,
      autoConfirm: false,
      notes: entity.note,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
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
    final yyyyMmDd = '${beforeDate.year.toString().padLeft(4, '0')}-${beforeDate.month.toString().padLeft(2, '0')}-${beforeDate.day.toString().padLeft(2, '0')}';
    final list = await _dao.getDueTransactions(yyyyMmDd);
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
