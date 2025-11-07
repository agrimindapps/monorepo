import 'dart:async';

import 'package:core/core.dart' show injectable;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../di/injection.dart';
import '../services/gasometer_analytics_service.dart';

import 'app_error.dart';

/// Helper to check if Crashlytics is properly initialized
class _CrashlyticsHelper {
  static bool _isInitialized = false;
  static DateTime? _lastInitCheck;
  static const Duration _initCheckCooldown = Duration(seconds: 5);

  /// Check if Crashlytics is available and initialized
  static Future<bool> isAvailable() async {
    if (kDebugMode) {
      _isInitialized = false;
      return false;
    }
    if (_isInitialized) return true;
    final now = DateTime.now();
    if (_lastInitCheck != null &&
        now.difference(_lastInitCheck!) < _initCheckCooldown) {
      return _isInitialized;
    }

    _lastInitCheck = now;

    try {
      final instance = FirebaseCrashlytics.instance;
      await instance
          .log('Crashlytics availability check')
          .timeout(const Duration(seconds: 2));

      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics not available: $e');
      }
      _isInitialized = false;
      return false;
    }
  }
}

/// Service responsible for reporting errors to external services
/// Integrates with Firebase Crashlytics and Analytics
@injectable
class ErrorReporter {
  const ErrorReporter(this._analyticsService);
  final GasometerAnalyticsService _analyticsService;

  /// Report error to all configured services
  Future<void> reportError(
    AppError error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    await Future.wait([
      _reportToCrashlytics(error, stackTrace, context, additionalData, fatal),
      _reportToAnalytics(error, context, additionalData),
    ]);
  }

  /// Report non-fatal error for monitoring
  Future<void> reportNonFatalError(
    AppError error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await reportError(
      error,
      stackTrace: stackTrace,
      context: context,
      additionalData: additionalData,
      fatal: false,
    );
  }

  /// Report user action that resulted in error
  Future<void> reportUserActionError(
    AppError error, {
    required String action,
    String? screen,
    Map<String, dynamic>? parameters,
  }) async {
    await reportError(
      error,
      context: 'user_action',
      additionalData: {
        'action': action,
        'screen': screen,
        'parameters': parameters,
      },
    );
  }

  /// Report provider error with context
  Future<void> reportProviderError(
    AppError error, {
    required String providerName,
    required String method,
    Map<String, dynamic>? state,
  }) async {
    await reportError(
      error,
      context: 'provider_error',
      additionalData: {
        'provider': providerName,
        'method': method,
        'state': state,
      },
    );
  }

  /// Report network error with request details
  Future<void> reportNetworkError(
    NetworkError error, {
    String? endpoint,
    String? method,
    Map<String, dynamic>? requestData,
  }) async {
    await reportError(
      error,
      context: 'network_error',
      additionalData: {
        'endpoint': endpoint,
        'method': method,
        'status_code': error is ServerError
            ? (error as ServerError).statusCode
            : null,
        'request_data': requestData,
      },
    );
  }

  /// Report widget build error
  Future<void> reportWidgetError(
    AppError error, {
    required String widgetName,
    String? parentWidget,
    Map<String, dynamic>? props,
  }) async {
    await reportError(
      error,
      context: 'widget_error',
      additionalData: {
        'widget': widgetName,
        'parent': parentWidget,
        'props': props,
      },
    );
  }

  /// Set user context for error reporting
  Future<void> setUserContext({
    String? userId,
    bool? isAnonymous,
    bool? isPremium,
    String? appVersion,
  }) async {
    try {
      await _analyticsService.setUserProperties({
        'is_anonymous': (isAnonymous ?? true).toString(),
        'is_premium': (isPremium ?? false).toString(),
        if (appVersion != null) 'app_version': appVersion,
      });
      if (!kDebugMode && await _CrashlyticsHelper.isAvailable()) {
        final crashlyticsInstance = FirebaseCrashlytics.instance;

        await crashlyticsInstance.setUserIdentifier(userId ?? 'anonymous');

        await Future.wait([
          crashlyticsInstance.setCustomKey('is_anonymous', isAnonymous ?? true),
          crashlyticsInstance.setCustomKey('is_premium', isPremium ?? false),
          if (appVersion != null)
            crashlyticsInstance.setCustomKey('app_version', appVersion),
        ]);
      } else if (kDebugMode) {
        print('🔧 Debug mode: Skipping Crashlytics user context');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set user context: $e');
      }
    }
  }

  /// Clear user context (for logout)
  Future<void> clearUserContext() async {
    try {
      await setUserContext(userId: null, isAnonymous: true, isPremium: false);
    } catch (e) {
      print('Failed to clear user context: $e');
    }
  }

  /// Report to Firebase Crashlytics
  Future<void> _reportToCrashlytics(
    AppError error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
    bool fatal,
  ) async {
    try {
      if (!await _CrashlyticsHelper.isAvailable()) {
        if (kDebugMode) {
          print('Skipping Crashlytics report - not available');
        }
        return;
      }

      final crashlyticsInstance = FirebaseCrashlytics.instance;
      if (context != null) {
        await crashlyticsInstance.setCustomKey('error_context', context);
      }
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await crashlyticsInstance.setCustomKey(
            entry.key,
            entry.value?.toString() ?? 'null',
          );
        }
      }
      await crashlyticsInstance.setCustomKey(
        'error_type',
        error.runtimeType.toString(),
      );
      await crashlyticsInstance.setCustomKey(
        'error_severity',
        error.severity.name,
      );
      await crashlyticsInstance.setCustomKey(
        'is_recoverable',
        error.isRecoverable,
      );

      if (fatal) {
        await FirebaseCrashlytics.instance.recordFlutterFatalError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            context: DiagnosticsNode.message(context ?? 'Unknown context'),
            library: 'gasometer_error_boundary',
          ),
        );
      } else {
        await FirebaseCrashlytics.instance.recordFlutterError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            context: DiagnosticsNode.message(context ?? 'Unknown context'),
            library: 'gasometer_error_boundary',
          ),
        );
      }
    } catch (e) {
      print('Failed to report to Crashlytics: $e');
    }
  }

  /// Report to Analytics for error tracking
  Future<void> _reportToAnalytics(
    AppError error,
    String? context,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      final Map<String, Object> parameters = {
        'error_type': error.runtimeType.toString(),
        'error_message': error.displayMessage,
        'error_severity': error.severity.name,
        'is_recoverable': error.isRecoverable.toString(),
        'context': context ?? 'unknown',
      };
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          if (entry.value != null) {
            parameters[entry.key] = entry.value.toString();
          }
        }
      }

      await _analyticsService.logEvent('app_error', parameters);
    } catch (e) {
      debugPrint('Failed to report to Analytics: $e');
    }
  }

  /// Record breadcrumb for debugging context
  Future<void> recordBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!kDebugMode && await _CrashlyticsHelper.isAvailable()) {
        final crashlyticsInstance = FirebaseCrashlytics.instance;

        await crashlyticsInstance.log('[$category] $message');

        if (data != null) {
          for (final entry in data.entries) {
            await crashlyticsInstance.setCustomKey(
              'breadcrumb_${entry.key}',
              entry.value?.toString() ?? 'null',
            );
          }
        }
      } else {
        if (kDebugMode) {
          print('Breadcrumb [$category]: $message');
          if (data != null) {
            print('Data: $data');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to record breadcrumb: $e');
      }
    }
  }

  /// Test error reporting (for debugging)
  Future<void> testErrorReporting() async {
    const testError = UnexpectedError(
      message: 'Test error for validation',
      technicalDetails: 'This is a test error to validate error reporting',
    );

    await reportNonFatalError(
      testError,
      context: 'test',
      additionalData: {
        'test_timestamp': DateTime.now().toIso8601String(),
        'test_purpose': 'validation',
      },
    );
  }
}

/// Extension for easier error reporting from anywhere in the app
extension AppErrorReporting on AppError {
  /// Report this error using the error reporter
  Future<void> report({
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    try {
      // Use analytics service from DI instead of hardcoded mock
      final analyticsService = getIt<GasometerAnalyticsService>();
      final reporter = ErrorReporter(analyticsService);
      await reporter.reportError(
        this,
        stackTrace: stackTrace,
        context: context,
        additionalData: additionalData,
        fatal: fatal,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to report error: $e');
      }
    }
  }
}
