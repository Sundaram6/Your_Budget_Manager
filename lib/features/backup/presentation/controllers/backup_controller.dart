import 'package:riverpod_annotation/riverpod_annotation.dart';
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
