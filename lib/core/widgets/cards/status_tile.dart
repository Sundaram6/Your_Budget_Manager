import 'package:flutter/material.dart';

import '../../theme/app_custom_tokens.dart';

class StatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color statusColor;
  final VoidCallback? onTap;

  const StatusTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppCustomTokens>()!;
    
    // The surface uses the theme's card color but tinted with the statusColor based on the theme's statusTileTintOpacity
    final Color baseCardColor = theme.colorScheme.surface;
    final Color tintedSurface = Color.alphaBlend(
      statusColor.withOpacity(tokens.statusTileTintOpacity), 
      baseCardColor
    );

    return Material(
      color: tintedSurface,
      borderRadius: BorderRadius.circular(tokens.cardBorderRadius / 1.5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(tokens.gridUnit * 2),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.gridUnit),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              SizedBox(width: tokens.gridUnit * 1.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
