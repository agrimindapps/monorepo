import 'package:core/core.dart' hide getIt;
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

part 'analytics_notifier.g.dart';

/// Enhanced Analytics Provider for App-Plantis (Riverpod version)
/// Wrapper around EnhancedAnalyticsService from core package
/// Maintains backward compatibility while leveraging enhanced features
///
/// Note: This is a stateless wrapper, so we use a simple provider instead of AsyncNotifier
@riverpod
AnalyticsProvider analyticsProviderInstance(Ref ref) {
  final analyticsRepository = ref.watch<IAnalyticsRepository>(analyticsRepositoryProvider);
  final crashlyticsRepository = ref.watch<ICrashlyticsRepository>(crashlyticsRepositoryProvider);

  return AnalyticsProvider(
    analyticsRepository: analyticsRepository,
    crashlyticsRepository: crashlyticsRepository,
  );
}

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
            version: AppConstants.defaultVersion,
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
      userId: 'current_user',
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
      logAsAnalyticsEvent: true,
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
    await _enhancedService.logEvent('app_open', {});
  }

  Future<void> logAppClose() async {
    await _enhancedService.logEvent('app_close', {});
  }

  Future<void> logAppBackground() async {
    await _enhancedService.logEvent('app_background', {});
  }

  Future<void> logAppForeground() async {
    await _enhancedService.logEvent('app_foreground', {});
  }

  Future<void> logPlantAdded(String plantId, String plantName) async {
    await _enhancedService.logEvent('plant_added', {
      'plant_id': plantId,
      'plant_name': plantName,
    });
  }

  Future<void> logPlantUpdated(String plantId) async {
    await _enhancedService.logEvent('plant_updated', {
      'plant_id': plantId,
    });
  }

  Future<void> logPlantDeleted(String plantId) async {
    await _enhancedService.logEvent('plant_deleted', {
      'plant_id': plantId,
    });
  }

  Future<void> logPlantWatered(String plantId) async {
    await _enhancedService.logEvent('plant_watered', {
      'plant_id': plantId,
    });
  }

  Future<void> logPlantFertilized(String plantId) async {
    await _enhancedService.logEvent('plant_fertilized', {
      'plant_id': plantId,
    });
  }

  Future<void> logPremiumPurchase(String productId, double price) async {
    await _enhancedService.logEvent('premium_purchase', {
      'product_id': productId,
      'price': price,
    });
  }

  Future<void> logPremiumFeatureUsed(String featureName) async {
    await _enhancedService.logEvent('premium_feature_used', {
      'feature_name': featureName,
    });
  }

  Future<void> logSyncStarted() async {
    await _enhancedService.logEvent('sync_started', {});
  }

  Future<void> logSyncCompleted(int itemsSynced) async {
    await _enhancedService.logEvent('sync_completed', {
      'items_synced': itemsSynced,
    });
  }

  Future<void> logSyncFailed(String reason) async {
    await _enhancedService.logEvent('sync_failed', {
      'reason': reason,
    });
  }

  Future<void> logNavigationEvent(String from, String to) async {
    await _enhancedService.logEvent('navigation', {
      'from': from,
      'to': to,
    });
  }

  Future<void> logFeatureUsed(String featureName) async {
    await _enhancedService.logEvent('feature_used', {
      'feature_name': featureName,
    });
  }

  Future<void> logButtonPressed(String buttonName) async {
    await _enhancedService.logEvent('button_pressed', {
      'button_name': buttonName,
    });
  }

  Future<void> logPerformanceMetric(String metricName, double value) async {
    await _enhancedService.logEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
    });
  }

  Future<void> logCriticalError(String errorType, String message) async {
    await _enhancedService.recordError(
      Exception(message),
      StackTrace.current,
      reason: errorType,
      logAsAnalyticsEvent: true,
    );
  }
}
@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return GetIt.instance<IAnalyticsRepository>();
}

@riverpod
ICrashlyticsRepository crashlyticsRepository(Ref ref) {
  return GetIt.instance<ICrashlyticsRepository>();
}
