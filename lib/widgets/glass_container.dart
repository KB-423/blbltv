import 'dart:ui';
import 'package:flutter/material.dart';

/// Apple TV Liquid Glass 毛玻璃通用组件
/// 严格遵循 Apple TV 沉浸式毛玻璃设计规范：
/// 1. 使用 BackdropFilter + ImageFilter.blur 实现真实背景景深模糊
/// 2. 背景叠加通透半透明白色材质 (12%~25%)
/// 3. 细微漫反射白色描边模拟真实玻璃边缘反光 (25%~45%)
/// 4. 空间悬浮柔和扩散阴影与纯白漫反射微光
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isFocused;
  final Color? surfaceColor;
  final Color? borderColor;
  final List<BoxShadow>? customShadows;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blur = 20.0,
    this.opacity = 0.14,
    this.borderOpacity = 0.28,
    this.borderWidth = 0.8,
    this.borderRadius = const BorderRadius.all(Radius.circular(20.0)),
    this.padding,
    this.margin,
    this.isFocused = false,
    this.surfaceColor,
    this.borderColor,
    this.customShadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSurface = surfaceColor ??
        (isFocused
            ? Colors.white.withValues(alpha: 0.24)
            : Colors.white.withValues(alpha: opacity));

    final effectiveBorder = borderColor ??
        (isFocused
            ? Colors.white
            : Colors.white.withValues(alpha: borderOpacity));

    final effectiveWidth = isFocused ? 1.8 : borderWidth;

    final shadows = customShadows ??
        (isFocused
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.32),
                  blurRadius: 26,
                  offset: const Offset(0, 8),
                ),
              ]);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveSurface,
        gradient: gradient ??
            (isFocused
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0.16),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: opacity * 1.3),
                      Colors.white.withValues(alpha: opacity * 0.7),
                    ],
                  )),
        borderRadius: borderRadius,
        border: Border.all(
          color: effectiveBorder,
          width: effectiveWidth,
        ),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    // 通过 ClipRRect + BackdropFilter 实现真实的背景光学模糊
    return ClipRRect(
      borderRadius: borderRadius,
      child: blur > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: content,
            )
          : content,
    );
  }
}
