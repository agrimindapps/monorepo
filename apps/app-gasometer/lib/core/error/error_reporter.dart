import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../services/analytics_service.dart';
import 'app_error.dart';

/// Service responsible for reporting errors to external services
/// Integrates with Firebase Crashlytics and Analytics
@injectable
class ErrorReporter {
  final AnalyticsService _analyticsService;

  const ErrorReporter(this._analyticsService);

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
        'status_code': (error as NetworkError?)?.statusCode,
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
      await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? 'anonymous');
      
      await Future.wait([
        FirebaseCrashlytics.instance.setCustomKey('is_anonymous', isAnonymous ?? true),
        FirebaseCrashlytics.instance.setCustomKey('is_premium', isPremium ?? false),
        if (appVersion != null)
          FirebaseCrashlytics.instance.setCustomKey('app_version', appVersion),
      ]);

      await _analyticsService.setUserProperties({
        'is_anonymous': (isAnonymous ?? true).toString(),
        'is_premium': (isPremium ?? false).toString(),
        if (appVersion != null) 'app_version': appVersion,
      });
    } catch (e) {
      // Don't throw error in error reporter
      print('Failed to set user context: $e');
    }
  }

  /// Clear user context (for logout)
  Future<void> clearUserContext() async {
    try {
      await setUserContext(
        userId: null,
        isAnonymous: true,
        isPremium: false,
      );
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
      // Set context information
      if (context != null) {
        await FirebaseCrashlytics.instance.setCustomKey('error_context', context);
      }

      // Set additional data as custom keys
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await FirebaseCrashlytics.instance.setCustomKey(
            entry.key,
            entry.value?.toString() ?? 'null',
          );
        }
      }

      // Set error type and severity
      await FirebaseCrashlytics.instance.setCustomKey('error_type', error.runtimeType.toString());
      await FirebaseCrashlytics.instance.setCustomKey('error_severity', error.severity.name);
      await FirebaseCrashlytics.instance.setCustomKey('is_recoverable', error.isRecoverable);

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
      await _analyticsService.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': error.runtimeType.toString(),
          'error_message': error.userMessage,
          'error_severity': error.severity.name,
          'is_recoverable': error.isRecoverable,
          'context': context ?? 'unknown',
          ...?additionalData,
        },
      );
    } catch (e) {
      print('Failed to report to Analytics: $e');
    }
  }

  /// Record breadcrumb for debugging context
  Future<void> recordBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseCrashlytics.instance.log('[$category] $message');
      
      if (data != null) {
        for (final entry in data.entries) {
          await FirebaseCrashlytics.instance.setCustomKey(
            'breadcrumb_${entry.key}',
            entry.value?.toString() ?? 'null',
          );
        }
      }
    } catch (e) {
      print('Failed to record breadcrumb: $e');
    }
  }

  /// Test error reporting (for debugging)
  Future<void> testErrorReporting() async {
    final testError = UnexpectedError(
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
    // Get error reporter from service locator if available
    try {
      // This would normally use dependency injection
      // For now, we'll create a simple reporter
      final reporter = ErrorReporter(AnalyticsService());
      await reporter.reportError(
        this,
        stackTrace: stackTrace,
        context: context,
        additionalData: additionalData,
        fatal: fatal,
      );
    } catch (e) {
      print('Failed to report error: $e');
    }
  }
}