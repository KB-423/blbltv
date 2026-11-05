import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/tv_theme.dart';
import '../../../../router/route_paths.dart';
import '../../../../widgets/tv_scaffold.dart';
import '../../../../widgets/tv_status_view.dart';
import '../../../home/presentation/widgets/tv_video_card.dart';
import '../providers/search_provider.dart';
import '../providers/search_state.dart';

/// TV 搜索界面
/// 完全遵循 10-foot TV 交互规范：
/// - 采用原生 TV TextField（调起电视系统自带的输入法，如 Android TV Gboard / Leanback IME / 搜狗输入法）
/// - 支持遥控器一键点击实时热搜词快速直达
/// - 搜索结果采用 4 列卡片网格复用展示，支持遥控器导航与无缝全屏播放
class TvSearchScreen extends ConsumerStatefulWidget {
  const TvSearchScreen({super.key});

  @override
  ConsumerState<TvSearchScreen> createState() => _TvSearchScreenState();
}

class _TvSearchScreenState extends ConsumerState<TvSearchScreen> {
  static const MethodChannel _imeChannel = MethodChannel('cloud.kitasaitamablues.bili_tv/ime');

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 呼出系统软键盘/输入法
  void _openKeyboard() {
    if (!Platform.isAndroid) return;
    _inputFocusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
    try {
      _imeChannel.invokeMethod('showIme');
    } catch (_) {}
  }

  /// 隐藏软键盘
  void _hideKeyboard() {
    if (!Platform.isAndroid) return;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    try {
      _imeChannel.invokeMethod('hideIme');
    } catch (_) {}
    _inputFocusNode.unfocus();
  }

  void _submitSearch(String text) {
    _hideKeyboard();
    final query = text.trim();
    if (query.isNotEmpty) {
      ref.read(searchProvider.notifier).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return TvScaffold(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题与搜索输入框工具栏 (独立 DpadRegion，横向停止逃逸)
          DpadRegion(
            horizontalEdge: DpadEdgeBehavior.stop,
            verticalEdge: DpadEdgeBehavior.leave,
            child: Row(
              children: [
                Text('全站搜索',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 24),

              // TV 优化搜索输入框 (使用电视系统自带输入法)
              Expanded(
                child: DpadFocusable(
                  autofocus: true,
                  excludeChildFocus: false,
                  onSelect: _openKeyboard,
                  builder: (context, state, child) {
                    final isFocused = state.focused || _inputFocusNode.hasFocus;
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isFocused
                            ? TvTheme.tvSurfaceElevated
                            : TvTheme.tvSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFocused ? Colors.white : Colors.white12,
                          width: isFocused ? 2.0 : 1.0,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: TvTheme.biliBlue.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: child,
                    );
                  },
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.search_rounded, color: TvTheme.tvTextSecondary, size: 20),
                      ),
                      Expanded(
                        child: Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.select ||
                                  event.logicalKey == LogicalKeyboardKey.enter ||
                                  event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                                  event.logicalKey == LogicalKeyboardKey.gameButtonA) {
                                _openKeyboard();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: _searchController,
                            focusNode: _inputFocusNode,
                            style: const TextStyle(color: TvTheme.tvTextPrimary, fontSize: 15),
                            textInputAction: TextInputAction.search,
                            onTap: _openKeyboard,
                            onSubmitted: _submitSearch,
                            decoration: const InputDecoration(
                              hintText: '输入关键词搜索全站视频（遥控器 OK 激活电视输入法）',
                              hintStyle: TextStyle(color: TvTheme.tvTextDisabled, fontSize: 13.5),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        DpadFocusable(
                          onSelect: () {
                            _searchController.clear();
                            notifier.clear();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(right: 6),
                            child: const Icon(
                              Icons.cancel_rounded,
                              color: TvTheme.tvTextSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 搜索按钮
              DpadFocusable(
                onSelect: () => _submitSearch(_searchController.text),
                builder: (context, state, child) {
                  final isFocused = state.focused;
                  return Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      gradient: isFocused ? null : TvTheme.biliBlueGradient,
                      color: isFocused ? Colors.white : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.4),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: TvTheme.biliBlue.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: isFocused ? Colors.black : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '搜索',
                          style: TextStyle(
                            color: isFocused ? Colors.black : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),

          // 真实热搜榜推荐标签栏 (独立 DpadRegion，防止横向串焦逃逸到其他结构)
          if (searchState.hotWords.isNotEmpty) ...[
            const SizedBox(height: 14),
            DpadRegion(
              horizontalEdge: DpadEdgeBehavior.stop,
              verticalEdge: DpadEdgeBehavior.leave,
              child: SizedBox(
                height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: searchState.hotWords.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.deepOrangeAccent,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '热搜榜:',
                          style: TextStyle(
                            color: TvTheme.tvTextSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }

                  final int rank = index;
                  final word = searchState.hotWords[index - 1];

                  Color rankColor;
                  if (rank == 1) {
                    rankColor = const Color(0xFFFF4D4F);
                  } else if (rank == 2) {
                    rankColor = const Color(0xFFFF7A45);
                  } else if (rank == 3) {
                    rankColor = const Color(0xFFFFA940);
                  } else {
                    rankColor = TvTheme.tvTextDisabled;
                  }

                  return DpadFocusable(
                    onSelect: () {
                      _searchController.text = word;
                      _submitSearch(word);
                    },
                    builder: (context, state, child) {
                      final isFocused = state.focused;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isFocused
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: isFocused ? Colors.white : Colors.white12,
                            width: 1,
                          ),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 17,
                              height: 17,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isFocused
                                    ? rankColor
                                    : rankColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  color: isFocused ? Colors.white : rankColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              word,
                              style: TextStyle(
                                color: isFocused ? Colors.black : TvTheme.tvTextPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ),
        ],
        ],
      ),
      body: _buildBody(searchState, notifier),
    );
  }

  Widget _buildBody(SearchState searchState, SearchNotifier notifier) {
    if (searchState.isLoading) {
      return TvLoadingView(message: '正在搜索 "${searchState.keyword}"...');
    }

    if (searchState.error != null && searchState.videos.isEmpty) {
      return TvErrorView(error: searchState.error!, onRetry: () => notifier.retry());
    }

    // 未执行搜索时的欢迎与指引页
    if (!searchState.hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded, size: 64, color: TvTheme.tvTextDisabled),
            const SizedBox(height: 16),
            const Text(
              '探索精彩视频',
              style: TextStyle(
                color: TvTheme.tvTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '按遥控器 OK 激活输入框打开电视输入法，或点击上方热搜标签直接检索',
              style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // 搜索结果为空
    if (searchState.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 56,
              color: TvTheme.tvTextDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到关于 "${searchState.keyword}" 的视频',
              style: const TextStyle(
                color: TvTheme.tvTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请尝试更换关键词或检查输入是否有误',
              style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final videos = searchState.videos;

    // 4 列大屏搜索结果网格
    return DpadRegion(
      enter: DpadEnterBehavior.restore,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 搜索结果统计摘要
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '共找到约 ${searchState.numResults} 个相关视频 (第 ${searchState.page} / ${searchState.numPages} 页)',
                style: const TextStyle(color: TvTheme.tvTextSecondary, fontSize: 13),
              ),
            ),
          ),

          // 视频卡片网格
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.15,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final video = videos[index];
              return TvVideoCard(
                video: video,
                autofocus: index == 0,
                onFocusChange: (focused) {
                  // 遥控器触底加载更多
                  if (focused && index >= videos.length - 4) {
                    notifier.loadMore();
                  }
                },
                onPlay: () {
                  context.push(RoutePaths.playerWithBvid(video.bvid));
                },
              );
            }, childCount: videos.length),
          ),

          // 底部追加加载指示器
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: searchState.isLoadingMore
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(TvTheme.biliBlue),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '正在加载更多搜索结果...',
                          style: TextStyle(color: TvTheme.tvTextSecondary, fontSize: 14),
                        ),
                      ],
                    )
                  : (!searchState.hasMore
                        ? const Center(
                            child: Text(
                              '— 已加载全部搜索结果 —',
                              style: TextStyle(color: TvTheme.tvTextDisabled, fontSize: 13),
                            ),
                          )
                        : const SizedBox.shrink()),
            ),
          ),
        ],
      ),
    );
  }
}
