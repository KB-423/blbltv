import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../widgets/tv_image.dart';
import '../../../../widgets/tv_status_view.dart';
import '../providers/user_content_provider.dart';

/// TV 我的追番选项卡
class TvBangumiTab extends ConsumerWidget {
  const TvBangumiTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangumiAsync = ref.watch(userBangumiProvider);

    return bangumiAsync.when(
      loading: () => const TvLoadingView(message: '正在拉取追番列表...'),
      error: (err, _) => TvErrorView(
        error: err.toString(),
        onRetry: () => ref.invalidate(userBangumiProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const TvEmptyView(message: '暂无追番记录');
        }

        return DpadRegion(
          enter: DpadEnterBehavior.restore,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.68,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return DpadFocusable(
                autofocus: index == 0,
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
                      // 海报封面
                      Expanded(
                        flex: 7,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TvImage(
                              imageUrl: item.cover,
                              fit: BoxFit.cover,
                            ),
                            if (item.badge.isNotEmpty)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TvTheme.biliPink,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.badge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (item.newEpTitle.isNotEmpty)
                              Positioned(
                                left: 6,
                                bottom: 6,
                                right: 6,
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
                                    item.newEpTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // 标题与进度
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
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
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                item.progress.isNotEmpty
                                    ? item.progress
                                    : (item.totalCount.isNotEmpty
                                        ? '${item.totalCount} 话全'
                                        : '连载中'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: TvTheme.tvTextSecondary,
                                  fontSize: 11,
                                ),
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
