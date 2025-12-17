import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_spacing.dart';

/// Reusable status card component
/// Displays status information with icon, title, and subtitle
class StatusCard extends StatelessWidget {
  /// Creates a status card
  const StatusCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    super.key,
  });

  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Optional icon color (defaults to primary)
  final Color? iconColor;

  /// Optional background color (defaults to primary container)
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            // Icon Container
            Container(
              width: AppSpacing.iconLarge,
              height: AppSpacing.iconLarge,
              decoration: BoxDecoration(
                color: backgroundColor ?? colorScheme.primaryContainer,
                borderRadius: AppSpacing.borderRadiusSmall,
              ),
              child: Icon(
                icon,
                color: iconColor ?? colorScheme.onPrimaryContainer,
                size: AppSpacing.iconMedium,
              ),
            ),
            AppSpacing.gapMd,

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
