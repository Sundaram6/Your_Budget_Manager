import '../../../../features/transactions/domain/entities/transaction.dart';

enum TransferConfidence {
  high,
  suggested,
}

class TransferMatchResult {
  final String sourceTransactionId;
  final String candidateTransactionId;
  final TransferConfidence confidence;
  final String? transferPairId;
  final String reason;

  const TransferMatchResult({
    required this.sourceTransactionId,
    required this.candidateTransactionId,
    required this.confidence,
    this.transferPairId,
    required this.reason,
  });

  bool get isAutoLinked => confidence == TransferConfidence.high;
}

class TransferSuggestion {
  final Transaction sourceTransaction;
  final Transaction candidateTransaction;
  final String reason;
  final DateTime createdAt;

  const TransferSuggestion({
    required this.sourceTransaction,
    required this.candidateTransaction,
    required this.reason,
    required this.createdAt,
  });

  /// Deterministic symmetric key so suggestion(A, B) and suggestion(B, A) share the same key.
  String get pairKey {
    final ids = [sourceTransaction.id, candidateTransaction.id]..sort();
    return 'sug_${ids[0]}_${ids[1]}';
  }
}
