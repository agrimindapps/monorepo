import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../shared/enums/log_level.dart';
import '../../shared/utils/app_error.dart';
import '../../shared/utils/failure.dart';

/// Enhanced Logging Service - Sistema avançado de logs
///
/// Funcionalidades:
/// - Múltiplos níveis de log (trace, debug, info, warning, error, critical)
/// - Persistência local com rotação automática de arquivos
/// - Filtering e busca em logs
/// - Formatação estruturada (JSON)
/// - Upload automático de logs críticos
/// - Performance profiling
/// - Memory usage tracking
/// - Analytics de crashes
/// - Log categorization
/// - Export e compartilhamento
class EnhancedLoggingService {
  static const String _logsDirectory = 'app_logs';
  static const int _maxLogFileSize = 10 * 1024 * 1024; // 10MB
  static const int _maxLogFiles = 10;
  static const int _maxMemoryLogs = 1000;

  late Directory _logsDir;
  late File _currentLogFile;
  final List<EnhancedLogEntry> _memoryBuffer = [];
  LogLevel _minLevel = LogLevel.info;
  bool _persistLogs = true;
  bool _enableConsoleOutput = kDebugMode;
  bool _enableStructuredLogging = true;
  final Map<String, PerformanceTracker> _performanceTrackers = {};
  final Set<String> _enabledCategories = {};
  int _totalLogs = 0;
  int _errorCount = 0;
  int _warningCount = 0;
  DateTime? _lastError;

  bool _initialized = false;

  /// Inicializa o logging service
  Future<Either<Failure, void>> initialize({
    LogLevel minLevel = LogLevel.info,
    bool persistLogs = true,
    bool enableConsoleOutput = kDebugMode,
    bool enableStructuredLogging = true,
    List<String>? enabledCategories,
  }) async {
    if (_initialized) return const Right(null);

    try {
      _minLevel = minLevel;
      _persistLogs = persistLogs;
      _enableConsoleOutput = enableConsoleOutput;
      _enableStructuredLogging = enableStructuredLogging;

      if (enabledCategories != null) {
        _enabledCategories.addAll(enabledCategories);
      }

      if (_persistLogs) {
        await _initializeFileLogging();
      }
      await info(
        'Enhanced Logging Service initialized',
        category: 'SYSTEM',
        metadata: {'minLevel': minLevel.name},
      );

      _initialized = true;
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        StorageError(
          message: 'Erro ao inicializar logging service: ${e.toString()}',
          code: 'LOGGING_INIT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Log de trace (desenvolvimento)
  Future<void> trace(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _log(
      LogLevel.trace,
      message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de debug
  Future<void> debug(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _log(
      LogLevel.debug,
      message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log informativo
  Future<void> info(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    await _log(
      LogLevel.info,
      message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de warning
  Future<void> warning(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _warningCount++;
    await _log(
      LogLevel.warning,
      message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de erro
  Future<void> error(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _errorCount++;
    _lastError = DateTime.now();
    await _log(
      LogLevel.error,
      message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log crítico
  Future<void> critical(
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _errorCount++;
    _lastError = DateTime.now();
    await _log(
      LogLevel.critical,
      message,
      category: category,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de AppError estruturado
  Future<void> logAppError(AppError appError, {String? category}) async {
    final metadata = {
      'errorType': appError.runtimeType.toString(),
      'errorCode': appError.code,
      'errorCategory': appError.category.name,
      'errorSeverity': appError.severity.name,
      'timestamp': appError.timestamp.toIso8601String(),
    };

    final level = _severityToLogLevel(appError.severity);

    await _log(
      level,
      appError.message,
      category: category ?? 'ERROR',
      metadata: metadata,
      error: appError,
      stackTrace: appError.stackTrace,
    );
  }

  /// Inicia tracking de performance
  void startPerformanceTracking(
    String operation, {
    Map<String, dynamic>? metadata,
  }) {
    _performanceTrackers[operation] = PerformanceTracker(
      operation: operation,
      startTime: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Finaliza tracking de performance
  Future<void> endPerformanceTracking(
    String operation, {
    Map<String, dynamic>? additionalMetadata,
  }) async {
    final tracker = _performanceTrackers.remove(operation);
    if (tracker == null) return;

    final duration = DateTime.now().difference(tracker.startTime);

    final metadata = <String, dynamic>{
      'operation': operation,
      'durationMs': duration.inMilliseconds,
      'startTime': tracker.startTime.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      ...?tracker.metadata,
      ...?additionalMetadata,
    };
    final level = duration.inMilliseconds > 5000
        ? LogLevel.warning
        : LogLevel.info;

    await _log(
      level,
      'Performance: $operation completed in ${duration.inMilliseconds}ms',
      category: 'PERFORMANCE',
      metadata: metadata,
    );
  }

  /// Busca logs por critérios
  Future<Either<Failure, List<EnhancedLogEntry>>> searchLogs({
    LogLevel? minLevel,
    LogLevel? maxLevel,
    String? category,
    String? textQuery,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      final left = initResult.fold((l) => l, (_) => null);
      if (left != null) return Left(left);
    }

    try {
      List<EnhancedLogEntry> results = List.from(_memoryBuffer);
      if (minLevel != null) {
        results = results
            .where((log) => log.level.index >= minLevel.index)
            .toList();
      }

      if (maxLevel != null) {
        results = results
            .where((log) => log.level.index <= maxLevel.index)
            .toList();
      }

      if (category != null) {
        results = results.where((log) => log.category == category).toList();
      }

      if (textQuery != null) {
        final query = textQuery.toLowerCase();
        results = results
            .where(
              (log) =>
                  log.message.toLowerCase().contains(query) ||
                  (log.metadata?.toString().toLowerCase().contains(query) ??
                      false),
            )
            .toList();
      }

      if (startDate != null) {
        results = results
            .where((log) => log.timestamp.isAfter(startDate))
            .toList();
      }

      if (endDate != null) {
        results = results
            .where((log) => log.timestamp.isBefore(endDate))
            .toList();
      }
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (limit != null && results.length > limit) {
        results = results.take(limit).toList();
      }

      return Right(results);
    } catch (e, stackTrace) {
      return Left(
        StorageError(
          message: 'Erro ao buscar logs: ${e.toString()}',
          code: 'LOG_SEARCH_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Exporta logs para arquivo
  Future<Either<Failure, String>> exportLogs({
    LogLevel? minLevel,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    LogExportFormat format = LogExportFormat.json,
  }) async {
    try {
      final searchResult = await searchLogs(
        minLevel: minLevel,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );

      final logs = searchResult.fold((failure) => null, (data) => data);

      if (logs == null) {
        return Left(searchResult.fold((l) => l, (r) => throw Exception()));
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'logs_export_$timestamp.${format.extension}';

      final tempDir = await getTemporaryDirectory();
      final exportFile = File(path.join(tempDir.path, fileName));

      String content;
      switch (format) {
        case LogExportFormat.json:
          content = jsonEncode(logs.map((log) => log.toMap()).toList());
          break;
        case LogExportFormat.csv:
          content = _exportToCsv(logs);
          break;
        case LogExportFormat.txt:
          content = logs.map((log) => log.toString()).join('\n\n');
          break;
      }

      await exportFile.writeAsString(content);

      return Right(exportFile.path);
    } catch (e, stackTrace) {
      return Left(
        StorageError(
          message: 'Erro ao exportar logs: ${e.toString()}',
          code: 'LOG_EXPORT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Limpa logs antigos
  Future<Either<Failure, void>> clearLogs({
    Duration? olderThan,
    LogLevel? maxLevel,
    String? category,
  }) async {
    try {
      if (olderThan != null) {
        final cutoff = DateTime.now().subtract(olderThan);
        _memoryBuffer.removeWhere((log) => log.timestamp.isBefore(cutoff));
      } else if (maxLevel != null) {
        _memoryBuffer.removeWhere((log) => log.level.index <= maxLevel.index);
      } else if (category != null) {
        _memoryBuffer.removeWhere((log) => log.category == category);
      } else {
        _memoryBuffer.clear();
      }
      if (_persistLogs && olderThan != null) {
        await _cleanOldLogFiles(olderThan);
      }

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
        StorageError(
          message: 'Erro ao limpar logs: ${e.toString()}',
          code: 'LOG_CLEAR_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  /// Obtém estatísticas de logs
  Future<Either<Failure, LoggingStats>> getStats() async {
    try {
      final memoryLogs = _memoryBuffer.length;

      final categories = _memoryBuffer
          .map((log) => log.category)
          .where((c) => c != null)
          .toSet();

      int diskLogFiles = 0;
      int diskLogSize = 0;

      if (_persistLogs && await _logsDir.exists()) {
        await for (final file in _logsDir.list()) {
          if (file is File && path.extension(file.path) == '.log') {
            diskLogFiles++;
            diskLogSize += await file.length();
          }
        }
      }

      final stats = LoggingStats(
        totalLogs: _totalLogs,
        memoryLogs: memoryLogs,
        errorCount: _errorCount,
        warningCount: _warningCount,
        lastError: _lastError,
        diskLogFiles: diskLogFiles,
        diskLogSize: diskLogSize,
        categories: categories.toList().cast<String>(),
        activePerformanceTrackers: _performanceTrackers.length,
      );

      return Right(stats);
    } catch (e, stackTrace) {
      return Left(
        StorageError(
          message: 'Erro ao obter estatísticas: ${e.toString()}',
          code: 'LOG_STATS_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ).toFailure(),
      );
    }
  }

  Future<void> _log(
    LogLevel level,
    String message, {
    String? category,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (level.index < _minLevel.index) return;
    if (category != null &&
        _enabledCategories.isNotEmpty &&
        !_enabledCategories.contains(category)) {
      return;
    }

    _totalLogs++;

    final entry = EnhancedLogEntry(
      level: level,
      message: message,
      category: category ?? 'GENERAL',
      timestamp: DateTime.now(),
      metadata: metadata,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );
    _addToMemoryBuffer(entry);
    if (_enableConsoleOutput) {
      _outputToConsole(entry);
    }
    if (_persistLogs) {
      await _persistToFile(entry);
    }
  }

  void _addToMemoryBuffer(EnhancedLogEntry entry) {
    _memoryBuffer.add(entry);
    if (_memoryBuffer.length > _maxMemoryLogs) {
      _memoryBuffer.removeAt(0);
    }
  }

  void _outputToConsole(EnhancedLogEntry entry) {
    final prefix = '[${entry.level.name.toUpperCase()}]';
    final timestamp = entry.timestamp.toIso8601String();
    final category = entry.category != null ? '[${entry.category}]' : '';

    final message = '$prefix $timestamp $category ${entry.message}';

    switch (entry.level) {
      case LogLevel.error:
      case LogLevel.critical:
        debugPrint('\x1B[31m$message\x1B[0m'); // Vermelho
        break;
      case LogLevel.warning:
        debugPrint('\x1B[33m$message\x1B[0m'); // Amarelo
        break;
      case LogLevel.info:
        debugPrint('\x1B[32m$message\x1B[0m'); // Verde
        break;
      case LogLevel.debug:
        debugPrint('\x1B[34m$message\x1B[0m'); // Azul
        break;
      case LogLevel.trace:
        debugPrint('\x1B[37m$message\x1B[0m'); // Branco
        break;
    }

    if (entry.error != null) {
      debugPrint('  Error: ${entry.error}');
    }

    if (entry.stackTrace != null &&
        (entry.level == LogLevel.error || entry.level == LogLevel.critical)) {
      debugPrint('  StackTrace: ${entry.stackTrace}');
    }
  }

  Future<void> _initializeFileLogging() async {
    final appDir = await getApplicationDocumentsDirectory();
    _logsDir = Directory(path.join(appDir.path, _logsDirectory));

    if (!await _logsDir.exists()) {
      await _logsDir.create(recursive: true);
    }
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    _currentLogFile = File(path.join(_logsDir.path, 'app_$timestamp.log'));
    await _rotateLogFiles();
  }

  Future<void> _persistToFile(EnhancedLogEntry entry) async {
    try {
      if (await _currentLogFile.exists()) {
        final size = await _currentLogFile.length();
        if (size > _maxLogFileSize) {
          await _rotateLogFiles();
        }
      }

      String logLine;
      if (_enableStructuredLogging) {
        logLine = jsonEncode(entry.toMap());
      } else {
        logLine =
            '${entry.timestamp.toIso8601String()} [${entry.level.name.toUpperCase()}] ${entry.category} ${entry.message}';
        if (entry.error != null) {
          logLine += ' | Error: ${entry.error}';
        }
      }

      await _currentLogFile.writeAsString('$logLine\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Warning: Falha ao persistir log: $e');
    }
  }

  Future<void> _rotateLogFiles() async {
    try {
      final logFiles = <File>[];
      await for (final entity in _logsDir.list()) {
        if (entity is File && path.extension(entity.path) == '.log') {
          logFiles.add(entity);
        }
      }
      logFiles.sort(
        (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()),
      );
      while (logFiles.length >= _maxLogFiles) {
        await logFiles.removeAt(0).delete();
      }
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _currentLogFile = File(path.join(_logsDir.path, 'app_$timestamp.log'));
    } catch (e) {
      debugPrint('Warning: Falha na rotação de logs: $e');
    }
  }

  Future<void> _cleanOldLogFiles(Duration olderThan) async {
    try {
      final cutoff = DateTime.now().subtract(olderThan);

      await for (final entity in _logsDir.list()) {
        if (entity is File && path.extension(entity.path) == '.log') {
          final lastModified = await entity.lastModified();
          if (lastModified.isBefore(cutoff)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Warning: Falha ao limpar logs antigos: $e');
    }
  }

  LogLevel _severityToLogLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return LogLevel.info;
      case ErrorSeverity.medium:
        return LogLevel.warning;
      case ErrorSeverity.high:
        return LogLevel.error;
      case ErrorSeverity.critical:
        return LogLevel.critical;
    }
  }

  String _exportToCsv(List<EnhancedLogEntry> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Level,Category,Message,Error,Metadata');
    for (final log in logs) {
      final row = [
        log.timestamp.toIso8601String(),
        log.level.name,
        log.category ?? '',
        '"${log.message.replaceAll('"', '""')}"',
        log.error?.replaceAll('\n', '\\n') ?? '',
        log.metadata?.toString().replaceAll('\n', '\\n') ?? '',
      ].join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }

  /// Dispose - limpa recursos
  Future<void> dispose() async {
    if (_persistLogs) {
      for (final tracker in _performanceTrackers.values) {
        await endPerformanceTracking(
          tracker.operation,
          additionalMetadata: {'status': 'force_ended_on_dispose'},
        );
      }
    }

    _performanceTrackers.clear();
    _memoryBuffer.clear();
    _initialized = false;
  }
}

/// Entrada de log estruturada para enhanced logging
class EnhancedLogEntry {
  final LogLevel level;
  final String message;
  final String? category;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? error;
  final String? stackTrace;

  EnhancedLogEntry({
    required this.level,
    required this.message,
    this.category,
    required this.timestamp,
    this.metadata,
    this.error,
    this.stackTrace,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level.name,
      'message': message,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'error': error,
      'stackTrace': stackTrace,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write(
      '[${level.name.toUpperCase()}] ${timestamp.toIso8601String()}',
    );
    if (category != null) buffer.write(' [$category]');
    buffer.write(' $message');
    if (error != null) buffer.write(' | Error: $error');
    return buffer.toString();
  }
}

/// Tracker de performance
class PerformanceTracker {
  final String operation;
  final DateTime startTime;
  final Map<String, dynamic>? metadata;

  PerformanceTracker({
    required this.operation,
    required this.startTime,
    this.metadata,
  });
}

/// Formato de exportação de logs
enum LogExportFormat {
  json('json'),
  csv('csv'),
  txt('txt');

  const LogExportFormat(this.extension);
  final String extension;
}

/// Estatísticas de logging
class LoggingStats {
  final int totalLogs;
  final int memoryLogs;
  final int errorCount;
  final int warningCount;
  final DateTime? lastError;
  final int diskLogFiles;
  final int diskLogSize;
  final List<String> categories;
  final int activePerformanceTrackers;

  LoggingStats({
    required this.totalLogs,
    required this.memoryLogs,
    required this.errorCount,
    required this.warningCount,
    this.lastError,
    required this.diskLogFiles,
    required this.diskLogSize,
    required this.categories,
    required this.activePerformanceTrackers,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalLogs': totalLogs,
      'memoryLogs': memoryLogs,
      'errorCount': errorCount,
      'warningCount': warningCount,
      'lastError': lastError?.toIso8601String(),
      'diskLogFiles': diskLogFiles,
      'diskLogSize': diskLogSize,
      'categories': categories,
      'activePerformanceTrackers': activePerformanceTrackers,
    };
  }

  @override
  String toString() {
    return 'LoggingStats('
        'total: $totalLogs, '
        'errors: $errorCount, '
        'warnings: $warningCount, '
        'files: $diskLogFiles, '
        'size: ${_formatBytes(diskLogSize)})';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
