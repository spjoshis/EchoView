import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_spacing.dart';

/// Control panel component
/// Container for grouped controls with consistent styling
class ControlPanel extends StatelessWidget {
  /// Creates a control panel
  const ControlPanel({
    required this.title,
    required this.children,
    this.trailing,
    super.key,
  });

  /// Panel title
  final String title;

  /// Control widgets
  final List<Widget> children;

  /// Optional trailing widget in title row
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMedium,
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Row
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outline,
          ),

          // Controls
          Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
