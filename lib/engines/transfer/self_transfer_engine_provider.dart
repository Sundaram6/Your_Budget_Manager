import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import 'models/transfer_match_result.dart';
import 'self_transfer_engine.dart';

part 'self_transfer_engine_provider.g.dart';

@Riverpod(keepAlive: true)
SelfTransferEngine selfTransferEngine(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return SelfTransferEngine(db);
}

@Riverpod(keepAlive: true)
class TransferSuggestionsNotifier extends _$TransferSuggestionsNotifier {
  @override
  List<TransferSuggestion> build() {
    final engine = ref.watch(selfTransferEngineProvider);

    void listener(List<TransferSuggestion> suggestions) {
      state = List.of(suggestions);
    }

    engine.addSuggestionListener(listener);
    ref.onDispose(() => engine.removeSuggestionListener(listener));

    // Run initial scan on startup
    Future.microtask(() => engine.scanAllPendingSuggestions());

    return engine.activeSuggestions;
  }

  Future<void> linkSuggestion(TransferSuggestion suggestion) async {
    final engine = ref.read(selfTransferEngineProvider);
    await engine.linkPair(suggestion.sourceTransaction.id, suggestion.candidateTransaction.id);
  }

  Future<void> dismissSuggestion(TransferSuggestion suggestion) async {
    final engine = ref.read(selfTransferEngineProvider);
    await engine.dismissSuggestion(suggestion.pairKey);
  }
}
