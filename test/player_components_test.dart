import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dpad/dpad.dart';

import 'package:bili_tv/models/video/play_url_model.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_play_pause_button.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_quick_seek_button.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_progress_bar.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_seek_hud.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_player_header.dart';
import 'package:bili_tv/features/player/presentation/widgets/tv_player_controls.dart';

Widget _wrapWithDpad(Widget child) {
  return MaterialApp(
    builder: (context, c) => Dpad.wrap()(context, c ?? const SizedBox.shrink()),
    home: Scaffold(body: child),
  );
}

void main() {
  group('TvPlayPauseButton Tests', () {
    testWidgets('shows pause icon when isPlaying is true and triggers callback',
        (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        _wrapWithDpad(
          TvPlayPauseButton(
            isPlaying: true,
            onTogglePlay: () {
              toggled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);

      await tester.tap(find.byType(TvPlayPauseButton));
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('shows play icon when isPlaying is false', (tester) async {
      await tester.pumpWidget(
        _wrapWithDpad(
          TvPlayPauseButton(
            isPlaying: false,
            onTogglePlay: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsNothing);
    });
  });

  group('TvQuickSeekButton Tests', () {
    testWidgets('backward button renders replay_10 and triggers onSeek',
        (tester) async {
      bool seekCalled = false;

      await tester.pumpWidget(
        _wrapWithDpad(
          TvQuickSeekButton(
            isForward: false,
            seconds: 10,
            onSeek: () {
              seekCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);

      await tester.tap(find.byType(TvQuickSeekButton));
      await tester.pump();
      expect(seekCalled, isTrue);
    });

    testWidgets('forward button renders forward_10 and triggers onSeek',
        (tester) async {
      bool seekCalled = false;

      await tester.pumpWidget(
        _wrapWithDpad(
          TvQuickSeekButton(
            isForward: true,
            seconds: 10,
            onSeek: () {
              seekCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);

      await tester.tap(find.byType(TvQuickSeekButton));
      await tester.pump();
      expect(seekCalled, isTrue);
    });
  });

  group('TvProgressBar Tests', () {
    testWidgets('renders formatted position and duration cleanly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TvProgressBar(
              position: Duration(minutes: 1, seconds: 23),
              duration: Duration(minutes: 10, seconds: 0),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('01:23'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('handles zero duration cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TvProgressBar(
              position: Duration.zero,
              duration: Duration.zero,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsNWidgets(2));
    });
  });

  group('TvSeekHUD Tests', () {
    testWidgets('renders target time and forward indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TvSeekHUD(
              targetPosition: Duration(minutes: 5, seconds: 30),
              duration: Duration(minutes: 10),
              accumulatedSeconds: 30,
              isForward: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('05:30'), findsOneWidget);
      expect(find.byIcon(Icons.fast_forward_rounded), findsOneWidget);
    });

    testWidgets('renders backward indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TvSeekHUD(
              targetPosition: Duration(minutes: 2, seconds: 15),
              duration: Duration(minutes: 10),
              accumulatedSeconds: -15,
              isForward: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('02:15'), findsOneWidget);
      expect(find.byIcon(Icons.fast_rewind_rounded), findsOneWidget);
    });
  });

  group('TvPlayerHeader Tests', () {
    testWidgets('renders title, subtitle, online count and back action',
        (tester) async {
      bool backed = false;

      await tester.pumpWidget(
        _wrapWithDpad(
          TvPlayerHeader(
            title: '【4K60FPS】超高清大片',
            subtitle: 'UP主：B站技术漫游',
            onlineCount: '3.5万',
            onBack: () {
              backed = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('【4K60FPS】超高清大片'), findsOneWidget);
      expect(find.text('UP主：B站技术漫游'), findsOneWidget);
      expect(find.text('3.5万 人在看'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump();
      expect(backed, isTrue);
    });
  });

  group('TvPlayerControls Decoupled Integration Tests', () {
    const qualities = [
      VideoQualityItem(qn: 80, desc: '1080P 高清'),
      VideoQualityItem(qn: 64, desc: '720P 高清'),
    ];

    testWidgets('normal video mode displays progress bar, seek buttons and quality button',
        (tester) async {
      bool playToggled = false;
      bool qualityOpened = false;

      await tester.pumpWidget(
        _wrapWithDpad(
          TvPlayerControls(
            title: '测试视频标题',
            isPlaying: true,
            position: const Duration(minutes: 2),
            duration: const Duration(minutes: 5),
            currentQn: 80,
            qualities: qualities,
            showDebugOverlay: false,
            isLive: false,
            onTogglePlay: () {
              playToggled = true;
            },
            onSeekBackward: () {},
            onSeekForward: () {},
            onOpenQuality: () {
              qualityOpened = true;
            },
            onToggleDebugOverlay: () {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header title
      expect(find.text('测试视频标题'), findsOneWidget);

      // Play pause button
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(playToggled, isTrue);

      // Quick Seek buttons (backward and forward)
      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);

      // Quality button
      expect(find.text('1080P 高清'), findsOneWidget);
      await tester.tap(find.text('1080P 高清'));
      await tester.pump();
      expect(qualityOpened, isTrue);

      // Progress bar times
      expect(find.text('02:00'), findsOneWidget);
      expect(find.text('05:00'), findsOneWidget);
    });

    testWidgets('live mode hides progress bar and quick seek buttons, shows live badge',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithDpad(
          TvPlayerControls(
            title: '测试直播间',
            subtitle: '主播：星海拾光',
            isPlaying: true,
            position: Duration.zero,
            duration: Duration.zero,
            currentQn: 10000,
            qualities: const [VideoQualityItem(qn: 10000, desc: '原画')],
            showDebugOverlay: false,
            isLive: true,
            onTogglePlay: () {},
            onSeekBackward: () {},
            onSeekForward: () {},
            onOpenQuality: () {},
            onToggleDebugOverlay: () {},
            onBack: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Subtitle
      expect(find.text('测试直播间'), findsOneWidget);
      expect(find.text('主播：星海拾光'), findsOneWidget);

      // Live badge
      expect(find.text('直播中'), findsOneWidget);

      // Progress bar and seek buttons should NOT be present in live mode
      expect(find.byIcon(Icons.replay_10_rounded), findsNothing);
      expect(find.byIcon(Icons.forward_10_rounded), findsNothing);
      expect(find.byType(TvProgressBar), findsNothing);
    });
  });
}
