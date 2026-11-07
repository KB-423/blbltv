import 'package:flutter/material.dart';

import '../../../../models/video/video_part_model.dart';
import 'tv_episode_drawer.dart';

/// TV 普通视频分 P 抽屉适配器
/// 基于通用 `TvEpisodeDrawer` 构建，保持向后兼容
class TvPartDrawer extends StatelessWidget {
  final List<VideoPartItem> parts;
  final int currentPartIndex;
  final ValueChanged<int> onSelectPart;
  final VoidCallback onClose;

  const TvPartDrawer({
    super.key,
    required this.parts,
    required this.currentPartIndex,
    required this.onSelectPart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final episodes = parts
        .asMap()
        .entries
        .map((e) => TvEpisodeItem.fromPart(e.value, e.key))
        .toList();

    return TvEpisodeDrawer(
      drawerTitle: '选集播放',
      countLabel: '共${parts.length}P',
      episodes: episodes,
      currentIndex: currentPartIndex,
      onSelectEpisode: onSelectPart,
      onClose: onClose,
    );
  }
}
