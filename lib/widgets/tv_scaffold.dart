import 'package:flutter/material.dart';

/// TV 页面脚手架容器，保证 Overscan 防切边安全边距
/// 注意：
/// 1. 外层 TvMainShell 已提供根 Scaffold，此处采用 Container 避免嵌套 Scaffold 造成的焦点作用域孤立隔离
/// 2. 具备响应式自适应边距：针对常见 540P/720P TV 分辨率收紧间距，释放充足的可用内容区
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
    final size = MediaQuery.of(context).size;
    final bool isCompact = size.height <= 650;

    final double horizontalPadding = isCompact ? 36.0 : 48.0;
    final responsivePadding = padding ??
        EdgeInsets.fromLTRB(
          horizontalPadding,
          isCompact ? 12.0 : 16.0,
          horizontalPadding,
          isCompact ? 16.0 : 24.0,
        );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: responsivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (header != null) ...[
                  header!,
                  SizedBox(height: isCompact ? 10.0 : 16.0),
                ],
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
