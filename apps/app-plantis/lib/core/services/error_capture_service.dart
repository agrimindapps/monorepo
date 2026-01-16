import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service for capturing and logging errors globally in the app
class ErrorCaptureService {
  ErrorCaptureService({
    required IErrorLogRepository errorLogService,
  }) : _errorLogService = errorLogService;

  final IErrorLogRepository _errorLogService;

  // Context tracking
  String? _currentRoute;
  String? _currentPlantId;
  String? _currentPlantName;
  String? _currentTaskId;
  String? _userId;
  String? _userEmail;
  String? _appVersion;
  String? _screenSize;

  // Rate limiting
  final List<DateTime> _recentErrors = [];
  static const int _maxErrorsPerMinute = 10;

  // Deduplication
  final Map<String, DateTime> _errorCache = {};
  static const Duration _deduplicationWindow = Duration(minutes: 5);

  /// Initialize the error capture service
  Future<void> initialize() async {
    // Get app version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {
      _appVersion = 'unknown';
    }

    // Setup Flutter error handler
    FlutterError.onError = (details) {
      _captureFlutterError(details);
    };

    // Setup platform dispatcher error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      _captureError(
        error: error,
        stackTrace: stack,
        errorType: ErrorType.exception,
        fatal: true,
      );
      return true;
    };

    if (kDebugMode) {
      debugPrint('🔧 ErrorCaptureService initialized');
    }
  }

  /// Update current route context
  void setCurrentRoute(String route) {
    _currentRoute = route;
  }

  /// Update current plant context
  void setCurrentPlant({String? id, String? name}) {
    _currentPlantId = id;
    _currentPlantName = name;
  }

  /// Update current task context
  void setCurrentTask(String? taskId) {
    _currentTaskId = taskId;
  }

  /// Update user context
  void setUserContext({String? userId, String? email}) {
    _userId = userId;
    _userEmail = email;
  }

  /// Update screen size
  void updateScreenSize(double width, double height) {
    _screenSize = '${width.toInt()}x${height.toInt()}';
  }

  /// Capture Flutter framework errors
  void _captureFlutterError(FlutterErrorDetails details) {
    ErrorType errorType = ErrorType.exception;

    // Classify error based on library/context
    if (details.exception is AssertionError) {
      errorType = ErrorType.assertion;
    } else if (details.library?.contains('rendering') == true) {
      errorType = ErrorType.render;
    } else if (details.library?.contains('widgets') == true) {
      errorType = ErrorType.state;
    } else if (details.library?.contains('navigator') == true) {
      errorType = ErrorType.navigation;
    }

    _captureError(
      error: details.exception,
      stackTrace: details.stack,
      errorType: errorType,
      fatal: false,
      context: {
        'library': details.library ?? 'unknown',
        'summary': details.summary.toString(),
      },
    );
  }

  /// Capture generic errors
  Future<void> _captureError({
    required Object error,
    StackTrace? stackTrace,
    required ErrorType errorType,
    bool fatal = false,
    Map<String, dynamic>? context,
  }) async {
    // Rate limiting
    if (!_checkRateLimit()) {
      if (kDebugMode) {
        debugPrint('⚠️ Error rate limit exceeded, skipping error log');
      }
      return;
    }

    // Deduplication
    final errorHash = _generateErrorHash(error, stackTrace);
    if (!_shouldLogError(errorHash)) {
      if (kDebugMode) {
        debugPrint('⚠️ Duplicate error detected, skipping: $errorHash');
      }
      return;
    }

    // Determine severity
    final severity = _determineSeverity(error, errorType, fatal);

    // Build context
    final errorContext = <String, dynamic>{
      'route': _currentRoute,
      'plantId': _currentPlantId,
      'plantName': _currentPlantName,
      'taskId': _currentTaskId,
      'userId': _userId,
      'userEmail': _userEmail,
      'appVersion': _appVersion,
      'screenSize': _screenSize,
      'platform': _getPlatform(),
      'fatal': fatal,
      if (context != null) ...context,
    };

    // Create error entity
    final errorLog = ErrorLogEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      errorType: errorType,
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
      severity: severity,
      status: ErrorStatus.newError,
      context: errorContext,
      errorHash: errorHash,
      occurrences: 1,
      platform: _getPlatform(),
      createdAt: DateTime.now(),
      // updatedAt not present in entity
    );

    // Log to Firestore
    try {
      await _errorLogService.logError(errorLog);
      if (kDebugMode) {
        debugPrint('✅ Error logged: ${errorType.name} - $severity');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to log error: $e');
      }
    }
  }

  /// Capture network errors
  Future<void> captureNetworkError({
    required String url,
    int? statusCode,
    required String message,
  }) async {
    await _captureError(
      error: Exception('Network Error: $message'),
      stackTrace: StackTrace.current,
      errorType: ErrorType.network,
      context: {
        'url': url,
        'statusCode': statusCode,
      },
    );
  }

  /// Capture timeout errors
  Future<void> captureTimeoutError({
    required String operation,
    required Duration timeout,
  }) async {
    await _captureError(
      error: TimeoutException(
        'Operation timed out: $operation',
        timeout,
      ),
      stackTrace: StackTrace.current,
      errorType: ErrorType.timeout,
      context: {
        'operation': operation,
        'timeout_seconds': timeout.inSeconds,
      },
    );
  }

  /// Capture parsing errors
  Future<void> captureParsingError({
    required String dataType,
    required String message,
    String? rawData,
  }) async {
    await _captureError(
      error: FormatException('Parsing error: $message'),
      stackTrace: StackTrace.current,
      errorType: ErrorType.parsing,
      context: {
        'dataType': dataType,
        'rawData': rawData?.substring(0, 200), // Truncate for safety
      },
    );
  }

  /// Check rate limit
  bool _checkRateLimit() {
    final now = DateTime.now();
    _recentErrors.removeWhere(
      (time) => now.difference(time) > const Duration(minutes: 1),
    );

    if (_recentErrors.length >= _maxErrorsPerMinute) {
      return false;
    }

    _recentErrors.add(now);
    return true;
  }

  /// Generate error hash for deduplication
  String _generateErrorHash(Object error, StackTrace? stackTrace) {
    final errorString = error.toString();
    final stackString = stackTrace?.toString() ?? '';

    // Take first line of stack trace (most relevant)
    final firstStackLine = stackString.split('\n').firstOrNull ?? '';

    return '${errorString.hashCode}_${firstStackLine.hashCode}';
  }

  /// Check if error should be logged (deduplication)
  bool _shouldLogError(String errorHash) {
    final now = DateTime.now();
    final lastOccurrence = _errorCache[errorHash];

    if (lastOccurrence != null &&
        now.difference(lastOccurrence) < _deduplicationWindow) {
      return false;
    }

    _errorCache[errorHash] = now;
    return true;
  }

  /// Determine error severity
  ErrorSeverity _determineSeverity(
    Object error,
    ErrorType errorType,
    bool fatal,
  ) {
    if (fatal) return ErrorSeverity.critical;

    // Network errors are usually medium severity
    if (errorType == ErrorType.network) {
      return ErrorSeverity.medium;
    }

    // Timeout errors
    if (errorType == ErrorType.timeout) {
      return ErrorSeverity.medium;
    }

    // Assertion errors in debug mode
    if (error is AssertionError) {
      return ErrorSeverity.high;
    }

    // State errors can be critical
    if (errorType == ErrorType.state) {
      return ErrorSeverity.high;
    }

    // Render errors
    if (errorType == ErrorType.render) {
      return ErrorSeverity.medium;
    }

    // Default
    return ErrorSeverity.low;
  }

  /// Get current platform
  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'unknown';
  }

  /// Dispose resources
  void dispose() {
    _recentErrors.clear();
    _errorCache.clear();
  }
}
