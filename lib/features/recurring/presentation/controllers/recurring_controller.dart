import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../engines/recurring/recurring_engine_provider.dart';
import '../../domain/entities/recurring_transaction.dart';

part 'recurring_controller.g.dart';

@riverpod
class RecurringController extends _$RecurringController {
  @override
  Stream<List<RecurringTransaction>> build() {
    return ref.watch(recurringEngineProvider).watchAll();
  }
}
