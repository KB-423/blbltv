import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bili_tv/models/video/video_part_model.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_part_drawer.dart';

void main() {
  testWidgets('TvPartDrawer renders parts and responds to selection',
      (tester) async {
    int selectedPart = -1;
    bool isClosed = false;

    const parts = [
      VideoPartItem(cid: 1001, page: 1, part: '第1话 启程', duration: 1420),
      VideoPartItem(cid: 1002, page: 2, part: '第2话 试炼', duration: 1435),
      VideoPartItem(cid: 1003, page: 3, part: '第3话 突破', duration: 1410),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvPartDrawer(
            parts: parts,
            currentPartIndex: 0,
            onSelectPart: (idx) {
              selectedPart = idx;
            },
            onClose: () {
              isClosed = true;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('选集播放'), findsOneWidget);
    expect(find.text('共3P'), findsOneWidget);
    expect(find.text('第1话 启程'), findsOneWidget);
    expect(find.text('第2话 试炼'), findsOneWidget);

    // 点击第二个分P
    await tester.tap(find.text('第2话 试炼'));
    await tester.pump();
    expect(selectedPart, 1);

    // 点击关闭按钮
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(isClosed, true);
  });
}
