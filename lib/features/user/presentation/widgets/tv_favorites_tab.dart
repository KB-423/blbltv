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

/// TV 我的收藏选项卡 (支持切换收藏夹与浏览收藏稿件)
class TvFavoritesTab extends ConsumerStatefulWidget {
  const TvFavoritesTab({super.key});

  @override
  ConsumerState<TvFavoritesTab> createState() => _TvFavoritesTabState();
}

class _TvFavoritesTabState extends ConsumerState<TvFavoritesTab> {
  int? _selectedMediaId;

  @override
  Widget build(BuildContext context) {
    final foldersAsync = ref.watch(userFavFoldersProvider);

    return foldersAsync.when(
      loading: () => const TvLoadingView(message: '正在拉取收藏夹...'),
      error: (err, _) => TvErrorView(
        error: err.toString(),
        onRetry: () => ref.invalidate(userFavFoldersProvider),
      ),
      data: (folders) {
        if (folders.isEmpty) {
          return const TvEmptyView(message: '暂无收藏夹');
        }

        final currentId = _selectedMediaId ?? folders.first.id;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：收藏夹垂直列表
            SizedBox(
              width: 220,
              child: DpadRegion(
                enter: DpadEnterBehavior.restore,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final isSelected = folder.id == currentId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DpadFocusable(
                        autofocus: index == 0,
                        onSelect: () {
                          setState(() {
                            _selectedMediaId = folder.id;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TvTheme.tvSurfaceLight
                                : TvTheme.tvSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? TvTheme.biliPink
                                  : TvTheme.tvDivider,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : TvTheme.tvTextPrimary,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${folder.mediaCount} 个视频',
                                style: const TextStyle(
                                  color: TvTheme.tvTextSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 右侧：当前收藏夹内容
            Expanded(
              child: _buildFolderContent(currentId),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFolderContent(int mediaId) {
    final resourcesAsync = ref.watch(userFavResourcesProvider(mediaId));

    return resourcesAsync.when(
      loading: () => const TvLoadingView(message: '正在拉取收藏内容...'),
      error: (err, _) => TvErrorView(
        error: err.toString(),
        onRetry: () => ref.invalidate(userFavResourcesProvider(mediaId)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const TvEmptyView(message: '该收藏夹暂无视频');
        }

        return DpadRegion(
          enter: DpadEnterBehavior.restore,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.25,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return DpadFocusable(
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
                      // 封面
                      Expanded(
                        flex: 6,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TvImage(
                              imageUrl: item.cover,
                              fit: BoxFit.cover,
                            ),
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
                                      item.upperName.isNotEmpty
                                          ? item.upperName
                                          : 'Bilibili 创作者',
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
