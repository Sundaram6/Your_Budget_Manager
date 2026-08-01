import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../engines/backup/backup_engine_provider.dart';

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
      debugPrint(e.toString());
    }
  }

  Future<void> importData(String path, String passphrase) async {
    try {
      final file = File(path);
      final encryptedData = await file.readAsString();
      await ref.read(backupEngineProvider).importData(encryptedData, passphrase);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
