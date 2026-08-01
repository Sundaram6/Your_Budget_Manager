import os

files = {
    'lib/features/budgets/presentation/screens/budget_overview_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/budget_controller.dart';
import '../widgets/budget_card.dart';

class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: state.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets found.'));
          }
          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              return BudgetCard(budget: budgets[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
''',
    'lib/features/budgets/presentation/screens/budget_detail_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../budgets/domain/entities/budget.dart';

class BudgetDetailScreen extends ConsumerWidget {
  final Budget budget;
  const BudgetDetailScreen({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Limit: \${budget.limit.value}'),
            // Trend chart placeholder
            const Expanded(child: Center(child: Text('Trend Chart Placeholder'))),
          ],
        ),
      ),
    );
  }
}
''',
    'lib/features/budgets/presentation/widgets/budget_card.dart': '''import 'package:flutter/material.dart';
import '../../../budgets/domain/entities/budget.dart';
import 'budget_progress_ring.dart';
import '../screens/budget_detail_screen.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text('Budget: \${budget.categoryId}'),
        subtitle: Text('Limit: \${budget.limit.value}'),
        trailing: BudgetProgressRing(progress: 0.5),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetDetailScreen(budget: budget)));
        },
      ),
    );
  }
}
''',
    'lib/features/budgets/presentation/widgets/budget_progress_ring.dart': '''import 'package:flutter/material.dart';

class BudgetProgressRing extends StatelessWidget {
  final double progress;
  const BudgetProgressRing({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(value: progress);
  }
}
''',
    'lib/features/budgets/presentation/controllers/budget_controller.dart': '''import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../domain/entities/budget.dart';

part 'budget_controller.g.dart';

@riverpod
class BudgetController extends _$BudgetController {
  @override
  FutureOr<List<Budget>> build() async {
    return ref.watch(budgetEngineProvider).watchBudgets().first;
  }
}
''',
    'lib/features/recurring/presentation/screens/recurring_transactions_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/recurring_controller.dart';
import '../widgets/recurring_tile.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recurringControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: state.when(
        data: (transactions) {
          if (transactions.isEmpty) return const Center(child: Text('No recurring transactions.'));
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return RecurringTile(transaction: transactions[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
''',
    'lib/features/recurring/presentation/widgets/recurring_tile.dart': '''import 'package:flutter/material.dart';
import '../../domain/entities/recurring_transaction.dart';

class RecurringTile extends StatelessWidget {
  final RecurringTransaction transaction;
  const RecurringTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Amount: \${transaction.amount.value}'),
      subtitle: Text('Frequency: \${transaction.frequency.name}'),
    );
  }
}
''',
    'lib/features/recurring/presentation/controllers/recurring_controller.dart': '''import 'package:riverpod_annotation/riverpod_annotation.dart';
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
''',
    'lib/features/backup/presentation/screens/backup_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/backup_controller.dart';
import 'package:file_picker/file_picker.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => ref.read(backupControllerProvider.notifier).exportData('password'),
              child: const Text('Export Backup'),
            ),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.single.path != null) {
                  ref.read(backupControllerProvider.notifier).importData(result.files.single.path!, 'password');
                }
              },
              child: const Text('Import Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
''',
    'lib/features/backup/presentation/controllers/backup_controller.dart': '''import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../engines/backup/backup_engine_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

part 'backup_controller.g.dart';

@riverpod
class BackupController extends _$BackupController {
  @override
  void build() {}

  Future<void> exportData(String passphrase) async {
    try {
      final encryptedData = await ref.read(backupEngineProvider).exportData(passphrase);
      await Share.share(encryptedData, subject: 'My Budget Backup');
    } catch (e) {
      print(e);
    }
  }

  Future<void> importData(String path, String passphrase) async {
    try {
      final file = File(path);
      final encryptedData = await file.readAsString();
      await ref.read(backupEngineProvider).importData(encryptedData, passphrase);
    } catch (e) {
      print(e);
    }
  }
}
''',
    'lib/features/settings/presentation/screens/settings_screen.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../backup/presentation/screens/backup_screen.dart';
import '../../../recurring/presentation/screens/recurring_transactions_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(title: const Text('Security')),
          ListTile(title: const Text('Categories')),
          ListTile(
            title: const Text('Recurring'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringTransactionsScreen())),
          ),
          ListTile(
            title: const Text('Backup'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())),
          ),
          ListTile(title: const Text('Appearance')),
          ListTile(title: const Text('About')),
        ],
      ),
    );
  }
}
''',
    'lib/features/settings/presentation/controllers/settings_controller.dart': '''import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  void build() {}
}
'''
}

for filepath, content in files.items():
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, 'w') as f:
        f.write(content)
