import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:bili_tv/core/services/tv_focus_tracker.dart';
import 'package:bili_tv/core/services/tv_log_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempLogDir;

  setUp(() async {
    tempLogDir = Directory.systemTemp.createTempSync('tv_log_test_');
  });

  tearDown(() async {
    TvFocusTracker.dispose();
    await TvLogService.dispose();
    if (tempLogDir.existsSync()) {
      tempLogDir.deleteSync(recursive: true);
    }
  });

  group('TvLogService Tests', () {
    test('disables file logging by default in debug/test mode', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        maxFileSizeBytes: 10 * 1024,
      );

      expect(TvLogService.enableFileLogging, isFalse);

      final logFile = File('${tempLogDir.path}/app.log');
      expect(logFile.existsSync(), isFalse);

      Logger('TestApp').info('This should not be written to disk in debug mode');
      await TvLogService.flush();

      expect(logFile.existsSync(), isFalse);
      final recent = await TvLogService.readRecentLogs();
      expect(recent, isEmpty);
    });

    test('initializes and creates app.log file correctly when enableFileLogging is true', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        enableFileLogging: true,
        maxFileSizeBytes: 10 * 1024,
        maxBackupFiles: 3,
      );

      expect(TvLogService.enableFileLogging, isTrue);

      final logFile = File('${tempLogDir.path}/app.log');
      expect(logFile.existsSync(), isTrue);

      Logger('TestApp').info('Hello TV Logging World');
      await TvLogService.flush();

      final content = await logFile.readAsString();
      expect(content, contains('Hello TV Logging World'));
      expect(content, contains('[TestApp]'));
    });

    test('rotates log files when file size exceeds maxFileSizeBytes', () async {
      // 设置较小的单文件上限以触发快速轮转 (150 字节)
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        enableFileLogging: true,
        maxFileSizeBytes: 150,
        maxBackupFiles: 2,
      );

      final logger = Logger('RotateTest');

      // 写入第一批数据
      logger.info('Message chunk 1: 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF');
      await TvLogService.flush();

      // 写入第二批数据以触发第一次轮转 (app.log -> app.log.1)
      logger.info('Message chunk 2: 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF');
      await TvLogService.flush();

      // 写入第三批数据以触发第二次轮转 (app.log.1 -> app.log.2, app.log -> app.log.1)
      logger.info('Message chunk 3: 0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF');
      await TvLogService.flush();

      final files = await TvLogService.getAllLogFiles();
      expect(files.length, greaterThanOrEqualTo(2));

      final backup1 = File('${tempLogDir.path}/app.log.1');
      expect(backup1.existsSync(), isTrue);

      final totalSize = await TvLogService.getTotalLogSize();
      expect(totalSize, greaterThan(0));
    });

    test('reads recent logs and clears all logs correctly', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        enableFileLogging: true,
        maxFileSizeBytes: 10 * 1024,
      );

      final logger = Logger('ClearTest');
      logger.info('Line 1');
      logger.info('Line 2');
      logger.info('Line 3');
      await TvLogService.flush();

      final recent = await TvLogService.readRecentLogs(lineCount: 10);
      expect(recent, contains('Line 1'));
      expect(recent, contains('Line 3'));

      await TvLogService.clearAllLogs();
      final afterClear = await TvLogService.readRecentLogs();
      expect(afterClear, isEmpty);
    });
  });

  group('TvFocusTracker & Key Event Tests', () {
    test('logs focus node debugLabel and tracks snapshots', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        enableFileLogging: true,
        maxFileSizeBytes: 10 * 1024,
      );

      TvFocusTracker.init();

      final node = FocusNode(debugLabel: 'TestVideoCardFocus');
      TvFocusTracker.logFocus(node);
      await TvLogService.flush();

      final trail = TvFocusTracker.actionTrail;
      expect(trail, isNotEmpty);
      expect(trail.last.actionType, equals('FOCUS'));
      expect(trail.last.details, contains('TestVideoCardFocus'));

      final logs = await TvLogService.readRecentLogs();
      expect(logs, contains('[TvFocus]'));
      expect(logs, contains('TestVideoCardFocus'));

      node.dispose();
    });

    test('logs key events and formats DPAD, OK, BACK correctly', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        enableFileLogging: true,
        maxFileSizeBytes: 10 * 1024,
      );

      TvFocusTracker.init();

      // 模拟遥控器下键
      TvFocusTracker.logKey(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
          timeStamp: Duration(milliseconds: 100),
        ),
      );

      // 模拟遥控器 OK 键
      TvFocusTracker.logKey(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.select,
          logicalKey: LogicalKeyboardKey.select,
          timeStamp: Duration(milliseconds: 200),
        ),
      );

      // 模拟遥控器返回键
      TvFocusTracker.logKey(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.escape,
          logicalKey: LogicalKeyboardKey.escape,
          timeStamp: Duration(milliseconds: 300),
        ),
      );

      await TvLogService.flush();

      final trail = TvFocusTracker.actionTrail;
      expect(trail.length, greaterThanOrEqualTo(3));
      expect(trail.any((s) => s.details.contains('DPAD_DOWN')), isTrue);
      expect(trail.any((s) => s.details.contains('OK/SELECT')), isTrue);
      expect(trail.any((s) => s.details.contains('BACK')), isTrue);

      final logs = await TvLogService.readRecentLogs();
      expect(logs, contains('[TvKey]'));
      expect(logs, contains('DPAD_DOWN'));
      expect(logs, contains('OK/SELECT'));
      expect(logs, contains('BACK'));
    });

    test('dumps reproduction trail when focus is lost (primaryFocus == null)', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        enableFileLogging: true,
        maxFileSizeBytes: 10 * 1024,
      );

      TvFocusTracker.init();
      TvFocusTracker.clearTrail();

      final nodeA = FocusNode(debugLabel: 'CategoryTab_Recommend');
      TvFocusTracker.logFocus(nodeA);

      TvFocusTracker.logKey(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
          timeStamp: Duration(milliseconds: 150),
        ),
      );

      final nodeB = FocusNode(debugLabel: 'VideoCard_Item_0');
      TvFocusTracker.logFocus(nodeB);

      // 模拟按下选择键后失焦 (例如弹窗/页面关闭销毁导致焦点丢失)
      TvFocusTracker.logKey(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.enter,
          logicalKey: LogicalKeyboardKey.enter,
          timeStamp: Duration(milliseconds: 250),
        ),
      );

      TvFocusTracker.logFocus(null);
      await TvLogService.flush();

      final trailDump = TvFocusTracker.dumpReproductionTrail();
      expect(trailDump, contains('CategoryTab_Recommend'));
      expect(trailDump, contains('DPAD_DOWN'));
      expect(trailDump, contains('VideoCard_Item_0'));
      expect(trailDump, contains('OK/SELECT'));
      expect(trailDump, contains('焦点丢失'));

      final logs = await TvLogService.readRecentLogs();
      expect(logs, contains('焦点丢失前操作复现路径'));
      expect(logs, contains('CategoryTab_Recommend'));
      expect(logs, contains('VideoCard_Item_0'));

      nodeA.dispose();
      nodeB.dispose();
    });

    test('clears action trail on clearTrail and dispose', () {
      TvFocusTracker.init();
      final node1 = FocusNode(debugLabel: 'TempNode1');
      final node2 = FocusNode(debugLabel: 'TempNode2');

      TvFocusTracker.logFocus(node1);
      expect(TvFocusTracker.actionTrail, isNotEmpty);

      TvFocusTracker.clearTrail();
      expect(TvFocusTracker.actionTrail, isEmpty);

      TvFocusTracker.logFocus(node2);
      expect(TvFocusTracker.actionTrail, isNotEmpty);

      TvFocusTracker.dispose();
      expect(TvFocusTracker.actionTrail, isEmpty);

      node1.dispose();
      node2.dispose();
    });
  });
}
