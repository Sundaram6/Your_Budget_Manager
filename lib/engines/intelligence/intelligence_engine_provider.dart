import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import 'intelligence_engine.dart';

part 'intelligence_engine_provider.g.dart';

@riverpod
IntelligenceEngine intelligenceEngine(IntelligenceEngineRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return IntelligenceEngine(
    transactionDao: db.transactionDao,
    categoryDao: db.categoryDao,
  );
}
