import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../engines/sms/models/parsed_transaction.dart';
import '../../../../engines/sms/sms_parser_engine_provider.dart';

part 'sms_scan_controller.g.dart';

@riverpod
class SmsScanController extends _$SmsScanController {
  @override
  AsyncValue<List<ParsedTransaction>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> requestPermissionAndScan() async {
    state = const AsyncValue.loading();
    try {
      final status = await Permission.sms.request();
      if (status.isGranted) {
        final parser = ref.read(smsParserEngineProvider);
        final transactions = await parser.scanInbox(count: 100);
        state = AsyncValue.data(transactions);
      } else {
        state = AsyncValue.error('SMS permission denied', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
