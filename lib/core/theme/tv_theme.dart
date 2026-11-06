import 'package:flutter/material.dart';

/// Bili for TV 现代大屏视觉与主题规范 (Apple TV 纯净毛玻璃 Liquid Glass 风格)
/// 遵循 10-foot 视觉层次、深邃黑曜石背景与纯白微光漫反射质感
class TvTheme {
  TvTheme._();

  // Bilibili 标志性品牌色 (仅保留纯粹品牌标识与点缀)
  static const Color biliPink = Color(0xFFFF6699);
  static const Color biliPinkLight = Color(0xFFFF85AD);
  static const Color biliPinkDark = Color(0xFFE0447C);
  static const Color biliBlue = Color(0xFF00AEEC);
  static const Color biliBlueLight = Color(0xFF33C2F7);
  static const Color vipGold = Color(0xFFFFB027);

  // 现代大屏深邃黑曜石背景与表面色阶
  static const Color tvBackground = Color(0xFF0A0B10);
  static const Color tvSurface = Color(0xFF141620);
  static const Color tvSurfaceLight = Color(0xFF1E2130);
  static const Color tvSurfaceElevated = Color(0xFF282C3E);

  // Apple TV 纯净毛玻璃 (Liquid Glass) 与微光色阶
  static const Color tvGlassBackground = Color(0x1AFFFFFF); // 10%~12% 通透悬浮
  static const Color tvGlassSurface = Color(0x22FFFFFF);    // 14% 晶莹白色半透
  static const Color tvGlassSurfaceFocused = Color(0x38FFFFFF); // 22% 获焦白光表面
  static const Color tvGlassBorder = Color(0x30FFFFFF);     // 19% 漫白反光边
  static const Color tvGlassBorderActive = Color(0xFFFFFFFF); // 100% 亮白微光边
  static const Color tvGlowWhite = Color(0x40FFFFFF);       // 纯白柔和漫反射光晕

  // 边框与阴影色阶 (向下兼容)
  static const Color tvCardBorder = tvGlassBorder;
  static const Color tvCardBorderFocused = Colors.white;
  static const Color tvFocusBorder = Colors.white;
  static const Color tvFocusGlow = tvGlowWhite;
  static const Color tvDivider = Color(0x18FFFFFF);

  // 统一圆角规范 (Apple TV 大圆角与胶囊规范)
  static const double radiusCard = 16.0;
  static const double radiusPill = 24.0;
  static const double radiusCapsule = 32.0;
  static const double radiusTile = 12.0;

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
    colors: [Color(0xFF1A1C28), Color(0xFF12131C)],
  );

  static const LinearGradient navRailGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x22FFFFFF), Color(0x10FFFFFF)],
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
