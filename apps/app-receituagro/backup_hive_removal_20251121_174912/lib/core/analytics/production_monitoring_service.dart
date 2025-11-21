import 'dart:async';
import 'dart:io';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Production Monitoring Service for Sprint 4 Features
/// 
/// Features:
/// - Error tracking and reporting
/// - Performance monitoring
/// - Feature usage analytics
/// - Sync performance tracking
/// - Device management monitoring
/// - Premium service monitoring
/// - A/B test tracking
class ProductionMonitoringService {
  static ProductionMonitoringService? _instance;
  static ProductionMonitoringService get instance => _instance ??= ProductionMonitoringService._();
  
  ProductionMonitoringService._();

  late IAnalyticsRepository _analytics;
  late ICrashlyticsRepository _crashlytics;
  bool _isInitialized = false;
  
  final Map<String, DateTime> _performanceStartTimes = {};
  final Map<String, int> _errorCounts = {};

  /// Initialize monitoring service
  Future<void> initialize({
    required IAnalyticsRepository analytics,
    required ICrashlyticsRepository crashlytics,
  }) async {
    if (_isInitialized) return;

    _analytics = analytics;
    _crashlytics = crashlytics;
    
    try {
      FlutterError.onError = _handleFlutterError;
      PlatformDispatcher.instance.onError = _handlePlatformError;
      await _crashlytics.setUserId('receituagro_user_${DateTime.now().millisecondsSinceEpoch}');
      await _crashlytics.setCustomKey(key: 'app_name', value: 'receituagro');
      await _crashlytics.setCustomKey(key: 'sprint_version', value: 'sprint_4');
      
      _isInitialized = true;
      await _analytics.logEvent(
        'monitoring_service_initialized',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Platform.operatingSystem,
          'app_version': '1.0.0',
        },
      );
      
    } catch (e) {
      debugPrint('Failed to initialize monitoring service: $e');
    }
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    _crashlytics.recordError(
      exception: details.exception,
      stackTrace: details.stack ?? StackTrace.empty,
      reason: 'Flutter Error: ${details.library}',
      fatal: false,
    );
    _analytics.logEvent(
      'flutter_error_occurred',
      parameters: {
        'error_type': details.exception.runtimeType.toString(),
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    final errorKey = details.exception.runtimeType.toString();
    _errorCounts[errorKey] = (_errorCounts[errorKey] ?? 0) + 1;
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Handle platform errors
  bool _handlePlatformError(Object error, StackTrace stack) {
    _crashlytics.recordError(
      exception: error,
      stackTrace: stack,
      reason: 'Platform Error',
      fatal: false,
    );

    _analytics.logEvent(
      'platform_error_occurred',
      parameters: {
        'error_type': error.runtimeType.toString(),
        'error_message': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    return true; // Handled
  }

  /// Device Management Monitoring

  /// Track device management operations
  Future<void> trackDeviceManagement(DeviceManagementEvent event, Map<String, dynamic> parameters) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'device_management_${event.name}',
      parameters: {
        ...parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _getSessionId(),
      },
    );
  }

  /// Track device listing performance
  Future<void> trackDeviceListingPerformance(int deviceCount, Duration loadTime) async {
    await _analytics.logEvent(
      'device_listing_performance',
      parameters: {
        'device_count': deviceCount,
        'load_time_ms': loadTime.inMilliseconds,
        'performance_category': _categorizePerformance(loadTime.inMilliseconds),
      },
    );
  }

  /// Premium Service Monitoring

  /// Track premium feature usage
  Future<void> trackPremiumFeatureUsage(String featureName, bool isAccessible) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'premium_feature_usage',
      parameters: {
        'feature_name': featureName,
        'is_accessible': isAccessible,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track subscription flow
  Future<void> trackSubscriptionFlow(SubscriptionFlowEvent event, Map<String, dynamic> parameters) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'subscription_flow_${event.name}',
      parameters: {
        ...parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'user_type': 'freemium', // This would come from actual user state
      },
    );
  }

  /// Track purchase flow performance
  Future<void> trackPurchaseFlowPerformance(String step, Duration duration) async {
    await _analytics.logEvent(
      'purchase_flow_performance',
      parameters: {
        'step': step,
        'duration_ms': duration.inMilliseconds,
        'performance_category': _categorizePerformance(duration.inMilliseconds),
      },
    );
  }

  /// Feature Flags & A/B Testing Monitoring

  /// Track feature flag exposure
  Future<void> trackFeatureFlagExposure(String flagName, bool isEnabled, String variant) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'feature_flag_exposure',
      parameters: {
        'flag_name': flagName,
        'is_enabled': isEnabled,
        'variant': variant,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track A/B test conversion
  Future<void> trackABTestConversion(String testName, String variant, String conversionEvent) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'ab_test_conversion',
      parameters: {
        'test_name': testName,
        'variant': variant,
        'conversion_event': conversionEvent,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Settings & Sync Monitoring

  /// Track settings sync operations
  Future<void> trackSettingsSync(SettingsSyncEvent event, Map<String, dynamic> parameters) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'settings_sync_${event.name}',
      parameters: {
        ...parameters,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track sync performance
  Future<void> trackSyncPerformance(String syncType, Duration duration, bool success) async {
    await _analytics.logEvent(
      'sync_performance',
      parameters: {
        'sync_type': syncType,
        'duration_ms': duration.inMilliseconds,
        'success': success,
        'performance_category': _categorizePerformance(duration.inMilliseconds),
      },
    );
  }

  /// Track network status changes
  Future<void> trackNetworkStatusChange(String from, String to, Duration disconnectedDuration) async {
    await _analytics.logEvent(
      'network_status_change',
      parameters: {
        'from_status': from,
        'to_status': to,
        'disconnected_duration_ms': disconnectedDuration.inMilliseconds,
      },
    );
  }

  /// User Profile Monitoring

  /// Track profile operations
  Future<void> trackProfileOperation(ProfileOperationEvent event, Map<String, dynamic> parameters) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'profile_operation_${event.name}',
      parameters: {
        ...parameters,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Performance Monitoring

  /// Start performance tracking
  void startPerformanceTracking(String operationName) {
    _performanceStartTimes[operationName] = DateTime.now();
  }

  /// End performance tracking and log results
  Future<void> endPerformanceTracking(String operationName, {Map<String, dynamic>? additionalParameters}) async {
    final startTime = _performanceStartTimes.remove(operationName);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    
    await _analytics.logEvent(
      'performance_tracking',
      parameters: {
        'operation': operationName,
        'duration_ms': duration.inMilliseconds,
        'performance_category': _categorizePerformance(duration.inMilliseconds),
        ...additionalParameters ?? {},
      },
    );
    if (duration.inMilliseconds > 2000) {
      await _crashlytics.log('Slow operation detected: $operationName (${duration.inMilliseconds}ms)');
    }
  }

  /// Error Monitoring

  /// Track custom errors
  Future<void> trackError(String errorType, String errorMessage, {StackTrace? stackTrace, Map<String, dynamic>? parameters}) async {
    if (!_isInitialized) return;
    await _crashlytics.recordError(
      exception: Exception('$errorType: $errorMessage'),
      stackTrace: stackTrace ?? StackTrace.current,
      reason: errorType,
      fatal: false,
    );
    await _analytics.logEvent(
      'custom_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
        ...parameters ?? {},
      },
    );
    _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;
  }

  /// Track sync errors
  Future<void> trackSyncError(String syncType, String errorMessage, {Map<String, dynamic>? parameters}) async {
    await trackError(
      'sync_error',
      '$syncType: $errorMessage',
      parameters: {
        'sync_type': syncType,
        ...parameters ?? {},
      },
    );
  }

  /// Track premium validation errors
  Future<void> trackPremiumValidationError(String validationType, String errorMessage) async {
    await trackError(
      'premium_validation_error',
      '$validationType: $errorMessage',
      parameters: {
        'validation_type': validationType,
      },
    );
  }

  /// Session Monitoring

  /// Track session information
  Future<void> trackSessionInfo({
    required String sessionId,
    required Duration sessionDuration,
    required Map<String, dynamic> sessionData,
  }) async {
    if (!_isInitialized) return;

    await _analytics.logEvent(
      'session_info',
      parameters: {
        'session_id': sessionId,
        'session_duration_ms': sessionDuration.inMilliseconds,
        'error_count': _errorCounts.values.fold(0, (acc, value) => acc + value),
        'most_common_error': _getMostCommonError(),
        ...sessionData,
      },
    );
  }

  /// Utility Methods

  /// Get session ID
  String _getSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Categorize performance based on duration
  String _categorizePerformance(int milliseconds) {
    if (milliseconds < 500) return 'excellent';
    if (milliseconds < 1000) return 'good';
    if (milliseconds < 2000) return 'fair';
    return 'poor';
  }

  /// Get most common error type
  String _getMostCommonError() {
    if (_errorCounts.isEmpty) return 'none';
    
    return _errorCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Health Check

  /// Perform system health check
  Future<Map<String, dynamic>> performHealthCheck() async {
    return {
      'monitoring_initialized': _isInitialized,
      'error_count': _errorCounts.values.fold(0, (acc, value) => acc + value),
      'performance_tracking_active': _performanceStartTimes.isNotEmpty,
      'most_common_error': _getMostCommonError(),
      'memory_usage': _getMemoryUsage(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get memory usage information
  Map<String, dynamic> _getMemoryUsage() {
    return {
      'rss': 'unknown', // Resident Set Size
      'heap_used': 'unknown',
      'heap_total': 'unknown',
    };
  }

  /// Dispose resources
  void dispose() {
    _performanceStartTimes.clear();
    _errorCounts.clear();
    _isInitialized = false;
  }
}

/// Event Enums for Type Safety

enum DeviceManagementEvent {
  deviceListed,
  deviceRevoked,
  deviceAdded,
  limitExceeded,
  managementDialogOpened,
}

enum SubscriptionFlowEvent {
  flowStarted,
  planSelected,
  purchaseInitiated,
  purchaseCompleted,
  purchaseFailed,
  flowAbandoned,
}

enum SettingsSyncEvent {
  syncStarted,
  syncCompleted,
  syncFailed,
  conflictDetected,
  conflictResolved,
}

enum ProfileOperationEvent {
  profileViewed,
  profileEdited,
  profileSaved,
  avatarChanged,
  accountManagementAccessed,
}

/// Production Monitoring Extensions

extension MonitoringExtension on ProductionMonitoringService {
  /// Quick performance tracking wrapper
  Future<T> trackPerformance<T>(String operationName, Future<T> Function() operation) async {
    startPerformanceTracking(operationName);
    
    try {
      final result = await operation();
      await endPerformanceTracking(operationName, additionalParameters: {'success': true});
      return result;
    } catch (e, stack) {
      await endPerformanceTracking(operationName, additionalParameters: {'success': false});
      await trackError('operation_error', e.toString(), stackTrace: stack);
      rethrow;
    }
  }

  /// Track feature usage with automatic performance monitoring
  Future<void> trackFeatureUsage(String featureName, Future<void> Function() featureOperation) async {
    await trackPerformance('feature_$featureName', () async {
      await trackPremiumFeatureUsage(featureName, true);
      await featureOperation();
    });
  }
}
