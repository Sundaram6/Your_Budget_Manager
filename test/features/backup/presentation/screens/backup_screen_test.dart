import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/theme/app_theme.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';
import 'package:your_budget_manager/engines/backup/backup_engine_provider.dart';
import 'package:your_budget_manager/features/backup/presentation/controllers/backup_controller.dart';
import 'package:your_budget_manager/features/backup/presentation/screens/backup_screen.dart';

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

  testWidgets('BackupScreen renders cards, buttons and header properly in dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupEngineProvider.overrideWithValue(backupEngine),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BackupScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Backup & Restore'), findsOneWidget);
    expect(find.text('Encrypted Local Storage'), findsOneWidget);
    expect(find.text('Export Backup'), findsNWidgets(2)); // Card title + button label
    expect(find.text('Restore from Backup'), findsOneWidget);
    expect(find.text('Choose Backup File'), findsOneWidget);
  });

  testWidgets('BackupScreen renders loading banner when isExporting is true', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupEngineProvider.overrideWithValue(backupEngine),
          backupControllerProvider.overrideWith(() => _MockLoadingBackupController()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BackupScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Encrypting database payload in background...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });
}

class _MockLoadingBackupController extends BackupController {
  @override
  BackupState build() {
    return const BackupState(
      isExporting: true,
      statusMessage: 'Encrypting database payload in background...',
    );
  }
}
