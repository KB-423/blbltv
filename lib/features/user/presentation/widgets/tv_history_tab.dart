import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_image.dart';
import '../../../../widgets/tv_status_view.dart';
import '../providers/user_content_provider.dart';

/// TV 用户历史记录选项卡
class TvHistoryTab extends ConsumerWidget {
  const TvHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(userHistoryProvider);

    return historyAsync.when(
      loading: () => const TvLoadingView(message: '正在加载观看历史...'),
      error: (err, _) => TvErrorView(
        error: err.toString(),
        onRetry: () => ref.invalidate(userHistoryProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const TvEmptyView(message: '暂无观看历史记录');
        }

        return DpadRegion(
          enter: DpadEnterBehavior.restore,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.25,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return DpadFocusable(
                autofocus: index == 0,
                onSelect: () {
                  context.push(RoutePaths.playerWithBvid(item.bvid));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: TvTheme.tvSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TvTheme.tvDivider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 封面与进度条
                      Expanded(
                        flex: 6,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TvImage(
                              imageUrl: item.cover,
                              fit: BoxFit.cover,
                            ),
                            // 底部进度状态文字
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  Formatters.formatProgress(
                                    item.progress,
                                    item.duration,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // 右下角总时长
                            if (item.duration > 0)
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    Formatters.formatDuration(item.duration),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // 标题与 UP 主
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: TvTheme.tvTextPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: 13,
                                    color: TvTheme.tvTextSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.authorName.isNotEmpty
                                          ? item.authorName
                                          : 'Bilibili UP主',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: TvTheme.tvTextSecondary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
