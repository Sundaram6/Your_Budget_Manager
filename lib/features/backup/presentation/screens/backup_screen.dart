import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_custom_tokens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/ghost_button.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/cards/glass_card.dart';
import '../../../../core/widgets/feedback/app_dialog.dart';
import '../controllers/backup_controller.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  Future<String?> _promptPassphrase({
    required String title,
    required String message,
    required String confirmLabel,
    String defaultPassphrase = 'password',
  }) async {
    final controller = TextEditingController(text: defaultPassphrase);
    bool obscure = true;

    return showDialog<String>(
      context: context,
      barrierColor: AppColors.darkCanvas.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.darkGoldPrimary, size: 22),
                    const SizedBox(width: AppSpacing.space2),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  message,
                  style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: AppSpacing.space4),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(color: AppColors.darkTextPrimary),
                  decoration: InputDecoration(
                    labelText: 'Passphrase',
                    labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                    filled: true,
                    fillColor: AppColors.darkSurface2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.darkBorderGlass),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.darkGoldPrimary),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.darkTextSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          obscure = !obscure;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(null),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.darkTextSecondary)),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGoldPrimary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        Navigator.of(ctx).pop(text.isEmpty ? defaultPassphrase : text);
                      },
                      child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    final passphrase = await _promptPassphrase(
      title: 'Export Encryption Passphrase',
      message: 'Choose a passphrase to encrypt your backup. You will need this passphrase to restore your data.',
      confirmLabel: 'Export & Share',
    );

    if (passphrase == null || !mounted) return;

    await ref.read(backupControllerProvider.notifier).exportData(passphrase);
  }

  Future<void> _handleImport() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null || !mounted) return;

    final passphrase = await _promptPassphrase(
      title: 'Restore Decryption Passphrase',
      message: 'Enter the passphrase that was used when creating this backup.',
      confirmLabel: 'Validate & Restore',
    );

    if (passphrase == null || !mounted) return;

    await ref.read(backupControllerProvider.notifier).importData(result.files.single.path!, passphrase);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCustomTokens>() ?? AppCustomTokens.dark;
    final backupState = ref.watch(backupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Feedback Banners
            if (backupState.isLoading) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkGoldPrimary.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.darkGoldPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        backupState.statusMessage ?? 'Processing backup in background...',
                        style: AppTypography.bodyBase.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (backupState.errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.accentAlert.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentAlert.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.accentAlert, size: 22),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        backupState.errorMessage!,
                        style: AppTypography.bodyBase.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.darkTextSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => ref.read(backupControllerProvider.notifier).clearMessages(),
                    ),
                  ],
                ),
              ),
            ],

            if (backupState.successMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                padding: const EdgeInsets.all(AppSpacing.space4),
                decoration: BoxDecoration(
                  color: AppColors.accentSavings.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentSavings.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.accentSavings, size: 22),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: Text(
                        backupState.successMessage!,
                        style: AppTypography.bodyBase.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.darkTextSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => ref.read(backupControllerProvider.notifier).clearMessages(),
                    ),
                  ],
                ),
              ),
            ],

            // Security Header Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkGoldPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.darkGoldPrimary, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Encrypted Local Storage',
                          style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your data is encrypted with AES-256-CBC and PBKDF2. Backups can only be decrypted with your passphrase.',
                          style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space3),

            // Export Section
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upload_file_outlined, color: AppColors.accentTransport, size: 22),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        'Export Backup',
                        style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'Export all transactions, categories, budgets, recurring expenses, and savings goals into an encrypted payload.',
                    style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  PrimaryButton(
                    label: backupState.isExporting ? 'Exporting...' : 'Export Backup',
                    icon: const Icon(Icons.share_outlined, size: 20, color: Colors.black),
                    isLoading: backupState.isExporting,
                    onPressed: backupState.isLoading ? null : _handleExport,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space3),

            // Import Section
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download_for_offline_outlined, color: AppColors.accentShopping, size: 22),
                      const SizedBox(width: AppSpacing.space2),
                      Text(
                        'Restore from Backup',
                        style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'Restore from a previously exported backup file. Pre-validated before database replacement.',
                    style: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  GhostButton(
                    label: backupState.isImporting ? 'Restoring...' : 'Choose Backup File',
                    icon: const Icon(Icons.folder_open_outlined, size: 20, color: AppColors.darkTextPrimary),
                    onPressed: backupState.isLoading ? null : _handleImport,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


