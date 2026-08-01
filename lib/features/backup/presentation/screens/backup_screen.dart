import 'package:flutter/material.dart';
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
