import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_spacing.dart';

/// Modern card component with enhanced styling
class ModernCard extends StatelessWidget {
  /// Creates a modern card
  const ModernCard({
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    super.key,
  });

  /// Child widget
  final Widget child;

  /// Optional tap callback
  final VoidCallback? onTap;

  /// Optional custom padding (defaults to medium)
  final EdgeInsetsGeometry? padding;

  /// Optional custom margin (defaults to zero)
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final cardChild = Padding(
      padding: padding ?? AppSpacing.paddingMd,
      child: child,
    );

    return Card(
      margin: margin ?? EdgeInsets.zero,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: AppSpacing.borderRadiusLarge,
              child: cardChild,
            )
          : cardChild,
    );
  }
}

/// Icon card component with prominent icon display
class IconCard extends StatelessWidget {
  /// Creates an icon card
  const IconCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    super.key,
  });

  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Description text
  final String description;

  /// Optional tap callback
  final VoidCallback? onTap;

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

/// Info card component for displaying information with leading icon
class InfoCard extends StatelessWidget {
  /// Creates an info card
  const InfoCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  /// Leading icon
  final IconData icon;

  /// Title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Optional trailing widget
  final Widget? trailing;

  /// Optional tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusLarge,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Icon Container
              Container(
                width: AppSpacing.iconLarge,
                height: AppSpacing.iconLarge,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: AppSpacing.borderRadiusSmall,
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
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

              // Trailing
              if (trailing != null) ...[
                AppSpacing.gapMd,
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
