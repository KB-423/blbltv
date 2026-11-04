import 'package:flutter/material.dart';
import 'package:dpad/dpad.dart';
import '../core/theme/tv_theme.dart';

/// TV 加载中状态组件
class TvLoadingView extends StatelessWidget {
  final String message;

  const TvLoadingView({super.key, this.message = '正在加载中...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(TvTheme.biliPink),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: TvTheme.tvTextSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// TV 错误重试状态组件
class TvErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const TvErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: TvTheme.biliPink,
            size: 56,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              error,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TvTheme.tvTextSecondary,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          DpadFocusable(
            autofocus: true,
            onSelect: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: TvTheme.tvSurfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20, color: TvTheme.tvTextPrimary),
                  SizedBox(width: 8),
                  Text(
                    '重新加载',
                    style: TextStyle(
                      color: TvTheme.tvTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// TV 空内容状态组件
class TvEmptyView extends StatelessWidget {
  final String message;
  final VoidCallback? onRefresh;

  const TvEmptyView({
    super.key,
    this.message = '暂无内容',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 56,
            color: TvTheme.tvTextDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: TvTheme.tvTextSecondary,
              fontSize: 16,
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 18),
            DpadFocusable(
              autofocus: true,
              onSelect: onRefresh!,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: TvTheme.tvSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '刷新',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
