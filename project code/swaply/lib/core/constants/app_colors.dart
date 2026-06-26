import 'package:flutter/material.dart';

@immutable
class AppColorTheme extends ThemeExtension<AppColorTheme> {
  final Color primary;
  final Color background;
  final Color card;
  final Color border;
  final Color muted;
  final Color text;
  final Color green;
  final Color greenBg;
  final Color amber;
  final Color amberBg;
  final Color sky;
  final Color skyBg;
  final Color rose;
  final Color roseBg;
  final Color primarySoft;
  final Color mutedFg;

  const AppColorTheme({
    required this.primary,
    required this.background,
    required this.card,
    required this.border,
    required this.muted,
    required this.text,
    required this.green,
    required this.greenBg,
    required this.amber,
    required this.amberBg,
    required this.sky,
    required this.skyBg,
    required this.rose,
    required this.roseBg,
    required this.primarySoft,
    required this.mutedFg,
  });

  @override
  AppColorTheme copyWith({
    Color? primary,
    Color? background,
    Color? card,
    Color? border,
    Color? muted,
    Color? text,
    Color? green,
    Color? greenBg,
    Color? amber,
    Color? amberBg,
    Color? sky,
    Color? skyBg,
    Color? rose,
    Color? roseBg,
    Color? primarySoft,
    Color? mutedFg,
  }) {
    return AppColorTheme(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      card: card ?? this.card,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      text: text ?? this.text,
      green: green ?? this.green,
      greenBg: greenBg ?? this.greenBg,
      amber: amber ?? this.amber,
      amberBg: amberBg ?? this.amberBg,
      sky: sky ?? this.sky,
      skyBg: skyBg ?? this.skyBg,
      rose: rose ?? this.rose,
      roseBg: roseBg ?? this.roseBg,
      primarySoft: primarySoft ?? this.primarySoft,
      mutedFg: mutedFg ?? this.mutedFg,
    );
  }

  @override
  AppColorTheme lerp(ThemeExtension<AppColorTheme>? other, double t) {
    if (other is! AppColorTheme) {
      return this;
    }
    return AppColorTheme(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      background: Color.lerp(background, other.background, t) ?? background,
      card: Color.lerp(card, other.card, t) ?? card,
      border: Color.lerp(border, other.border, t) ?? border,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      text: Color.lerp(text, other.text, t) ?? text,
      green: Color.lerp(green, other.green, t) ?? green,
      greenBg: Color.lerp(greenBg, other.greenBg, t) ?? greenBg,
      amber: Color.lerp(amber, other.amber, t) ?? amber,
      amberBg: Color.lerp(amberBg, other.amberBg, t) ?? amberBg,
      sky: Color.lerp(sky, other.sky, t) ?? sky,
      skyBg: Color.lerp(skyBg, other.skyBg, t) ?? skyBg,
      rose: Color.lerp(rose, other.rose, t) ?? rose,
      roseBg: Color.lerp(roseBg, other.roseBg, t) ?? roseBg,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
      mutedFg: Color.lerp(mutedFg, other.mutedFg, t) ?? mutedFg,
    );
  }
}

abstract class AppColors {
  AppColors._();

  static const AppColorTheme light = AppColorTheme(
    primary: Color(0xFF5B4CB8),
    background: Color(0xFFF9FAFB),
    card: Colors.white,
    border: Color(0xFFEAEAF0),
    muted: Color(0xFF9CA3AF),
    text: Color(0xFF111827),
    green: Color(0xFF059669),
    greenBg: Color(0xFFECFDF5),
    amber: Color(0xFFD97706),
    amberBg: Color(0xFFFFFBEB),
    sky: Color(0xFF0369A1),
    skyBg: Color(0xFFEFF6FF),
    rose: Color(0xFFBE123C),
    roseBg: Color(0xFFFFF1F2),
    primarySoft: Color(0xFFEEECFB),
    mutedFg: Color(0xFF8A8A9A),
  );

  static const AppColorTheme dark = AppColorTheme(
    primary: Color(0xFF8A7DE4),
    background: Color(0xFF121212),
    card: Color(0xFF1E1E1E),
    border: Color(0xFF2C2C2C),
    muted: Color(0xFF6B7280),
    text: Color(0xFFF9FAFB),
    green: Color(0xFF10B981),
    greenBg: Color(0xFF064E3B),
    amber: Color(0xFFF59E0B),
    amberBg: Color(0xFF78350F),
    sky: Color(0xFF0EA5E9),
    skyBg: Color(0xFF0C4A6E),
    rose: Color(0xFFF43F5E),
    roseBg: Color(0xFF881337),
    primarySoft: Color(0xFF2D265B),
    mutedFg: Color(0xFF9CA3AF),
  );
}
