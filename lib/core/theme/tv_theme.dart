import 'package:flutter/material.dart';

/// Bili for TV 现代大屏视觉与主题规范
/// 遵循 10-foot 视觉层次、深邃黑曜石背景与沉浸式影院级玻璃质感
class TvTheme {
  TvTheme._();

  // Bilibili 标志性品牌色
  static const Color biliPink = Color(0xFFFF6699);
  static const Color biliPinkLight = Color(0xFFFF85AD);
  static const Color biliPinkDark = Color(0xFFE0447C);
  static const Color biliBlue = Color(0xFF00AEEC);
  static const Color biliBlueLight = Color(0xFF33C2F7);
  static const Color vipGold = Color(0xFFFFB027);

  // 现代大屏深邃黑曜石背景与表面色阶
  static const Color tvBackground = Color(0xFF0C0D14);
  static const Color tvSurface = Color(0xFF161824);
  static const Color tvSurfaceLight = Color(0xFF222536);
  static const Color tvSurfaceElevated = Color(0xFF2B2F44);

  // 边框与阴影色阶
  static const Color tvCardBorder = Color(0x1AFFFFFF); // 10% 微光白边
  static const Color tvCardBorderFocused = Color(0xFFFFFFFF);
  static const Color tvFocusBorder = Color(0xFF00AEEC);
  static const Color tvFocusGlow = Color(0x4D00AEEC);
  static const Color tvDivider = Color(0x1FFFFFFF);

  // 大屏文字对比度标准 (符合 WCAG AA 级大屏远距离观影标准)
  static const Color tvTextPrimary = Color(0xFFFFFFFF);
  static const Color tvTextSecondary = Color(0xFFA1A7B8);
  static const Color tvTextTertiary = Color(0xFF72788E);
  static const Color tvTextDisabled = Color(0xFF505567);

  // 常用大屏质感渐变
  static const LinearGradient biliPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6699), Color(0xFFFF85AD)],
  );

  static const LinearGradient biliBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00AEEC), Color(0xFF33C2F7)],
  );

  static const LinearGradient vipGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB027), Color(0xFFFFD166)],
  );

  static const LinearGradient cardSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1E2D), Color(0xFF131520)],
  );

  static const LinearGradient navRailGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF13141F), Color(0xFF0D0E16)],
  );

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
      dividerColor: tvDivider,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: tvTextPrimary,
          letterSpacing: 0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: tvTextPrimary,
          letterSpacing: 0.2,
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
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: tvTextSecondary,
          height: 1.3,
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

