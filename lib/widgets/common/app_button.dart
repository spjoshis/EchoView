import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_colors.dart';
import 'package:cam_star/theme/app_spacing.dart';

/// Primary button component
/// Filled button for primary actions
class PrimaryButton extends StatelessWidget {
  /// Creates a primary button
  const PrimaryButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isFullWidth = true,
    super.key,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button label
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Whether button should take full width
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSpacing.iconSmall),
            label: Text(label),
          )
        : FilledButton(
            onPressed: onPressed,
            child: Text(label),
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Secondary button component
/// Outlined button for secondary actions
class SecondaryButton extends StatelessWidget {
  /// Creates a secondary button
  const SecondaryButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isFullWidth = true,
    super.key,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button label
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Whether button should take full width
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: AppSpacing.iconSmall),
            label: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label),
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// Danger button component
/// Red button for destructive actions (stop, disconnect, delete)
class DangerButton extends StatelessWidget {
  /// Creates a danger button
  const DangerButton({
    required this.onPressed,
    required this.label,
    this.icon,
    this.isFullWidth = true,
    super.key,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button label
  final String label;

  /// Optional leading icon
  final IconData? icon;

  /// Whether button should take full width
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final errorColor = brightness == Brightness.light
        ? AppColors.lightError
        : AppColors.darkError;

    final button = icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
            ),
            icon: Icon(icon, size: AppSpacing.iconSmall),
            label: Text(label),
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(label),
          );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
