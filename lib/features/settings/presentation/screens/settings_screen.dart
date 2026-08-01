import 'package:flutter/material.dart';
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
          const ListTile(title: Text('Security')),
          const ListTile(title: Text('Categories')),
          ListTile(
            title: const Text('Recurring'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringTransactionsScreen())),
          ),
          ListTile(
            title: const Text('Backup'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen())),
          ),
          const ListTile(title: Text('Appearance')),
          const ListTile(title: Text('About')),
        ],
      ),
    );
  }
}
