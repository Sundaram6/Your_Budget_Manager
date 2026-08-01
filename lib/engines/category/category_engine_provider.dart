import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import 'category_engine.dart';

part 'category_engine_provider.g.dart';

@Riverpod(keepAlive: true)
CategoryEngine categoryEngine(CategoryEngineRef ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryEngine(repository);
}
