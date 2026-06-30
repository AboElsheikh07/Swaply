import 'package:flutter/material.dart';
import 'package:swaply/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData.light().copyWith(
    primaryColor: AppColors.light.primary,
    canvasColor: AppColors.light.card,
    scaffoldBackgroundColor: AppColors.light.background,
    cardColor: AppColors.light.card,
    dividerColor: AppColors.light.border,
    bottomAppBarTheme: BottomAppBarThemeData(color: AppColors.light.card),
    unselectedWidgetColor: AppColors.light.muted,
    iconTheme: IconThemeData(color: AppColors.light.text),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.light.text),
      bodyMedium: TextStyle(color: AppColors.light.mutedFg),
      titleLarge: TextStyle(color: AppColors.light.text),
      titleMedium: TextStyle(color: AppColors.light.text),
    ),
    extensions: <ThemeExtension<dynamic>>[AppColors.light],
  );

  static ThemeData get dark => ThemeData.dark().copyWith(
    primaryColor: AppColors.dark.primary,
    canvasColor: AppColors.dark.card,
    scaffoldBackgroundColor: AppColors.dark.background,
    cardColor: AppColors.dark.card,
    dividerColor: AppColors.dark.border,
    bottomAppBarTheme: BottomAppBarThemeData(color: AppColors.dark.card),
    unselectedWidgetColor: AppColors.dark.muted,
    iconTheme: IconThemeData(color: AppColors.dark.text),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.dark.text),
      bodyMedium: TextStyle(color: AppColors.dark.mutedFg),
      titleLarge: TextStyle(color: AppColors.dark.text),
      titleMedium: TextStyle(color: AppColors.dark.text),
    ),
    extensions: <ThemeExtension<dynamic>>[AppColors.dark],
  );
}
