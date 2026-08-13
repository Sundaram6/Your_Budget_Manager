import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums.dart';
import '../../../../database/database_helper.dart';
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

  Future<void> scanByMonth(int year, int month) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        final engine = ref.read(merchantEngineProvider);
        final transactions = await engine.scanInbox(count: 2000, year: year, month: month);
        state = state.copyWith(
          transactions: transactions,
          scannedSmsCount: transactions.length,
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

  Future<void> scanAllTime() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        final engine = ref.read(merchantEngineProvider);
        final transactions = await engine.scanInbox(count: null);
        state = state.copyWith(
          transactions: transactions,
          scannedSmsCount: transactions.length,
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

  Future<int> scanSinceLastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('sms_last_check_timestamp') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      final status = await Permission.sms.status;
      if (!status.isGranted) return 0;

      final engine = ref.read(merchantEngineProvider);
      final transactions = await engine.scanInbox();
      
      final newTxs = transactions.where((tx) => tx.date.millisecondsSinceEpoch > lastCheck).toList();
      int autoSaved = 0;
      int maxProcessedTimestamp = lastCheck;
      for (final tx in newTxs) {
        maxProcessedTimestamp = max(maxProcessedTimestamp, tx.date.millisecondsSinceEpoch);
        final isDuplicate = await DatabaseHelper.instance.checkDuplicateTransaction(
          amountValue: tx.amount,
          date: tx.date,
          snippet: tx.merchantName,
        );

        if (isDuplicate) continue;

        final success = await engine.confirmPendingTransaction(transaction: tx);
        if (success) {
          autoSaved++;
        }
      }

      await prefs.setInt('sms_last_check_timestamp', max(maxProcessedTimestamp, now));
      return autoSaved;
    } catch (e) {
      return 0;
    }
  }

  /// Confirms a pending transaction with verified DB read-back. Returns true if saved successfully.
  Future<bool> confirmTransaction(
    ParsedTransaction transaction, {
    String? categoryId,
    TransactionType type = TransactionType.expense,
  }) async {
    try {
      final isDuplicate = await DatabaseHelper.instance.checkDuplicateTransaction(
        amountValue: transaction.amount,
        date: transaction.date,
        snippet: transaction.merchantName,
      );

      if (isDuplicate) {
        // Automatically remove it from the list if it's a duplicate
        final updatedList = state.transactions.where((t) => t.smsId != transaction.smsId).toList();
        state = state.copyWith(transactions: updatedList);
        return false;
      }

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
      rethrow;
    }
  }

  /// Confirms all pending transactions in bulk, skipping duplicates.
  /// Returns a record of (imported, skipped) counts.
  Future<({int imported, int skipped})> confirmAllTransactions() async {
    final engine = ref.read(merchantEngineProvider);
    final list = List<ParsedTransaction>.from(state.transactions);
    int imported = 0;
    int skipped = 0;
    final remaining = <ParsedTransaction>[];

    for (final tx in list) {
      try {
        // Duplicate check before inserting
        final isDuplicate = await DatabaseHelper.instance.checkDuplicateTransaction(
          amountValue: tx.amount,
          date: tx.date,
          snippet: tx.merchantName,
        );

        if (isDuplicate) {
          skipped++;
          continue; // Skip this transaction
        }

        final success = await engine.confirmPendingTransaction(
          transaction: tx,
        );
        if (success) {
          imported++;
        } else {
          remaining.add(tx);
        }
      } catch (e) {
        remaining.add(tx);
      }
    }

    state = state.copyWith(transactions: remaining);
    return (imported: imported, skipped: skipped);
  }
}
