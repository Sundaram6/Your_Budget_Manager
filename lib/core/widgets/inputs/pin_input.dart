import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PinInput extends StatelessWidget {
  final int length;
  final String value;

  const PinInput({
    super.key,
    this.length = 4,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final bool isFilled = index < value.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.darkGoldPrimary : AppColors.darkSurface3,
            boxShadow: isFilled
                ? [
                    const BoxShadow(
                      color: AppColors.darkGoldGlow,
                      blurRadius: 8,
                      offset: Offset(0, 0),
                    )
                  ]
                : [],
          ),
        );
      }),
    );
  }
}
