import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'sms_parser_engine.dart';

part 'sms_parser_engine_provider.g.dart';

@riverpod
SmsQuery smsQuery(SmsQueryRef ref) {
  return SmsQuery();
}

@riverpod
SmsParserEngine smsParserEngine(SmsParserEngineRef ref) {
  final query = ref.watch(smsQueryProvider);
  return SmsParserEngine(query, Logger());
}
