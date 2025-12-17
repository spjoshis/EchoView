import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_spacing.dart';

/// A reusable card widget for displaying mode selection options
class ModeSelectionCard extends StatelessWidget {
  /// Creates a mode selection card
  const ModeSelectionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    super.key,
  });

  /// The title text displayed on the card
  final String title;

  /// The description text explaining what this mode does
  final String description;

  /// The icon to display on the card
  final IconData icon;

  /// Callback function when the card is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                icon,
                size: AppSpacing.iconXLarge,
                color: colorScheme.primary,
              ),
              AppSpacing.gapMd,

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapSm,

              // Description
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
