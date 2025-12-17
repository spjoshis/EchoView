import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_spacing.dart';
import 'package:cam_star/theme/app_text_styles.dart';

/// Reusable status badge component
/// Displays a colored badge with text and optional icon (e.g., "LIVE", "Connected")
class StatusBadge extends StatelessWidget {
  /// Creates a status badge
  const StatusBadge({
    required this.text,
    required this.color,
    this.icon,
    this.showPulse = false,
    super.key,
  });

  /// Text to display in the badge
  final String text;

  /// Background color of the badge
  final Color color;

  /// Optional icon to display
  final IconData? icon;

  /// Whether to show a pulsing animation (for live indicators)
  final bool showPulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppSpacing.borderRadiusXLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            _PulsingDot(color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSpacing.iconSmall,
              color: Colors.white,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: AppTextStyles.badgeText.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot animation for live status badges
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.color,
  });

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
