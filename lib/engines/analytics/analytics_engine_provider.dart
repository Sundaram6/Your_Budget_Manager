import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import 'analytics_engine.dart';

part 'analytics_engine_provider.g.dart';

@Riverpod(keepAlive: true)
AnalyticsEngine analyticsEngine(Ref ref) {
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);
  return AnalyticsEngine(txRepo, catRepo);
}
