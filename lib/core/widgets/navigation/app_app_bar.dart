import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showGlassEffect;

  const AppAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showGlassEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget appBar = AppBar(
      backgroundColor: showGlassEffect ? AppColors.darkSurfaceGlass : Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
      ),
      leading: leading,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
    );

    if (showGlassEffect) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: appBar,
        ),
      );
    }
    return appBar;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
