import 'package:flutter/material.dart';

/// Central color palette — update once, applies everywhere.
abstract class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F3FF0);
  static const Color background = Colors.white;
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF9CA3AF);
  static const Color text = Color(0xFF111827);

  // Semantic
  static const Color green = Color(0xFF059669);
  static const Color greenBg = Color(0xFFECFDF5);
  static const Color amber = Color(0xFFD97706);
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color sky = Color(0xFF0369A1);
  static const Color skyBg = Color(0xFFEFF6FF);
  static const Color rose = Color(0xFFBE123C);
  static const Color roseBg = Color(0xFFFFF1F2);
}
