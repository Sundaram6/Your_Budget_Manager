import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  const AmountInput({
    super.key,
    this.controller,
    this.onChanged,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '₹',
          style: AppTypography.heading1.copyWith(
            color: AppColors.darkTextTertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.space1),
        IntrinsicWidth(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: autoFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.displayXL.copyWith(
              color: AppColors.darkTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: AppTypography.displayXL.copyWith(
                color: AppColors.darkTextTertiary.withOpacity(0.5),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
