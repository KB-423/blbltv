import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// TV 端全量日志服务与文件轮转系统 (Log Rotation Service)
///
/// 功能特性：
/// 1. 挂接 `package:logging`，接管 `Logger.root`；
/// 2. 双通道输出：
///    - 控制台 (stdout / Android logcat)：通过 `debugPrint` 实时输出，方便调试；
///    - 本地磁盘文件持久化：保存在 `logs/app.log`，支持断连 ADB、重启设备后回溯问题；
/// 3. 日志轮转 (Log Rotation)：
///    - 默认单个日志文件上限 2MB (`maxFileSizeBytes`)；
///    - 默认最多保留 5 个历史备份文件 (`app.log.1` ~ `app.log.5`)；
///    - 达到大小限制时自动滚动移位，丢弃最旧日志，防止占满电视存储空间；
/// 4. 异步非阻塞队列写入：磁盘 I/O 绝不阻塞 UI 渲染帧（保证 60fps/120fps 丝滑）；
/// 5. 挂接全局 FlutterError 与未捕获异步异常，确保崩溃日志 100% 留存。
class TvLogService {
  TvLogService._();

  static const String _logFileName = 'app.log';
  static Directory? _logDirectory;
  static File? _currentLogFile;
  static IOSink? _sink;
  static int _currentFileSizeBytes = 0;
  static int _maxFileSizeBytes = 2 * 1024 * 1024; // 2MB
  static int _maxBackupFiles = 5;
  static bool _enableFileLogging = kReleaseMode;
  static bool _isInitialized = false;

  // 异步写入缓冲队列与并发互斥锁
  static final List<String> _pendingLogs = [];
  static bool _isWriting = false;
  static StreamSubscription<LogRecord>? _loggingSubscription;

  /// 获取当前日志存储目录
  static Directory? get logDirectory => _logDirectory;

  /// 是否启用了本地文件持久化 (默认仅在 Release 模式下生效)
  static bool get enableFileLogging => _enableFileLogging;

  /// 是否已初始化
  static bool get isInitialized => _isInitialized;

  /// 初始化日志服务
  /// [customLogDirectory] 可选指定目录（单元测试非常有用）
  /// [maxFileSizeBytes] 单个日志文件上限（默认 2MB）
  /// [maxBackupFiles] 保留的最多备份数量（默认 5 个）
  /// [logLevel] 最低记录等级（默认 Level.ALL）
  /// [enableFileLogging] 是否开启磁盘日志文件写入（默认仅在 Release 模式下为 true）
  static Future<void> init({
    Directory? customLogDirectory,
    int maxFileSizeBytes = 2 * 1024 * 1024,
    int maxBackupFiles = 5,
    Level logLevel = Level.ALL,
    bool? enableFileLogging,
  }) async {
    if (_isInitialized) return;

    _enableFileLogging = enableFileLogging ?? kReleaseMode;
    _maxFileSizeBytes = maxFileSizeBytes;
    _maxBackupFiles = maxBackupFiles;

    // 1. 仅在开启文件持久化时（Release模式或手动指定）解析目录并创建日志文件
    if (_enableFileLogging) {
      if (customLogDirectory != null) {
        _logDirectory = customLogDirectory;
      } else {
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          _logDirectory = Directory('${appDocDir.path}/logs');
        } catch (_) {
          // 在单元测试或无 path_provider 实现环境下平滑回退至系统临时目录
          final temp = Directory.systemTemp.path;
          _logDirectory = Directory('$temp/bili_tv_logs');
        }
      }

      if (!_logDirectory!.existsSync()) {
        _logDirectory!.createSync(recursive: true);
      }

      _currentLogFile = File('${_logDirectory!.path}/$_logFileName');
      if (_currentLogFile!.existsSync()) {
        _currentFileSizeBytes = _currentLogFile!.lengthSync();
      } else {
        _currentLogFile!.createSync(recursive: true);
        _currentFileSizeBytes = 0;
      }

      _openSink();
    }

    // 2. 配置 package:logging
    Logger.root.level = logLevel;
    _loggingSubscription?.cancel();
    _loggingSubscription = Logger.root.onRecord.listen((record) {
      _handleRecord(record);
    });

    // 3. 挂接 Flutter 框架级未捕获异常
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      Logger('FlutterError').severe(
        details.exceptionAsString(),
        details.exception,
        details.stack,
      );
      originalOnError?.call(details);
    };

    // 4. 挂接 Dart 原生异步平台异常
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger('UncaughtAsync').severe(
        '未捕获的异步平台异常: $error',
        error,
        stack,
      );
      return false; // 继续交由 Flutter 处理或中断
    };

    _isInitialized = true;
    final dirInfo = _logDirectory?.path ?? '(磁盘持久化已关闭，仅输出至终端与系统日志)';
    Logger('TvLogService').info(
      '日志系统初始化成功 | 磁盘持久化: ${_enableFileLogging ? "开启" : "关闭"} | 目录: $dirInfo | 单文件上限: ${_maxFileSizeBytes ~/ 1024} KB | 备份数: $_maxBackupFiles',
    );
  }

  static void _openSink() {
    _sink?.close();
    _sink = _currentLogFile!.openWrite(mode: FileMode.append);
  }

  /// 格式化单条日志记录
  static String formatRecord(LogRecord record) {
    final timeStr = record.time.toIso8601String().replaceAll('T', ' ');
    final level = record.level.name.padRight(7);
    final logger = record.loggerName.isNotEmpty ? '[${record.loggerName}] ' : '';
    final msg = '$timeStr [$level] $logger${record.message}';

    if (record.error != null || record.stackTrace != null) {
      final buffer = StringBuffer(msg);
      if (record.error != null) {
        buffer.write('\nError: ${record.error}');
      }
      if (record.stackTrace != null) {
        buffer.write('\nStackTrace:\n${record.stackTrace}');
      }
      return buffer.toString();
    }
    return msg;
  }

  static void _handleRecord(LogRecord record) {
    final formatted = formatRecord(record);

    // 1. 控制台与 logcat 实时输出
    if (kDebugMode || record.level >= Level.INFO) {
      debugPrint(formatted);
    }

    // 2. 仅在开启文件持久化时（默认 Release 模式）加入异步落盘队列
    if (_enableFileLogging) {
      _enqueueLog('$formatted\n');
    }
  }

  static void _enqueueLog(String log) {
    _pendingLogs.add(log);
    if (!_isWriting) {
      _processPendingLogs();
    }
  }

  static Future<void> _processPendingLogs() async {
    if (_isWriting || _pendingLogs.isEmpty) return;
    _isWriting = true;

    try {
      while (_pendingLogs.isNotEmpty) {
        final chunk = _pendingLogs.removeAt(0);
        final bytesCount = chunk.length; // UTF-8 近似字节数

        // 检查是否需要执行日志轮转
        if (_currentFileSizeBytes + bytesCount > _maxFileSizeBytes) {
          await _rotateLogs();
        }

        _sink?.write(chunk);
        _currentFileSizeBytes += bytesCount;
      }
      await _sink?.flush();
    } catch (e) {
      debugPrint('[TvLogService] 日志写入异常: $e');
    } finally {
      _isWriting = false;
      if (_pendingLogs.isNotEmpty) {
        _processPendingLogs();
      }
    }
  }

  /// 执行日志文件轮转 (Rotate Logs)
  /// app.log -> app.log.1 -> app.log.2 -> ... -> app.log.N (超出的删除)
  static Future<void> _rotateLogs() async {
    try {
      await _sink?.flush();
      await _sink?.close();
      _sink = null;

      final dirPath = _logDirectory!.path;

      // 1. 删除最旧的备份文件 (app.log.maxBackupFiles)
      final oldestFile = File('$dirPath/$_logFileName.$_maxBackupFiles');
      if (oldestFile.existsSync()) {
        oldestFile.deleteSync();
      }

      // 2. 依次顺延现有备份文件 (从后往前 rename)
      for (int i = _maxBackupFiles - 1; i >= 1; i--) {
        final currentBackup = File('$dirPath/$_logFileName.$i');
        if (currentBackup.existsSync()) {
          final targetBackup = File('$dirPath/$_logFileName.${i + 1}');
          currentBackup.renameSync(targetBackup.path);
        }
      }

      // 3. 将当前 app.log 重命名为 app.log.1
      if (_currentLogFile!.existsSync()) {
        final firstBackup = File('$dirPath/$_logFileName.1');
        _currentLogFile!.renameSync(firstBackup.path);
      }

      // 4. 重建新的 app.log 并打开写入句柄
      _currentLogFile = File('$dirPath/$_logFileName');
      _currentLogFile!.createSync(recursive: true);
      _currentFileSizeBytes = 0;
      _openSink();
    } catch (e) {
      debugPrint('[TvLogService] 日志轮转异常: $e');
      _openSink();
    }
  }

  /// 强制刷新当前缓冲区到磁盘
  static Future<void> flush() async {
    if (!_enableFileLogging) return;
    while (_pendingLogs.isNotEmpty || _isWriting) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
    await _sink?.flush();
  }

  /// 获取当前所有日志文件（主日志 + 备份日志，按新旧排序）
  static Future<List<File>> getAllLogFiles() async {
    await flush();
    if (_logDirectory == null || !_logDirectory!.existsSync()) return [];

    final files = <File>[];
    if (_currentLogFile != null && _currentLogFile!.existsSync()) {
      files.add(_currentLogFile!);
    }

    for (int i = 1; i <= _maxBackupFiles; i++) {
      final f = File('${_logDirectory!.path}/$_logFileName.$i');
      if (f.existsSync()) {
        files.add(f);
      }
    }
    return files;
  }

  /// 获取所有日志文件的总占用大小（字节）
  static Future<int> getTotalLogSize() async {
    final files = await getAllLogFiles();
    int total = 0;
    for (final f in files) {
      total += await f.length();
    }
    return total;
  }

  /// 读取最新的日志文本
  static Future<String> readRecentLogs({int lineCount = 300}) async {
    await flush();
    if (_currentLogFile == null || !_currentLogFile!.existsSync()) return '';

    try {
      final lines = await _currentLogFile!.readAsLines();
      if (lines.length <= lineCount) {
        return lines.join('\n');
      }
      return lines.sublist(lines.length - lineCount).join('\n');
    } catch (e) {
      return '读取日志失败: $e';
    }
  }

  /// 清理所有历史日志
  static Future<void> clearAllLogs() async {
    if (!_enableFileLogging || _logDirectory == null) return;
    await flush();
    try {
      await _sink?.close();
      _sink = null;

      final files = _logDirectory?.listSync() ?? [];
      for (final entity in files) {
        if (entity is File && entity.path.contains(_logFileName)) {
          entity.deleteSync();
        }
      }

      _currentLogFile = File('${_logDirectory!.path}/$_logFileName');
      _currentLogFile!.createSync(recursive: true);
      _currentFileSizeBytes = 0;
      _openSink();
    } catch (e) {
      debugPrint('[TvLogService] 清理日志异常: $e');
      _openSink();
    }
  }

  /// 关闭日志服务（应用退出或销毁测试时调用）
  static Future<void> dispose() async {
    await flush();
    await _loggingSubscription?.cancel();
    _loggingSubscription = null;
    await _sink?.close();
    _sink = null;
    _currentLogFile = null;
    _logDirectory = null;
    _currentFileSizeBytes = 0;
    _pendingLogs.clear();
    _isWriting = false;
    _isInitialized = false;
  }
}
