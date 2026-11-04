import 'package:flutter/material.dart';

/// Bili for TV 主题配置
class TvTheme {
  TvTheme._();

  // Bilibili 标志性粉色与大屏高对比辅助色
  static const Color biliPink = Color(0xFFFF6699);
  static const Color biliPinkLight = Color(0xFFFF85AD);
  static const Color biliBlue = Color(0xFF00AEEC);
  static const Color tvBackground = Color(0xFF101115);
  static const Color tvSurface = Color(0xFF1C1D24);
  static const Color tvSurfaceLight = Color(0xFF282A36);
  static const Color tvFocusBorder = Color(0xFF00AEEC);
  static const Color tvFocusGlow = Color(0x6600AEEC);
  static const Color tvTextPrimary = Color(0xFFF2F4F7);
  static const Color tvTextSecondary = Color(0xFF9EA3B0);
  static const Color tvTextDisabled = Color(0xFF5A5E6B);
  static const Color tvDivider = Color(0xFF2A2D3A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: tvBackground,
      primaryColor: biliPink,
      colorScheme: const ColorScheme.dark(
        primary: biliPink,
        secondary: biliBlue,
        surface: tvSurface,
        onSurface: tvTextPrimary,
      ),
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: tvTextPrimary,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: tvTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: tvTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: tvTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: tvTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: tvTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: tvTextPrimary,
        ),
      ),
    );
  }
}

