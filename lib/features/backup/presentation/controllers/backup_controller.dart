import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../engines/backup/backup_engine_provider.dart';

part 'backup_controller.g.dart';

class BackupState {
  final bool isExporting;
  final bool isImporting;
  final String? statusMessage;
  final String? errorMessage;
  final String? successMessage;
  final DateTime? lastExportDate;

  const BackupState({
    this.isExporting = false,
    this.isImporting = false,
    this.statusMessage,
    this.errorMessage,
    this.successMessage,
    this.lastExportDate,
  });

  bool get isLoading => isExporting || isImporting;

  BackupState copyWith({
    bool? isExporting,
    bool? isImporting,
    String? statusMessage,
    String? errorMessage,
    String? successMessage,
    DateTime? lastExportDate,
    bool clearStatus = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BackupState(
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      lastExportDate: lastExportDate ?? this.lastExportDate,
    );
  }
}

@riverpod
class BackupController extends _$BackupController {
  @override
  BackupState build() {
    return const BackupState();
  }

  Future<bool> exportData(String passphrase) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      isExporting: true,
      statusMessage: 'Encrypting and preparing backup...',
      clearError: true,
      clearSuccess: true,
    );

    try {
      final encryptedData = await ref.read(backupEngineProvider).exportData(passphrase);
      state = state.copyWith(
        statusMessage: 'Sharing backup file...',
      );
      await Share.share(encryptedData, subject: 'My Budget Backup');
      state = state.copyWith(
        isExporting: false,
        clearStatus: true,
        successMessage: 'Backup exported and shared successfully.',
        lastExportDate: DateTime.now(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Backup export failed: $e');
      }
      state = state.copyWith(
        isExporting: false,
        clearStatus: true,
        errorMessage: 'Backup export failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> importData(String path, String passphrase) async {
    if (state.isLoading) return false;
    state = state.copyWith(
      isImporting: true,
      statusMessage: 'Validating and restoring backup...',
      clearError: true,
      clearSuccess: true,
    );

    try {
      final file = File(path);
      final encryptedData = await file.readAsString();
      await ref.read(backupEngineProvider).importData(encryptedData, passphrase);
      state = state.copyWith(
        isImporting: false,
        clearStatus: true,
        successMessage: 'Backup restored successfully. Database updated.',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Backup import failed: $e');
      }
      String friendlyError = 'Backup restore failed.';
      if (e is CryptographyException) {
        friendlyError = 'Decryption failed. Incorrect passphrase or corrupted backup file.';
      } else if (e is ValidationException) {
        friendlyError = 'Invalid backup structure: ${e.message}';
      } else {
        friendlyError = e.toString();
      }
      state = state.copyWith(
        isImporting: false,
        clearStatus: true,
        errorMessage: friendlyError,
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true, clearStatus: true);
  }
}

