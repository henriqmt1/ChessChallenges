import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
          primary: AppColors.primary,
          error: AppColors.danger,
          surface: isDark ? AppColors.darkSurface : AppColors.surface,
        ).copyWith(
          onSurface: isDark ? AppColors.darkInk : AppColors.ink,
          onSurfaceVariant: isDark
              ? AppColors.darkMutedInk
              : AppColors.mutedInk,
          outlineVariant: isDark ? AppColors.darkBorder : AppColors.border,
          surfaceContainerHighest: isDark
              ? AppColors.darkRaisedSurface
              : AppColors.disabledBackground,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkPageBackground
          : AppColors.pageBackground,
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppFontSizes.pageTitle,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppFontSizes.sectionTitle,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: AppFontSizes.title,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: AppFontSizes.caption,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          fontSize: AppFontSizes.body,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontSize: AppFontSizes.compactLabel,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(
            AppSizes.minimumButtonHeight,
            AppSizes.minimumButtonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.standard),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(
            AppSizes.minimumButtonHeight,
            AppSizes.minimumButtonHeight,
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.standard),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
