import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dpad/dpad.dart';
import 'package:media_kit/media_kit.dart';

import 'core/storage/storage_service.dart';
import 'core/theme/tv_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final storageService = await StorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
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
      builder: Dpad.wrap(
        theme: const DpadThemeData(
          effects: [
            DpadScaleEffect(scale: 1.05),
            DpadBorderEffect(
              color: TvTheme.tvFocusBorder,
              width: 2.5,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            DpadGlowEffect(
              color: TvTheme.tvFocusGlow,
              blurRadius: 16.0,
            ),
          ],
          scrollPadding: 48.0,
          scrollDuration: Duration(milliseconds: 220),
        ),
      ),
    );
  }
}
