import 'package:flutter/material.dart';

/// TV 应用全局尺寸、间距与配置常量
class AppConstants {
  AppConstants._();

  // TV Overscan 安全边距
  static const EdgeInsets tvSafePadding = EdgeInsets.symmetric(
    horizontal: 40.0,
    vertical: 28.0,
  );

  // TV 侧边栏宽度
  static const double sideBarWidthCollapsed = 88.0;
  static const double sideBarWidthExpanded = 220.0;

  // TV 卡片动画与尺寸
  static const double focusScale = 1.05;
  static const Duration focusAnimationDuration = Duration(milliseconds: 180);
  static const double cardBorderRadius = 10.0;

  // 网络请求超时 (大屏电视 Wi-Fi 适度容错窗口)
  static const Duration connectTimeout = Duration(seconds: 25);
  static const Duration receiveTimeout = Duration(seconds: 25);

  // 本地存储 Key
  static const String keyUserToken = 'key_user_token';
  static const String keyBuvid = 'key_buvid';
  static const String keyWbiImgKey = 'key_wbi_img_key';
  static const String keyWbiSubKey = 'key_wbi_sub_key';
  static const String keyThemeMode = 'key_theme_mode';
}

