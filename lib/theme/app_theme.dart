import 'package:flutter/material.dart';
import 'package:cam_star/theme/app_colors.dart';
import 'package:cam_star/theme/app_spacing.dart';
import 'package:cam_star/theme/app_shadows.dart';

/// Centralized theme configuration for the CamStar application
/// Provides complete ThemeData objects for light and dark modes
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimaryContainer: AppColors.lightOnPrimaryContainer,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnPrimary,
        secondaryContainer: AppColors.lightSecondaryContainer,
        onSecondaryContainer: AppColors.lightOnSecondaryContainer,
        error: AppColors.lightError,
        onError: AppColors.lightOnPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        outline: AppColors.lightBorder,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: AppShadows.elevationLow,
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        iconTheme: IconThemeData(
          color: AppColors.lightOnSurface,
          size: AppSpacing.iconMedium,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
          letterSpacing: 0,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppShadows.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLarge,
        ),
        color: AppColors.lightSurface,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppShadows.elevationLow,
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeight),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeight),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          side: const BorderSide(
            color: AppColors.lightBorder,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeight),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppShadows.elevationHigh,
        backgroundColor: AppColors.lightSecondary,
        foregroundColor: AppColors.lightOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLarge,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.lightOnSurface,
        size: AppSpacing.iconMedium,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.lightBorder,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.md,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.lightPrimary,
        circularTrackColor: AppColors.lightBorder,
        linearTrackColor: AppColors.lightBorder,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightPrimaryContainer,
        deleteIconColor: AppColors.lightOnPrimaryContainer,
        labelStyle: TextStyle(
          color: AppColors.lightOnPrimaryContainer,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(
            color: AppColors.lightPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.lightError),
        ),
        contentPadding: AppSpacing.paddingMd,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnPrimary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkOnSecondaryContainer,
        error: AppColors.darkError,
        onError: AppColors.darkOnPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkBorder,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: AppShadows.elevationLow,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        iconTheme: IconThemeData(
          color: AppColors.darkOnSurface,
          size: AppSpacing.iconMedium,
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppShadows.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLarge,
        ),
        color: AppColors.darkSurface,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppShadows.elevationLow,
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeight),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeight),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(
            color: AppColors.darkBorder,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          minimumSize: const Size(0, AppSpacing.buttonHeight),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMedium,
          ),
          padding: AppSpacing.paddingHorizontalMd.copyWith(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppShadows.elevationHigh,
        backgroundColor: AppColors.darkSecondary,
        foregroundColor: AppColors.darkOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLarge,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.darkOnSurface,
        size: AppSpacing.iconMedium,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.md,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.darkPrimary,
        circularTrackColor: AppColors.darkBorder,
        linearTrackColor: AppColors.darkBorder,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkPrimaryContainer,
        deleteIconColor: AppColors.darkOnPrimaryContainer,
        labelStyle: TextStyle(
          color: AppColors.darkOnPrimaryContainer,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(
            color: AppColors.darkPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        contentPadding: AppSpacing.paddingMd,
      ),
    );
  }
}
