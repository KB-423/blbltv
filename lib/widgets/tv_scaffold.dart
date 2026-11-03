import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/tv_theme.dart';

/// TV 页面脚手架，保证 Overscan 防切边安全边距
class TvScaffold extends StatelessWidget {
  final Widget body;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const TvScaffold({
    super.key,
    required this.body,
    this.header,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? TvTheme.tvBackground,
      body: SafeArea(
        child: Padding(
          padding: padding ?? AppConstants.tvSafePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: 16.0),
              ],
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

