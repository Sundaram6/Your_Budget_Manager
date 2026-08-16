import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums.dart';
import '../../database/app_database.dart' as db;
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/domain/value_objects/amount.dart';
import 'models/transfer_match_result.dart';

class SelfTransferEngine {
  final db.AppDatabase _db;
  final Logger _logger;
  final Uuid _uuid;

  /// In-memory active suggestions listeners
  final List<void Function(List<TransferSuggestion>)> _suggestionListeners = [];
  final List<TransferSuggestion> _activeSuggestions = [];

  static const String _kDismissedSuggestionsKey = 'dismissed_self_transfer_pair_keys';

  SelfTransferEngine(
    this._db, {
    Logger? logger,
    Uuid? uuid,
  })  : _logger = logger ?? Logger(),
        _uuid = uuid ?? const Uuid();

  List<TransferSuggestion> get activeSuggestions => List.unmodifiable(_activeSuggestions);

  void addSuggestionListener(void Function(List<TransferSuggestion>) listener) {
    _suggestionListeners.add(listener);
    listener(activeSuggestions);
  }

  void removeSuggestionListener(void Function(List<TransferSuggestion>) listener) {
    _suggestionListeners.remove(listener);
  }

  void _notifySuggestionListeners() {
    for (final listener in List.of(_suggestionListeners)) {
      listener(activeSuggestions);
    }
  }

  Transaction _mapToDomain(db.Transaction entity) {
    return Transaction(
      id: entity.id,
      amount: Amount(entity.amount),
      date: DateTime.fromMillisecondsSinceEpoch(entity.date),
      categoryId: entity.categoryId,
      type: TransactionType.values.firstWhere(
        (e) => e.name == entity.type,
        orElse: () => TransactionType.expense,
      ),
      note: entity.note,
      sourceApp: entity.sourceApp,
      paymentMethod: PaymentMethod.fromString(entity.paymentMethod),
      cardLast4: entity.cardLast4,
      accountLast4: entity.accountLast4,
      transactionRef: entity.transactionRef,
      transferPairId: entity.transferPairId,
      isRecurring: entity.isRecurring,
      recurringId: entity.recurringId,
      merchantName: entity.merchantName,
      merchantId: entity.merchantId,
      recurrenceOccurrenceKey: entity.recurrenceOccurrenceKey,
      sourceMessageId: entity.sourceMessageId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Evaluates two in-memory transactions and determines if they qualify as a self-transfer pair,
  /// scoring the confidence as [TransferConfidence.high] (auto-linkable) or [TransferConfidence.suggested].
  TransferMatchResult? evaluateMatch(
    Transaction tx1,
    Transaction tx2, {
    Duration window = const Duration(minutes: 5),
  }) {
    // 1. Cannot match with self
    if (tx1.id == tx2.id) return null;

    // 2. Cannot match if either is already linked
    if (tx1.isSelfTransfer || tx2.isSelfTransfer) return null;

    // 3. Must be opposite transaction types (one income, one expense)
    final isOpposite = (tx1.type == TransactionType.expense && tx2.type == TransactionType.income) ||
        (tx1.type == TransactionType.income && tx2.type == TransactionType.expense);
    if (!isOpposite) return null;

    // 4. Must match exact amount in integer paise
    if (tx1.amount.value != tx2.amount.value) return null;

    // 5. Must be within the time window
    final timeDiffMs = tx1.date.difference(tx2.date).inMilliseconds.abs();
    if (timeDiffMs > window.inMilliseconds) return null;

    // 6. Confidence Scoring
    // Check for shared transactionRef / UTR / RRN (High confidence)
    if (tx1.transactionRef != null &&
        tx2.transactionRef != null &&
        tx1.transactionRef!.trim().isNotEmpty &&
        tx2.transactionRef!.trim().isNotEmpty &&
        tx1.transactionRef!.trim().toLowerCase() == tx2.transactionRef!.trim().toLowerCase()) {
      return TransferMatchResult(
        sourceTransactionId: tx1.id,
        candidateTransactionId: tx2.id,
        confidence: TransferConfidence.high,
        reason: 'Matching reference: ${tx1.transactionRef}',
      );
    }

    // Check if one transaction's accountLast4 appears in the other's note/merchant/body (High confidence)
    final tx1Note = '${tx1.note ?? ''} ${tx1.merchantName ?? ''}'.toLowerCase();
    final tx2Note = '${tx2.note ?? ''} ${tx2.merchantName ?? ''}'.toLowerCase();

    if (tx1.accountLast4 != null && tx1.accountLast4!.isNotEmpty && tx2Note.contains(tx1.accountLast4!)) {
      return TransferMatchResult(
        sourceTransactionId: tx1.id,
        candidateTransactionId: tx2.id,
        confidence: TransferConfidence.high,
        reason: 'Cross-account reference detected (A/c ending in ${tx1.accountLast4})',
      );
    }

    if (tx2.accountLast4 != null && tx2.accountLast4!.isNotEmpty && tx1Note.contains(tx2.accountLast4!)) {
      return TransferMatchResult(
        sourceTransactionId: tx1.id,
        candidateTransactionId: tx2.id,
        confidence: TransferConfidence.high,
        reason: 'Cross-account reference detected (A/c ending in ${tx2.accountLast4})',
      );
    }

    // Check if both sides have distinct accountLast4 and distinct bank identities (High confidence)
    if (tx1.accountLast4 != null &&
        tx2.accountLast4 != null &&
        tx1.accountLast4 != tx2.accountLast4 &&
        tx1.sourceApp != null &&
        tx2.sourceApp != null &&
        tx1.sourceApp != tx2.sourceApp &&
        (tx1.sourceApp!.startsWith('sms:') || tx2.sourceApp!.startsWith('sms:'))) {
      return TransferMatchResult(
        sourceTransactionId: tx1.id,
        candidateTransactionId: tx2.id,
        confidence: TransferConfidence.high,
        reason: 'Cross-bank transfer between A/c *${tx1.accountLast4} and A/c *${tx2.accountLast4}',
      );
    }

    // Otherwise: exact amount and time match -> Suggested match for user confirmation
    return TransferMatchResult(
      sourceTransactionId: tx1.id,
      candidateTransactionId: tx2.id,
      confidence: TransferConfidence.suggested,
      reason: 'Opposite transaction with exact amount ₹${(tx1.amount.value / 100.0).toStringAsFixed(2)} within 5 minutes',
    );
  }

  /// Scans SQLite database for candidate transactions matching [tx] within [window],
  /// directly filtering for unlinked, opposite-type, exact-amount rows in SQL.
  Future<TransferMatchResult?> scanAndProcess(
    Transaction tx, {
    Duration window = const Duration(minutes: 5),
  }) async {
    if (tx.isSelfTransfer) return null;

    final targetMillis = tx.date.millisecondsSinceEpoch;
    final startMillis = targetMillis - window.inMilliseconds;
    final endMillis = targetMillis + window.inMilliseconds;
    final oppositeTypeStr = tx.type == TransactionType.expense ? 'income' : 'expense';

    // Direct SQL query filtering unlinked candidate rows within window & amount
    final candidateRows = await _db.customSelect(
      '''
      SELECT * FROM transactions
      WHERE id != ?
        AND transfer_pair_id IS NULL
        AND amount = ?
        AND type = ?
        AND date >= ?
        AND date <= ?
      ORDER BY ABS(date - ?) ASC
      ''',
      variables: [
        Variable.withString(tx.id),
        Variable.withInt(tx.amount.value),
        Variable.withString(oppositeTypeStr),
        Variable.withInt(startMillis),
        Variable.withInt(endMillis),
        Variable.withInt(targetMillis),
      ],
      readsFrom: {_db.transactionsTable},
    ).get();

    if (candidateRows.isEmpty) return null;

    final candidates = candidateRows.map((r) => _mapToDomain(_db.transactionsTable.map(r.data))).toList();

    TransferMatchResult? bestResult;
    Transaction? bestCandidate;

    for (final candidate in candidates) {
      final eval = evaluateMatch(tx, candidate, window: window);
      if (eval == null) continue;

      if (eval.confidence == TransferConfidence.high) {
        bestResult = eval;
        bestCandidate = candidate;
        break; // High confidence match found -> break early
      } else if (bestResult == null) {
        bestResult = eval;
        bestCandidate = candidate;
      }
    }

    if (bestResult == null || bestCandidate == null) return null;

    if (bestResult.confidence == TransferConfidence.high) {
      final pairId = await linkPair(tx.id, bestCandidate.id);
      _logger.i('Auto-linked high-confidence self-transfer pair $pairId between ${tx.id} and ${bestCandidate.id}');
      
      // Remove any lingering suggestion for these transactions
      _activeSuggestions.removeWhere(
        (s) => s.sourceTransaction.id == tx.id ||
            s.candidateTransaction.id == tx.id ||
            s.sourceTransaction.id == bestCandidate!.id ||
            s.candidateTransaction.id == bestCandidate.id,
      );
      _notifySuggestionListeners();

      return TransferMatchResult(
        sourceTransactionId: tx.id,
        candidateTransactionId: bestCandidate.id,
        confidence: TransferConfidence.high,
        transferPairId: pairId,
        reason: bestResult.reason,
      );
    } else {
      // Suggested match: check if already dismissed
      final suggestion = TransferSuggestion(
        sourceTransaction: tx,
        candidateTransaction: bestCandidate,
        reason: bestResult.reason,
        createdAt: DateTime.now(),
      );

      final isDismissed = await isSuggestionDismissed(suggestion.pairKey);
      if (!isDismissed) {
        // Add to active suggestions if not already present
        final exists = _activeSuggestions.any((s) => s.pairKey == suggestion.pairKey);
        if (!exists) {
          _activeSuggestions.add(suggestion);
          _notifySuggestionListeners();
        }
      }

      return bestResult;
    }
  }

  /// Atomically links two transactions with a shared [pairId] inside a database transaction.
  Future<String> linkPair(String txId1, String txId2, {String? pairId}) async {
    final finalPairId = pairId ?? 'tf_${_uuid.v4()}';
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.transaction(() async {
      final updatedRows = await _db.customUpdate(
        '''
        UPDATE transactions
        SET transfer_pair_id = ?, updated_at = ?
        WHERE id IN (?, ?) AND transfer_pair_id IS NULL
        ''',
        variables: [
          Variable.withString(finalPairId),
          Variable.withInt(now),
          Variable.withString(txId1),
          Variable.withString(txId2),
        ],
        updates: {_db.transactionsTable},
      );

      if (updatedRows < 2) {
        // One or both transactions could not be linked (e.g. already linked or deleted)
        _logger.w('Attempted to link $txId1 and $txId2 but only updated $updatedRows rows.');
      }
    });

    _db.markTablesUpdated({_db.transactionsTable});

    // Remove from in-memory suggestions
    _activeSuggestions.removeWhere(
      (s) => (s.sourceTransaction.id == txId1 && s.candidateTransaction.id == txId2) ||
          (s.sourceTransaction.id == txId2 && s.candidateTransaction.id == txId1),
    );
    _notifySuggestionListeners();

    return finalPairId;
  }

  /// Unlinks a self-transfer pair by setting `transfer_pair_id = NULL` on both rows atomically.
  Future<void> unlinkPair(String transferPairId) async {
    if (transferPairId.trim().isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.transaction(() async {
      await _db.customUpdate(
        '''
        UPDATE transactions
        SET transfer_pair_id = NULL, updated_at = ?
        WHERE transfer_pair_id = ?
        ''',
        variables: [
          Variable.withInt(now),
          Variable.withString(transferPairId),
        ],
        updates: {_db.transactionsTable},
      );
    });

    _db.markTablesUpdated({_db.transactionsTable});
    _logger.i('Unlinked self-transfer pair $transferPairId');
  }

  /// Unlinks whichever transfer pair is associated with [txId].
  Future<void> unlinkByTransactionId(String txId) async {
    final rows = await _db.customSelect(
      'SELECT transfer_pair_id FROM transactions WHERE id = ? AND transfer_pair_id IS NOT NULL LIMIT 1',
      variables: [Variable.withString(txId)],
      readsFrom: {_db.transactionsTable},
    ).get();

    if (rows.isNotEmpty) {
      final pairId = rows.first.read<String?>('transfer_pair_id');
      if (pairId != null) {
        await unlinkPair(pairId);
      }
    }
  }

  /// Retrieves the counterpart transaction for a linked self-transfer.
  Future<Transaction?> getCounterpart(Transaction tx) async {
    if (!tx.isSelfTransfer || tx.transferPairId == null) return null;

    final rows = await _db.customSelect(
      'SELECT * FROM transactions WHERE transfer_pair_id = ? AND id != ? LIMIT 1',
      variables: [
        Variable.withString(tx.transferPairId!),
        Variable.withString(tx.id),
      ],
      readsFrom: {_db.transactionsTable},
    ).get();

    if (rows.isEmpty) return null;
    return _mapToDomain(_db.transactionsTable.map(rows.first.data));
  }

  /// Dismisses a suggested transfer match permanently across app restarts.
  Future<void> dismissSuggestion(String pairKey) async {
    _activeSuggestions.removeWhere((s) => s.pairKey == pairKey);
    _notifySuggestionListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedList = prefs.getStringList(_kDismissedSuggestionsKey) ?? [];
      if (!dismissedList.contains(pairKey)) {
        dismissedList.add(pairKey);
        await prefs.setStringList(_kDismissedSuggestionsKey, dismissedList);
      }
    } catch (e) {
      _logger.w('Failed to persist dismissed suggestion key $pairKey: $e');
    }
  }

  /// Checks if a suggested transfer match was dismissed.
  Future<bool> isSuggestionDismissed(String pairKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedList = prefs.getStringList(_kDismissedSuggestionsKey) ?? [];
      return dismissedList.contains(pairKey);
    } catch (_) {
      return false;
    }
  }

  /// Scans unlinked transactions in the current month to populate pending suggestions on startup.
  Future<List<TransferSuggestion>> scanAllPendingSuggestions() async {
    final unlinkedRows = await _db.customSelect(
      '''
      SELECT * FROM transactions
      WHERE transfer_pair_id IS NULL
      ORDER BY date DESC
      LIMIT 100
      ''',
      readsFrom: {_db.transactionsTable},
    ).get();

    final unlinked = unlinkedRows.map((r) => _mapToDomain(_db.transactionsTable.map(r.data))).toList();
    final suggestions = <TransferSuggestion>[];

    for (int i = 0; i < unlinked.length; i++) {
      for (int j = i + 1; j < unlinked.length; j++) {
        final eval = evaluateMatch(unlinked[i], unlinked[j]);
        if (eval != null && eval.confidence == TransferConfidence.suggested) {
          final sug = TransferSuggestion(
            sourceTransaction: unlinked[i],
            candidateTransaction: unlinked[j],
            reason: eval.reason,
            createdAt: DateTime.now(),
          );
          if (!await isSuggestionDismissed(sug.pairKey)) {
            if (!suggestions.any((s) => s.pairKey == sug.pairKey)) {
              suggestions.add(sug);
            }
          }
        }
      }
    }

    _activeSuggestions.clear();
    _activeSuggestions.addAll(suggestions);
    _notifySuggestionListeners();
    return activeSuggestions;
  }
}
