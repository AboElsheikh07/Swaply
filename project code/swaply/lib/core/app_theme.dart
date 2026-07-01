import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColorTheme colors, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      primaryColor: colors.primary,
      canvasColor: colors.card,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.card,
      dividerColor: colors.border,
      unselectedWidgetColor: colors.muted,

      colorScheme: base.colorScheme.copyWith(
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.primarySoft,
        onSecondary: colors.primary,
        surface: colors.card,
        onSurface: colors.text,
        error: colors.rose,
        onError: Colors.white,
        outline: colors.border,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.card,
        foregroundColor: colors.text,
        elevation: 0.5,
        shadowColor: colors.border,
        iconTheme: IconThemeData(color: colors.text),
        titleTextStyle: TextStyle(
          color: colors.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      bottomAppBarTheme: BottomAppBarThemeData(color: colors.card),

      iconTheme: IconThemeData(color: colors.text),

      textTheme: base.textTheme.copyWith(
        bodyLarge: TextStyle(color: colors.text),
        bodyMedium: TextStyle(color: colors.text),
        bodySmall: TextStyle(color: colors.mutedFg),
        titleLarge: TextStyle(color: colors.text),
        titleMedium: TextStyle(color: colors.text),
        titleSmall: TextStyle(color: colors.text),
        labelLarge: TextStyle(color: colors.text),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),

      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),

      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
