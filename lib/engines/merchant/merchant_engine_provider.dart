import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../expense/expense_engine_provider.dart';
import 'merchant_engine.dart';

part 'merchant_engine_provider.g.dart';

@Riverpod(keepAlive: true)
MerchantEngine merchantEngine(Ref ref) {
  final smsQuery = SmsQuery();
  final logger = Logger();
  final expenseEngine = ref.watch(expenseEngineProvider);
  return MerchantEngine(smsQuery, logger, expenseEngine);
}
