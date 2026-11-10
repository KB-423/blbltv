import 'dart:io';
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
    await TvLogService.dispose();
    if (tempLogDir.existsSync()) {
      tempLogDir.deleteSync(recursive: true);
    }
  });

  group('TvLogService Tests', () {
    test('initializes and creates app.log file correctly', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        maxFileSizeBytes: 10 * 1024,
        maxBackupFiles: 3,
      );

      final logFile = File('${tempLogDir.path}/app.log');
      expect(logFile.existsSync(), isTrue);

      Logger('TestApp').info('Hello TV Logging World');
      await TvLogService.flush();

      final content = await logFile.readAsString();
      expect(content, contains('Hello TV Logging World'));
      expect(content, contains('[TestApp]'));
    });

    test('rotates log files when file size exceeds maxFileSizeBytes', () async {
      // 设置较小的单文件上限以触发快速轮转 (100 字节)
      await TvLogService.init(
        customLogDirectory: tempLogDir,
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

  group('TvFocusTracker Tests', () {
    test('logs focus node debugLabel and handles null focus loss gracefully', () async {
      await TvLogService.init(
        customLogDirectory: tempLogDir,
        maxFileSizeBytes: 10 * 1024,
      );

      TvFocusTracker.init();

      final node = FocusNode(debugLabel: 'TestVideoCardFocus');
      TvFocusTracker.logFocus(node);
      await TvLogService.flush();

      String logs = await TvLogService.readRecentLogs();
      expect(logs, contains('[TvFocus]'));
      expect(logs, contains('TestVideoCardFocus'));

      // 模拟焦点丢失 (null)
      TvFocusTracker.logFocus(null);
      await TvLogService.flush();

      logs = await TvLogService.readRecentLogs();
      expect(logs, contains('焦点丢失'));

      node.dispose();
      TvFocusTracker.dispose();
    });
  });
}
