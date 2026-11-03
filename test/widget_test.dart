import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bili_tv/core/storage/storage_service.dart';
import 'package:bili_tv/features/home/presentation/providers/home_provider.dart';
import 'package:bili_tv/models/video/video_item_model.dart';
import 'package:bili_tv/main.dart';

class _FakeHomeFeedNotifier extends HomeFeedNotifier {
  @override
  Future<List<VideoItemModel>> build() async {
    return const [];
  }
}

void main() {
  testWidgets('BiliTvApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          homeFeedProvider.overrideWith(_FakeHomeFeedNotifier.new),
        ],
        child: const BiliTvApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bili TV'), findsOneWidget);
    expect(find.text('推荐'), findsOneWidget);
  });
}
