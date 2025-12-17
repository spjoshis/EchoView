import 'package:flutter/material.dart';

/// Centralized shadow and elevation system for the CamStar application
/// Provides consistent shadow styles matching the modern design reference
class AppShadows {
  AppShadows._(); // Private constructor to prevent instantiation

  // Elevation Levels
  /// No elevation
  static const double elevationNone = 0.0;

  /// Subtle elevation - 1dp
  static const double elevationSubtle = 1.0;

  /// Low elevation - 2dp (default for cards)
  static const double elevationLow = 2.0;

  /// Medium elevation - 4dp (for hover states, bottom sheets)
  static const double elevationMedium = 4.0;

  /// High elevation - 8dp (for FABs, dialogs)
  static const double elevationHigh = 8.0;

  /// Very high elevation - 12dp (for modal overlays)
  static const double elevationVeryHigh = 12.0;

  /// Maximum elevation - 24dp (for full-screen overlays)
  static const double elevationMax = 24.0;

  // Shadow Definitions
  /// Subtle shadow for minimal elevation
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for cards and elevated elements
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Elevated shadow for prominent elements like dialogs
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// High shadow for floating action buttons and modals
  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Dark Mode Shadows (lighter shadows for dark backgrounds)
  /// Subtle shadow for dark mode
  static const List<BoxShadow> darkSubtle = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for dark mode
  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Elevated shadow for dark mode
  static const List<BoxShadow> darkElevated = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 20,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 10,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  // Helper method to get appropriate shadow based on theme brightness
  /// Returns the appropriate shadow list based on theme brightness
  static List<BoxShadow> getShadow(Brightness brightness, ShadowLevel level) {
    final isDark = brightness == Brightness.dark;

    switch (level) {
      case ShadowLevel.subtle:
        return isDark ? darkSubtle : subtle;
      case ShadowLevel.medium:
        return isDark ? darkMedium : medium;
      case ShadowLevel.elevated:
        return isDark ? darkElevated : elevated;
      case ShadowLevel.high:
        return isDark ? darkElevated : high;
    }
  }
}

/// Enum for shadow levels to make shadow selection more semantic
enum ShadowLevel {
  /// Subtle shadow (minimal elevation)
  subtle,

  /// Medium shadow (standard cards)
  medium,

  /// Elevated shadow (dialogs, bottom sheets)
  elevated,

  /// High shadow (FABs, modals)
  high,
}
