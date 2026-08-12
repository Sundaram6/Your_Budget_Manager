import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_engine.dart';

part 'notification_engine_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationEngine notificationEngine(Ref ref) {
  return NotificationEngine();
}
