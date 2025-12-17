import 'package:flutter/material.dart';

/// Centralized color palette for the CamStar application
/// Based on modern design principles with soft backgrounds and navy accents
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Light Mode Colors
  /// Soft blue-gray background color - #F1F5F9
  static const Color lightBackground = Color(0xFFF1F5F9);

  /// Pure white surface color
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Navy/slate primary color - #1E293B
  static const Color lightPrimary = Color(0xFF1E293B);

  /// Blue accent color - #3B82F6
  static const Color lightSecondary = Color(0xFF3B82F6);

  /// Error/Stop action color - #EF4444
  static const Color lightError = Color(0xFFEF4444);

  /// Success/Connected status color - #10B981
  static const Color lightSuccess = Color(0xFF10B981);

  /// Warning color - #F59E0B
  static const Color lightWarning = Color(0xFFF59E0B);

  /// Text on background - #0F172A
  static const Color lightOnBackground = Color(0xFF0F172A);

  /// Text on surface - #0F172A
  static const Color lightOnSurface = Color(0xFF0F172A);

  /// Text on primary - #FFFFFF
  static const Color lightOnPrimary = Color(0xFFFFFFFF);

  /// Secondary text color - #64748B
  static const Color lightOnSurfaceVariant = Color(0xFF64748B);

  /// Primary container - #E0E7FF
  static const Color lightPrimaryContainer = Color(0xFFE0E7FF);

  /// On primary container - #1E3A8A
  static const Color lightOnPrimaryContainer = Color(0xFF1E3A8A);

  /// Secondary container - #DBEAFE
  static const Color lightSecondaryContainer = Color(0xFFDBEAFE);

  /// On secondary container - #1E40AF
  static const Color lightOnSecondaryContainer = Color(0xFF1E40AF);

  // Dark Mode Colors
  /// Dark background - #0F172A
  static const Color darkBackground = Color(0xFF0F172A);

  /// Dark surface - #1E293B
  static const Color darkSurface = Color(0xFF1E293B);

  /// Light primary for dark mode - #E0E7FF
  static const Color darkPrimary = Color(0xFFE0E7FF);

  /// Blue accent for dark mode - #60A5FA
  static const Color darkSecondary = Color(0xFF60A5FA);

  /// Error color for dark mode - #F87171
  static const Color darkError = Color(0xFFF87171);

  /// Success color for dark mode - #34D399
  static const Color darkSuccess = Color(0xFF34D399);

  /// Warning color for dark mode - #FBBF24
  static const Color darkWarning = Color(0xFFFBBF24);

  /// Text on dark background - #F1F5F9
  static const Color darkOnBackground = Color(0xFFF1F5F9);

  /// Text on dark surface - #F1F5F9
  static const Color darkOnSurface = Color(0xFFF1F5F9);

  /// Text on dark primary - #1E293B
  static const Color darkOnPrimary = Color(0xFF1E293B);

  /// Secondary text on dark - #94A3B8
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);

  /// Primary container dark - #1E3A8A
  static const Color darkPrimaryContainer = Color(0xFF1E3A8A);

  /// On primary container dark - #E0E7FF
  static const Color darkOnPrimaryContainer = Color(0xFFE0E7FF);

  /// Secondary container dark - #1E40AF
  static const Color darkSecondaryContainer = Color(0xFF1E40AF);

  /// On secondary container dark - #DBEAFE
  static const Color darkOnSecondaryContainer = Color(0xFFDBEAFE);

  // Semantic Colors (work for both light and dark modes based on context)
  /// Live broadcasting indicator
  static const Color live = Color(0xFFEF4444);

  /// Connected status
  static const Color connected = Color(0xFF10B981);

  /// Disconnected/error status
  static const Color disconnected = Color(0xFF64748B);

  /// Border color light
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// Border color dark
  static const Color darkBorder = Color(0xFF334155);
}
