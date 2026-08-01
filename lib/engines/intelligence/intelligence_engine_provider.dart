import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'intelligence_engine.dart';

part 'intelligence_engine_provider.g.dart';

@Riverpod(keepAlive: true)
IntelligenceEngine intelligenceEngine(IntelligenceEngineRef ref) {
  return IntelligenceEngine();
}
