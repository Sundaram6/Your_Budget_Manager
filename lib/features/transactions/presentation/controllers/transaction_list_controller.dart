import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../engines/expense/expense_engine_provider.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_list_controller.freezed.dart';
part 'transaction_list_controller.g.dart';

@freezed
abstract class TransactionListState with _$TransactionListState {
  const factory TransactionListState({
    required DateTime selectedMonth,
    required Map<DateTime, List<Transaction>> groupedTransactions,
  }) = _TransactionListState;
}

@riverpod
class TransactionListController extends _$TransactionListController {
  DateTime _currentMonth = DateTime.now();

  @override
  FutureOr<TransactionListState> build() {
    final expenseEngine = ref.watch(expenseEngineProvider);
    final sub = expenseEngine.watchTransactionsByMonth(_currentMonth).listen((transactions) {
      final grouped = <DateTime, List<Transaction>>{};
      for (final t in transactions) {
        final dateOnly = DateTime(t.date.year, t.date.month, t.date.day);
        grouped.putIfAbsent(dateOnly, () => []).add(t);
      }
      
      final sortedGrouped = Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key))
      );
      
      state = AsyncValue.data(TransactionListState(
        selectedMonth: _currentMonth,
        groupedTransactions: sortedGrouped,
      ));
    });
    ref.onDispose(() => sub.cancel());

    return _loadForMonth(_currentMonth);
  }
  
  Future<TransactionListState> _loadForMonth(DateTime month) async {
    _currentMonth = month;
    final expenseEngine = ref.watch(expenseEngineProvider);
    final transactions = await expenseEngine.getTransactionsByMonth(month);
    
    // Group by date (ignoring time)
    final grouped = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final dateOnly = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(dateOnly, () => []).add(t);
    }
    
    // sort groups by date descending
    final sortedGrouped = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key))
    );
    
    return TransactionListState(
      selectedMonth: month,
      groupedTransactions: sortedGrouped,
    );
  }
  
  Future<void> changeMonth(DateTime newMonth) async {
    _currentMonth = newMonth;
    ref.invalidateSelf();
  }
}
