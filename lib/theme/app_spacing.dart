import 'package:flutter/material.dart';

/// Centralized spacing and sizing constants for the CamStar application
/// Uses an 8px base grid system for consistent spacing
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Spacing Scale (8px base grid)
  /// Extra small spacing - 4px
  static const double xs = 4.0;

  /// Small spacing - 8px
  static const double sm = 8.0;

  /// Medium spacing - 16px
  static const double md = 16.0;

  /// Large spacing - 24px
  static const double lg = 24.0;

  /// Extra large spacing - 32px
  static const double xl = 32.0;

  /// Extra extra large spacing - 48px
  static const double xxl = 48.0;

  // EdgeInsets Presets
  /// No padding
  static const EdgeInsets zero = EdgeInsets.zero;

  /// Extra small padding (4px all sides)
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);

  /// Small padding (8px all sides)
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);

  /// Medium padding (16px all sides)
  static const EdgeInsets paddingMd = EdgeInsets.all(md);

  /// Large padding (24px all sides)
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Extra large padding (32px all sides)
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  /// Extra extra large padding (48px all sides)
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  /// Horizontal small padding (8px horizontal)
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal medium padding (16px horizontal)
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal large padding (24px horizontal)
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical small padding (8px vertical)
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Vertical medium padding (16px vertical)
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  /// Vertical large padding (24px vertical)
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // Border Radius Constants
  /// Small border radius - 8px
  static const double radiusSmall = 8.0;

  /// Medium border radius - 12px
  static const double radiusMedium = 12.0;

  /// Large border radius - 16px
  static const double radiusLarge = 16.0;

  /// Extra large border radius - 20px
  static const double radiusXLarge = 20.0;

  /// Extra extra large border radius - 24px
  static const double radiusXxLarge = 24.0;

  /// Full circle border radius
  static const double radiusFull = 9999.0;

  // BorderRadius Presets
  /// Small border radius
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);

  /// Medium border radius
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);

  /// Large border radius
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);

  /// Extra large border radius
  static final BorderRadius borderRadiusXLarge = BorderRadius.circular(radiusXLarge);

  /// Extra extra large border radius
  static final BorderRadius borderRadiusXxLarge = BorderRadius.circular(radiusXxLarge);

  /// Full circle border radius
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // Icon Sizes
  /// Small icon - 20px
  static const double iconSmall = 20.0;

  /// Medium icon - 24px
  static const double iconMedium = 24.0;

  /// Large icon - 48px
  static const double iconLarge = 48.0;

  /// Extra large icon - 64px
  static const double iconXLarge = 64.0;

  /// Extra extra large icon - 80px
  static const double iconXxLarge = 80.0;

  // Button Sizes
  /// Button height
  static const double buttonHeight = 48.0;

  /// Small button height
  static const double buttonHeightSmall = 40.0;

  /// Large button height
  static const double buttonHeightLarge = 56.0;

  // Card Sizes
  /// Card elevation
  static const double cardElevation = 2.0;

  /// Card elevation hover
  static const double cardElevationHover = 4.0;

  // Divider Thickness
  /// Standard divider thickness
  static const double dividerThickness = 1.0;

  // Progress Indicator Sizes
  /// Progress indicator stroke width
  static const double progressIndicatorStroke = 3.0;

  // Gap Helpers (for Row/Column spacing)
  /// Extra small gap
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);

  /// Small gap
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);

  /// Medium gap
  static const SizedBox gapMd = SizedBox(width: md, height: md);

  /// Large gap
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);

  /// Extra large gap
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  /// Extra extra large gap
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
}
