import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';
import 'package:your_budget_manager/engines/backup/backup_engine_provider.dart';
import 'package:your_budget_manager/features/backup/presentation/controllers/backup_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late BackupEngine backupEngine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backupEngine = BackupEngine(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('BackupController initial state is idle with no errors', () {
    final container = ProviderContainer(
      overrides: [
        backupEngineProvider.overrideWithValue(backupEngine),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(backupControllerProvider);
    expect(state.isExporting, false);
    expect(state.isImporting, false);
    expect(state.isLoading, false);
    expect(state.errorMessage, isNull);
    expect(state.successMessage, isNull);
    expect(state.statusMessage, isNull);
  });

  test('BackupController clearMessages resets error and success messages', () {
    final container = ProviderContainer(
      overrides: [
        backupEngineProvider.overrideWithValue(backupEngine),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(backupControllerProvider.notifier);
    notifier.clearMessages();

    final state = container.read(backupControllerProvider);
    expect(state.errorMessage, isNull);
    expect(state.successMessage, isNull);
  });
}
