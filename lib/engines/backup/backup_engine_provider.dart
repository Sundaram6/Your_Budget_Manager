import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import 'backup_engine.dart';

part 'backup_engine_provider.g.dart';

@Riverpod(keepAlive: true)
BackupEngine backupEngine(BackupEngineRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupEngine(db);
}
