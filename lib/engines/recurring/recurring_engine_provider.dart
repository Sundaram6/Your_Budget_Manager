import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'recurring_engine.dart';

part 'recurring_engine_provider.g.dart';

@Riverpod(keepAlive: true)
RecurringEngine recurringEngine(Ref ref) {
  return const RecurringEngine();
}
