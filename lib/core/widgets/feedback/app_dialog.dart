import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../cards/glass_card.dart';
import '../buttons/primary_button.dart';
import '../buttons/ghost_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? cancelText;
  final VoidCallback? onCancel;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.confirmText,
    required this.onConfirm,
    this.cancelText,
    this.onCancel,
  });

  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors.darkCanvas.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.space6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.space3),
            Text(
              message!,
              style: AppTypography.bodyBase.copyWith(color: AppColors.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (content != null) ...[
            const SizedBox(height: AppSpacing.space4),
            content!,
          ],
          const SizedBox(height: AppSpacing.space6),
          PrimaryButton(
            label: confirmText,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
          ),
          if (cancelText != null) ...[
            const SizedBox(height: AppSpacing.space2),
            GhostButton(
              label: cancelText!,
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancel != null) onCancel!();
              },
            ),
          ],
        ],
      ),
    );
  }
}
