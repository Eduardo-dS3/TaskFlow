import 'package:flutter/material.dart';

import 'colors.dart';
import 'dimens.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      visualDensity: VisualDensity.standard,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimens.radiusSmall),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusSmall),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusSmall),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
