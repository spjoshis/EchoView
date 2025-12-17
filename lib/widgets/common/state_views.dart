import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_spacing.dart';

/// Reusable loading view component
/// Displays a centered circular progress indicator with optional message
class LoadingView extends StatelessWidget {
  /// Creates a loading view
  const LoadingView({
    this.message,
    super.key,
  });

  /// Optional message to display below the spinner
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: AppSpacing.progressIndicatorStroke,
            color: colorScheme.primary,
          ),
          if (message != null) ...[
            AppSpacing.gapMd,
            Text(
              message!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable error view component
/// Displays an error icon, message, and optional retry button
class ErrorView extends StatelessWidget {
  /// Creates an error view
  const ErrorView({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    super.key,
  });

  /// Error message to display
  final String message;

  /// Optional callback for retry button
  final VoidCallback? onRetry;

  /// Icon to display (defaults to error_outline)
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconXxLarge,
              color: colorScheme.error,
            ),
            AppSpacing.gapMd,
            Text(
              'Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.gapLg,
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: AppSpacing.iconSmall),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable empty view component
/// Displays an empty state icon, message, and optional action button
class EmptyView extends StatelessWidget {
  /// Creates an empty view
  const EmptyView({
    required this.message,
    this.icon = Icons.search_off,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Message to display
  final String message;

  /// Icon to display (defaults to search_off)
  final IconData icon;

  /// Optional action button label
  final String? actionLabel;

  /// Optional action button callback
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconXxLarge,
              color: colorScheme.onSurfaceVariant,
            ),
            AppSpacing.gapMd,
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapLg,
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable placeholder view component
/// Displays a generic placeholder with icon and optional message
class PlaceholderView extends StatelessWidget {
  /// Creates a placeholder view
  const PlaceholderView({
    required this.icon,
    required this.message,
    this.subtitle,
    super.key,
  });

  /// Icon to display
  final IconData icon;

  /// Main message
  final String message;

  /// Optional subtitle
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconXxLarge,
              color: colorScheme.primary,
            ),
            AppSpacing.gapMd,
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.gapSm,
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
