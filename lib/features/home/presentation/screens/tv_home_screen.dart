import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../providers/home_provider.dart';
import '../widgets/tv_video_card.dart';

/// TV 首页推荐屏幕
class TvHomeScreen extends ConsumerWidget {
  const TvHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedProvider);

    return TvScaffold(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: TvTheme.biliPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '推荐视频',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          DpadFocusable(
            onSelect: () => ref.read(homeFeedProvider.notifier).refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: TvTheme.tvSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 18, color: TvTheme.tvTextSecondary),
                  SizedBox(width: 6),
                  Text(
                    '刷新推荐',
                    style: TextStyle(
                      color: TvTheme.tvTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => const TvLoadingView(message: '正在拉取推荐视频...'),
        error: (error, _) => TvErrorView(
          error: error.toString(),
          onRetry: () => ref.read(homeFeedProvider.notifier).refresh(),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Text(
                '暂无推荐内容',
                style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.15,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return TvVideoCard(
                video: video,
                autofocus: index == 0,
                onPlay: () {
                  context.push(RoutePaths.playerWithBvid(video.bvid));
                },
              );
            },
          );
        },
      ),
    );
  }
}
