import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';
import '../../../../engines/merchant/merchant_engine_provider.dart';
import '../../../../engines/sms/models/parsed_transaction.dart';

part 'pending_transactions_controller.g.dart';

class PendingTransactionsState {
  final List<ParsedTransaction> transactions;
  final int scannedSmsCount;
  final bool isLoading;
  final String? error;

  const PendingTransactionsState({
    this.transactions = const [],
    this.scannedSmsCount = 0,
    this.isLoading = false,
    this.error,
  });

  PendingTransactionsState copyWith({
    List<ParsedTransaction>? transactions,
    int? scannedSmsCount,
    bool? isLoading,
    String? error,
  }) {
    return PendingTransactionsState(
      transactions: transactions ?? this.transactions,
      scannedSmsCount: scannedSmsCount ?? this.scannedSmsCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class PendingTransactionsController extends _$PendingTransactionsController {
  @override
  PendingTransactionsState build() {
    return const PendingTransactionsState();
  }

  Future<void> requestPermissionAndScan({int? limit}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        final engine = ref.read(merchantEngineProvider);
        final transactions = await engine.scanInbox(count: limit);
        state = state.copyWith(
          transactions: transactions,
          scannedSmsCount: limit ?? transactions.length,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'SMS permission denied',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Confirms a pending transaction with verified DB read-back. Returns true if saved successfully.
  Future<bool> confirmTransaction(
    ParsedTransaction transaction, {
    String? categoryId,
    TransactionType type = TransactionType.expense,
  }) async {
    try {
      final engine = ref.read(merchantEngineProvider);
      final success = await engine.confirmPendingTransaction(
        transaction: transaction,
        categoryId: categoryId,
        type: type,
      );

      if (success) {
        final updatedList = state.transactions.where((t) => t.smsId != transaction.smsId).toList();
        state = state.copyWith(transactions: updatedList);
        return true;
      } else {
        throw StateError('Failed to confirm transaction ${transaction.merchantName}');
      }
    } catch (e) {
      // Propagate exception to UI layer for error display
      rethrow;
    }
  }

  /// Confirms all pending transactions in bulk. Returns count of successfully confirmed transactions.
  Future<int> confirmAllTransactions() async {
    final engine = ref.read(merchantEngineProvider);
    final list = List<ParsedTransaction>.from(state.transactions);
    int successCount = 0;
    final remaining = <ParsedTransaction>[];

    for (final tx in list) {
      try {
        final success = await engine.confirmPendingTransaction(
          transaction: tx,
        );
        if (success) {
          successCount++;
        } else {
          remaining.add(tx);
        }
      } catch (e) {
        remaining.add(tx);
      }
    }

    state = state.copyWith(transactions: remaining);
    return successCount;
  }
}
