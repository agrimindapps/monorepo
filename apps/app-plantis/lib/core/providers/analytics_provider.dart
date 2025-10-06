import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// Enhanced Analytics Provider for App-Plantis
/// Now uses the Enhanced Analytics Service from core package
/// Maintains backward compatibility while leveraging enhanced features
class AnalyticsProvider {
  final EnhancedAnalyticsService _enhancedService;

  AnalyticsProvider({
    required IAnalyticsRepository analyticsRepository,
    required ICrashlyticsRepository crashlyticsRepository,
  }) : _enhancedService = EnhancedAnalyticsService(
         analytics: analyticsRepository,
         crashlytics: crashlyticsRepository,
         config: AnalyticsConfig.forApp(
           appId: AppConstants.appId,
           version: AppConstants.defaultVersion, // Note: Version should be loaded from package_info in production
           enableAnalytics: EnvironmentConfig.enableAnalytics,
           enableLogging: kDebugMode || EnvironmentConfig.enableLogging,
         ),
       );

  /// Direct access to enhanced service for advanced features
  EnhancedAnalyticsService get enhancedService => _enhancedService;

  /// Logs screen view with enhanced error handling
  Future<void> logScreenView(String screenName) async {
    await _enhancedService.setCurrentScreen(screenName);
    await _enhancedService.logEvent('screen_view', {'screen_name': screenName});
  }

  /// Logs custom event with enhanced error handling
  Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    await _enhancedService.logEvent(eventName, parameters);
  }

  /// Sets user ID in both analytics and crashlytics
  Future<void> setUserId(String userId) async {
    await _enhancedService.setUser(userId: userId);
  }

  /// Sets user properties
  Future<void> setUserProperty(String name, String value) async {
    await _enhancedService.setUser(
      userId: 'current_user', // Will be updated by actual user ID
      properties: {name: value},
    );
  }

  /// Records error with enhanced reporting
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await _enhancedService.recordError(
      error,
      stackTrace,
      reason: reason,
      logAsAnalyticsEvent: true, // Log critical errors as analytics events
    );
  }

  Future<void> logLogin(String method) async {
    await _enhancedService.logAuthEvent(
      'login',
      parameters: {'method': method},
    );
  }

  Future<void> logSignUp(String method) async {
    await _enhancedService.logAuthEvent(
      'signup',
      parameters: {'method': method},
    );
  }

  Future<void> logLogout() async {
    await _enhancedService.logAuthEvent('logout');
  }

  Future<void> logAppOpen() async {
    await _enhancedService.logEvent('app_open', {AppConstants.analyticsAppParam: AppConstants.appId});
  }

  Future<void> logAppBackground() async {
    await _enhancedService.logEvent('app_background', {AppConstants.analyticsAppParam: AppConstants.appId});
  }

  Future<void> logFeatureUsed(String featureName) async {
    await _enhancedService.logEvent('feature_used', {'feature': featureName});
  }

  Future<void> logPlantCreated({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.plantCreated,
      additionalParameters: additionalData,
    );
  }

  Future<void> logPlantDeleted({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.plantDeleted,
      additionalParameters: additionalData,
    );
  }

  Future<void> logPlantUpdated({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.plantUpdated,
      additionalParameters: additionalData,
    );
  }

  Future<void> logTaskCompleted(
    String taskType, {
    Map<String, dynamic>? additionalData,
  }) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.taskCompleted,
      additionalParameters: {
        'task_type': taskType,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  Future<void> logTaskCreated({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.taskCreated,
      additionalParameters: additionalData,
    );
  }

  Future<void> logSpaceCreated({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.spaceCreated,
      additionalParameters: additionalData,
    );
  }

  Future<void> logSpaceDeleted({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.spaceDeleted,
      additionalParameters: additionalData,
    );
  }

  Future<void> logPremiumFeatureAttempted(
    String featureName, {
    Map<String, dynamic>? additionalData,
  }) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.premiumFeatureAttempted,
      additionalParameters: {
        'feature': featureName,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  Future<void> logCareLogAdded({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.careLogAdded,
      additionalParameters: additionalData,
    );
  }

  Future<void> logPlantPhotoAdded({
    Map<String, dynamic>? additionalData,
  }) async {
    await _enhancedService.logAppSpecificEvent(
      PlantisEvent.plantPhotoAdded,
      additionalParameters: additionalData,
    );
  }

  Future<void> logSubscriptionPurchased(String productId, double price) async {
    await _enhancedService.logPurchaseEvent(
      productId: productId,
      value: price,
      currency: 'USD',
      additionalParameters: {'subscription_type': 'premium'},
    );
  }

  Future<void> logTrialStarted() async {
    await _enhancedService.logEvent('trial_started', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'trial_type': 'premium',
    });
  }

  Future<void> logTrialEnded(String reason) async {
    await _enhancedService.logEvent('trial_ended', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'reason': reason,
    });
  }

  Future<void> logSearch(String query, int resultCount) async {
    await _enhancedService.logEvent('search', {
      'query': query,
      'result_count': resultCount,
      'category': 'plants',
    });
  }

  Future<void> logContentViewed(String contentType, String contentId) async {
    await _enhancedService.logEvent('content_viewed', {
      'content_type': contentType,
      'content_id': contentId,
    });
  }

  Future<void> logUserEngagement(String action, int durationSeconds) async {
    await _enhancedService.logEvent('user_engagement', {
      'action': action,
      'duration_seconds': durationSeconds,
      'engagement_time_msec': durationSeconds * 1000,
    });
  }

  Future<void> logSessionStart() async {
    await _enhancedService.logEvent('session_start', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logSessionEnd(int durationSeconds) async {
    await _enhancedService.logEvent('session_end', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'duration_seconds': durationSeconds,
    });
  }

  Future<void> testCrash() async {
    await _enhancedService.testCrash();
  }

  Future<void> testAnalyticsEvent() async {
    await _enhancedService.testAnalyticsEvent();
  }

  /// Logs a development event for debugging purposes
  Future<void> logDevelopmentEvent(
    String event,
    Map<String, dynamic>? data,
  ) async {
    if (kDebugMode) {
      await _enhancedService.logEvent('dev_$event', {
        'is_development': true,
        if (data != null) ...data,
      });
    }
  }

  /// Whether analytics is enabled in the current environment
  bool get isAnalyticsEnabled => EnvironmentConfig.enableAnalytics;

  /// Whether debug mode is enabled
  bool get isDebugMode => kDebugMode;
}
