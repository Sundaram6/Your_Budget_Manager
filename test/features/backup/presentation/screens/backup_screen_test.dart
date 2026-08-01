import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/features/backup/presentation/screens/backup_screen.dart';

void main() {
  testWidgets('BackupScreen renders Export and Import buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BackupScreen(),
        ),
      ),
    );

    expect(find.text('Export Backup'), findsOneWidget);
    expect(find.text('Import Backup'), findsOneWidget);
  });
}
