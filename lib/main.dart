import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:media_kit/media_kit.dart';

import 'core/services/codec_capability_service.dart';
import 'core/services/display_capability_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/tv_theme.dart';
import 'features/main/presentation/providers/nav_rail_focus_provider.dart';
import 'router/app_router.dart';
import 'widgets/tv_debug_remote_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final storageService = await StorageService.init();
  final displayCapability = await DisplayCapabilityService.detect();
  final codecCapability = await CodecCapabilityService.detect();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        rawDisplayCapabilityProvider.overrideWithValue(displayCapability),
        codecCapabilityProvider.overrideWithValue(codecCapability),
      ],
      child: const BiliTvApp(),
    ),
  );
}

/// TV 应用入口组件
class BiliTvApp extends ConsumerWidget {
  const BiliTvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Bili for TV',
      debugShowCheckedModeBanner: false,
      theme: TvTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        return Dpad.wrap(
          // 全局边缘阻挡处理：右侧内容区向左到达边界无处可走时，自动将遥控器焦点平滑切回左侧导轨
          onBlockedMove: (direction) {
            if (direction == TraversalDirection.left) {
              final path =
                  router.routerDelegate.currentConfiguration.uri.path;
              // 全屏播放器等独立全屏页面严禁切回左侧导轨，杜绝播放器内按左键被盗走焦点导致失焦卡死
              if (!path.startsWith('/player')) {
                ref.read(navRailFocusServiceProvider).focusSelected();
              }
            }
          },
          theme: const DpadThemeData(
            effects: [
              DpadScaleEffect(scale: 1.04),
              DpadBorderEffect(
                color: Colors.white,
                width: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              DpadGlowEffect(
                color: Color(0x4000AEEC),
                blurRadius: 20.0,
              ),
            ],
            scrollPadding: 54.0,
            scrollDuration: Duration(milliseconds: 220),
            scrollCurve: Curves.easeOutCubic,
          ),
        )(
          context,
          TvDebugRemoteOverlay(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
