import 'package:flutter/foundation.dart';

import '../../domain/repositories/i_analytics_repository.dart';
import '../../domain/repositories/i_crashlytics_repository.dart';
import '../../shared/config/environment_config.dart';

/// Enhanced Analytics Service with environment awareness, error handling,
/// and app-specific event support. Built on top of core analytics services.
///
/// This service provides:
/// - Environment-aware analytics (dev/prod behavior)
/// - Unified analytics + crashlytics interface
/// - Enhanced error handling with recovery
/// - App-specific event system
/// - Configurable behavior per app
class EnhancedAnalyticsService {
  final IAnalyticsRepository _analytics;
  final ICrashlyticsRepository _crashlytics;
  final AnalyticsConfig _config;

  EnhancedAnalyticsService({
    required IAnalyticsRepository analytics,
    required ICrashlyticsRepository crashlytics,
    AnalyticsConfig? config,
  }) : _analytics = analytics,
       _crashlytics = crashlytics,
       _config = config ?? AnalyticsConfig.defaultConfig();

  /// Logs an event with enhanced error handling and environment awareness
  Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters, {
    bool enableErrorRecovery = true,
  }) async {
    if (!_config.isAnalyticsEnabled) {
      if (_config.enableDebugLogging) {
        debugPrint('📊 [${_config.environment}] Analytics: $eventName');
        if (parameters != null && parameters.isNotEmpty) {
          debugPrint('   Parameters: $parameters');
        }
      }
      return;
    }

    try {
      final result = await _analytics.logEvent(eventName, parameters: parameters);
      result.fold(
        (failure) => throw Exception('Failed to log event: $failure'),
        (_) {},
      );

      if (_config.enableDebugLogging) {
        debugPrint('📊 Analytics: Event logged - $eventName');
      }
    } catch (e, stackTrace) {
      if (enableErrorRecovery) {
        await _recordAnalyticsError(e, stackTrace, 'Failed to log event: $eventName');
      } else {
        rethrow;
      }
    }
  }

  /// Logs app-specific events with standardized parameters
  Future<void> logAppSpecificEvent(
    AppEvent event, {
    Map<String, dynamic>? additionalParameters,
  }) async {
    final parameters = <String, dynamic>{
      ...event.defaultParameters,
      if (additionalParameters != null) ...additionalParameters,
      'app_id': _config.appIdentifier,
      'version': _config.appVersion,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await logEvent(event.eventName, parameters);
  }

  /// Enhanced user management - sets user in both analytics and crashlytics
  Future<void> setUser({
    required String userId,
    Map<String, String>? properties,
  }) async {
    try {
      final userIdResult = await _analytics.setUserId(userId);
      userIdResult.fold(
        (failure) => throw Exception('Failed to set user ID: $failure'),
        (_) {},
      );

      await _crashlytics.setUserId(userId);

      if (properties != null && properties.isNotEmpty) {
        final propertiesResult = await _analytics.setUserProperties(properties: properties);
        propertiesResult.fold(
          (failure) => throw Exception('Failed to set user properties: $failure'),
          (_) {},
        );
      }

      if (_config.enableDebugLogging) {
        debugPrint('👤 User context set: $userId');
      }
    } catch (e, stackTrace) {
      await _recordAnalyticsError(e, stackTrace, 'Failed to set user: $userId');
    }
  }

  /// Enhanced error reporting with optional analytics event
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? customKeys,
    bool logAsAnalyticsEvent = false,
  }) async {
    if (!_config.isAnalyticsEnabled) {
      if (_config.enableDebugLogging) {
        debugPrint('🔥 [${_config.environment}] Error: ${error.toString()}');
        if (reason != null) {
          debugPrint('   Reason: $reason');
        }
      }
      return;
    }

    try {
      // Set custom keys for better context
      if (customKeys != null && customKeys.isNotEmpty) {
        await _crashlytics.setCustomKeys(keys: customKeys.cast<String, String>());
      }

      // Record in Crashlytics
      await _crashlytics.recordError(
        exception: error,
        stackTrace: stackTrace ?? StackTrace.current,
        reason: reason,
      );

      // Optionally log as analytics event for business metrics
      if (logAsAnalyticsEvent) {
        final errorResult = await _analytics.logError(
          error: error.toString(),
          stackTrace: stackTrace?.toString(),
          additionalInfo: customKeys,
        );
        errorResult.fold(
          (failure) => throw Exception('Failed to log error event: $failure'),
          (_) {},
        );
      }

      if (_config.enableDebugLogging) {
        debugPrint('🔥 Error recorded: ${error.toString()}');
      }
    } catch (e, stackTrace) {
      // Last resort - at least log to debug
      if (_config.enableDebugLogging) {
        debugPrint('❌ Failed to record error: $e');
      }
    }
  }

  /// Sets current screen for analytics
  Future<void> setCurrentScreen(String screenName) async {
    if (!_config.isAnalyticsEnabled) {
      if (_config.enableDebugLogging) {
        debugPrint('📱 [${_config.environment}] Screen: $screenName');
      }
      return;
    }

    try {
      final result = await _analytics.setCurrentScreen(screenName: screenName);
      result.fold(
        (failure) => throw Exception('Failed to set current screen: $failure'),
        (_) {},
      );

      if (_config.enableDebugLogging) {
        debugPrint('📱 Current screen set: $screenName');
      }
    } catch (e, stackTrace) {
      await _recordAnalyticsError(e, stackTrace, 'Failed to set screen: $screenName');
    }
  }

  /// Logs authentication events
  Future<void> logAuthEvent(String eventType, {Map<String, dynamic>? parameters}) async {
    final method = parameters?['method'] as String? ?? 'enhanced_analytics';

    try {
      switch (eventType.toLowerCase()) {
        case 'login':
          final result = await _analytics.logLogin(method: method);
          result.fold(
            (failure) => throw Exception('Failed to log login: $failure'),
            (_) {},
          );
          break;
        case 'signup':
          final result = await _analytics.logSignUp(method: method);
          result.fold(
            (failure) => throw Exception('Failed to log signup: $failure'),
            (_) {},
          );
          break;
        case 'logout':
          final result = await _analytics.logLogout();
          result.fold(
            (failure) => throw Exception('Failed to log logout: $failure'),
            (_) {},
          );
          break;
        default:
          final authParameters = <String, dynamic>{
            'auth_method': method,
            if (parameters != null) ...parameters,
          };
          await logEvent('auth_$eventType', authParameters);
      }
    } catch (e, stackTrace) {
      await _recordAnalyticsError(e, stackTrace, 'Failed to log auth event: $eventType');
    }
  }

  /// Logs purchase events
  Future<void> logPurchaseEvent({
    required String productId,
    required double value,
    required String currency,
    Map<String, dynamic>? additionalParameters,
  }) async {
    final purchaseParameters = <String, dynamic>{
      'product_id': productId,
      'value': value,
      'currency': currency,
      'app_id': _config.appIdentifier,
      if (additionalParameters != null) ...additionalParameters,
    };

    try {
      final result = await _analytics.logPurchase(
        productId: productId,
        value: value,
        currency: currency,
      );
      result.fold(
        (failure) => throw Exception('Failed to log purchase: $failure'),
        (_) {},
      );
    } catch (e, stackTrace) {
      await _recordAnalyticsError(e, stackTrace, 'Failed to log purchase: $productId');
    }
  }

  /// Development and testing utilities
  Future<void> testCrash() async {
    if (kDebugMode && _config.enableDebugLogging) {
      throw Exception('Test crash from Enhanced Analytics Service - App: ${_config.appIdentifier}');
    }
  }

  Future<void> testAnalyticsEvent() async {
    await logEvent('test_enhanced_analytics', {
      'app_id': _config.appIdentifier,
      'environment': _config.environment,
      'test_timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Records analytics-specific errors in crashlytics
  Future<void> _recordAnalyticsError(
    dynamic error,
    StackTrace stackTrace,
    String context,
  ) async {
    try {
      await _crashlytics.recordError(
        exception: error,
        stackTrace: stackTrace,
        reason: 'Enhanced Analytics Error: $context (App: ${_config.appIdentifier})',
      );
    } catch (e) {
      // Final fallback - just debug print
      if (_config.enableDebugLogging) {
        debugPrint('❌ Critical error recording analytics error: $e');
      }
    }
  }
}

/// Configuration for Enhanced Analytics Service
class AnalyticsConfig {
  final String appIdentifier;
  final String appVersion;
  final String environment;
  final bool isAnalyticsEnabled;
  final bool enableDebugLogging;
  final bool enableErrorRecovery;

  const AnalyticsConfig({
    required this.appIdentifier,
    required this.appVersion,
    required this.environment,
    required this.isAnalyticsEnabled,
    required this.enableDebugLogging,
    this.enableErrorRecovery = true,
  });

  /// Default configuration for development/testing
  const AnalyticsConfig.defaultConfig() : this(
    appIdentifier: 'unknown',
    appVersion: '1.0.0',
    environment: 'development',
    isAnalyticsEnabled: false,
    enableDebugLogging: true,
  );

  /// App-specific configuration using environment config
  AnalyticsConfig.forApp({
    required String appId,
    required String version,
    String? environment,
    bool? enableAnalytics,
    bool? enableLogging,
  }) : this(
    appIdentifier: appId,
    appVersion: version,
    environment: environment ?? EnvironmentConfig.environmentName,
    isAnalyticsEnabled: enableAnalytics ?? EnvironmentConfig.enableAnalytics,
    enableDebugLogging: enableLogging ?? (kDebugMode || EnvironmentConfig.enableLogging),
  );

  @override
  String toString() => 'AnalyticsConfig(app: $appIdentifier, env: $environment, enabled: $isAnalyticsEnabled)';
}

/// Base class for app-specific events with type safety
abstract class AppEvent {
  String get eventName;
  Map<String, dynamic> get defaultParameters;

  @override
  String toString() => 'AppEvent($eventName)';
}

/// Plantis-specific events
abstract class PlantisEvent extends AppEvent {
  static final plantCreated = _PlantisEvent('plant_created', {'category': 'plants', 'action': 'create'});
  static final plantDeleted = _PlantisEvent('plant_deleted', {'category': 'plants', 'action': 'delete'});
  static final plantUpdated = _PlantisEvent('plant_updated', {'category': 'plants', 'action': 'update'});
  static final taskCompleted = _PlantisEvent('task_completed', {'category': 'tasks', 'action': 'complete'});
  static final taskCreated = _PlantisEvent('task_created', {'category': 'tasks', 'action': 'create'});
  static final spaceCreated = _PlantisEvent('space_created', {'category': 'spaces', 'action': 'create'});
  static final spaceDeleted = _PlantisEvent('space_deleted', {'category': 'spaces', 'action': 'delete'});
  static final premiumFeatureAttempted = _PlantisEvent('premium_feature_attempted', {'category': 'premium', 'action': 'attempt'});
  static final careLogAdded = _PlantisEvent('care_log_added', {'category': 'care', 'action': 'log'});
  static final plantPhotoAdded = _PlantisEvent('plant_photo_added', {'category': 'photos', 'action': 'add'});

  // Private constructor
  PlantisEvent._();
}

class _PlantisEvent extends PlantisEvent {
  final String _eventName;
  final Map<String, dynamic> _defaultParameters;

  _PlantisEvent(this._eventName, this._defaultParameters) : super._();

  @override
  String get eventName => _eventName;

  @override
  Map<String, dynamic> get defaultParameters => _defaultParameters;
}

/// Gasometer-specific events
abstract class GasometerEvent extends AppEvent {
  static final vehicleCreated = _GasometerEvent('vehicle_created', {'category': 'vehicles', 'action': 'create'});
  static final fuelRecorded = _GasometerEvent('fuel_recorded', {'category': 'fuel', 'action': 'record'});
  static final expenseAdded = _GasometerEvent('expense_added', {'category': 'expenses', 'action': 'add'});
  static final maintenanceScheduled = _GasometerEvent('maintenance_scheduled', {'category': 'maintenance', 'action': 'schedule'});
  static final reportGenerated = _GasometerEvent('report_generated', {'category': 'reports', 'action': 'generate'});

  GasometerEvent._();
}

class _GasometerEvent extends GasometerEvent {
  final String _eventName;
  final Map<String, dynamic> _defaultParameters;

  _GasometerEvent(this._eventName, this._defaultParameters) : super._();

  @override
  String get eventName => _eventName;

  @override
  Map<String, dynamic> get defaultParameters => _defaultParameters;
}

/// ReceitAGro-specific events
abstract class ReceitAgroEvent extends AppEvent {
  static final cropAnalyzed = _ReceitAgroEvent('crop_analyzed', {'category': 'analysis', 'action': 'analyze'});
  static final reportViewed = _ReceitAgroEvent('report_viewed', {'category': 'reports', 'action': 'view'});
  static final diagnosisRequested = _ReceitAgroEvent('diagnosis_requested', {'category': 'diagnosis', 'action': 'request'});
  static final premiumAnalysisUsed = _ReceitAgroEvent('premium_analysis_used', {'category': 'premium', 'action': 'use'});

  ReceitAgroEvent._();
}

class _ReceitAgroEvent extends ReceitAgroEvent {
  final String _eventName;
  final Map<String, dynamic> _defaultParameters;

  _ReceitAgroEvent(this._eventName, this._defaultParameters) : super._();

  @override
  String get eventName => _eventName;

  @override
  Map<String, dynamic> get defaultParameters => _defaultParameters;
}

