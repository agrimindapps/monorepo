import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/enums/analytics_user_type.dart';

part 'enhanced_analytics_notifier.g.dart';

/// Enhanced Analytics state
class EnhancedAnalyticsState {
  final bool isInitialized;
  final String? currentUserId;
  final Map<String, String> userProperties;

  const EnhancedAnalyticsState({
    required this.isInitialized,
    this.currentUserId,
    required this.userProperties,
  });

  factory EnhancedAnalyticsState.initial() {
    return const EnhancedAnalyticsState(
      isInitialized: false,
      currentUserId: null,
      userProperties: {},
    );
  }

  EnhancedAnalyticsState copyWith({
    bool? isInitialized,
    String? currentUserId,
    Map<String, String>? userProperties,
  }) {
    return EnhancedAnalyticsState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentUserId: currentUserId ?? this.currentUserId,
      userProperties: userProperties ?? this.userProperties,
    );
  }
}

/// Enhanced Analytics Notifier for App-ReceitAgro (Presentation Layer)
/// Uses the Enhanced Analytics Service from core package
/// Maintains backward compatibility while leveraging enhanced features
@riverpod
class EnhancedAnalyticsNotifier extends _$EnhancedAnalyticsNotifier {
  late final EnhancedAnalyticsService _enhancedService;

  @override
  Future<EnhancedAnalyticsState> build() async {
    // Get dependencies from DI
    final analyticsRepository = di.sl<IAnalyticsRepository>();
    final crashlyticsRepository = di.sl<ICrashlyticsRepository>();

    _enhancedService = EnhancedAnalyticsService(
      analytics: analyticsRepository,
      crashlytics: crashlyticsRepository,
      config: AnalyticsConfig.forApp(
        appId: 'receituagro',
        version: '1.0.0', // TODO: Get from package_info
        enableAnalytics: EnvironmentConfig.enableAnalytics,
        enableLogging: kDebugMode || EnvironmentConfig.enableLogging,
      ),
    );

    return EnhancedAnalyticsState.initial();
  }

  /// Direct access to enhanced service for advanced features
  EnhancedAnalyticsService get enhancedService => _enhancedService;

  // ==========================================================================
  // INITIALIZATION AND SETUP
  // ==========================================================================

  /// Initialize method for backward compatibility
  Future<void> initialize() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Enhanced service is ready to use immediately
    if (kDebugMode) {
      debugPrint('✅ ReceitaAgro Enhanced Analytics Provider initialized');
    }

    state = AsyncValue.data(currentState.copyWith(isInitialized: true));
  }

  // ==========================================================================
  // SCREEN AND EVENT TRACKING
  // ==========================================================================

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

  // ==========================================================================
  // USER MANAGEMENT
  // ==========================================================================

  /// Sets user ID in both analytics and crashlytics
  Future<void> setUserId(String userId) async {
    final currentState = state.value;
    if (currentState == null) return;

    await _enhancedService.setUser(userId: userId);
    state = AsyncValue.data(currentState.copyWith(currentUserId: userId));
  }

  /// Sets user property
  Future<void> setUserProperty(String name, String value) async {
    final currentState = state.value;
    if (currentState == null) return;

    await _enhancedService.setUser(
      userId: currentState.currentUserId ?? 'current_user',
      properties: {name: value},
    );

    final updatedProperties = Map<String, String>.from(currentState.userProperties);
    updatedProperties[name] = value;
    state = AsyncValue.data(currentState.copyWith(userProperties: updatedProperties));
  }

  /// Sets user properties
  Future<void> setUserProperties({
    required AnalyticsUserType userType,
    required bool isPremium,
    required int deviceCount,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    await _enhancedService.setUser(
      userId: currentState.currentUserId ?? 'current_user',
      properties: {
        'user_type': userType.toString(),
        'is_premium': isPremium.toString(),
        'device_count': deviceCount.toString(),
      },
    );

    final updatedProperties = Map<String, String>.from(currentState.userProperties);
    updatedProperties['user_type'] = userType.toString();
    updatedProperties['is_premium'] = isPremium.toString();
    updatedProperties['device_count'] = deviceCount.toString();
    state = AsyncValue.data(currentState.copyWith(userProperties: updatedProperties));
  }

  /// Clear user
  Future<void> clearUser() async {
    final currentState = state.value;
    if (currentState == null) return;

    await _enhancedService.setUser(userId: 'anonymous');
    state = AsyncValue.data(
      currentState.copyWith(
        currentUserId: null,
        userProperties: {},
      ),
    );
  }

  // ==========================================================================
  // ERROR TRACKING
  // ==========================================================================

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

  // ==========================================================================
  // AUTH EVENTS
  // ==========================================================================

  Future<void> logLogin(String method) async {
    await _enhancedService.logAuthEvent('login', parameters: {'method': method});
  }

  Future<void> logSignUp(String method) async {
    await _enhancedService.logAuthEvent('signup', parameters: {'method': method});
  }

  Future<void> logLogout() async {
    await _enhancedService.logAuthEvent('logout');
  }

  // ==========================================================================
  // APP LIFECYCLE EVENTS
  // ==========================================================================

  Future<void> logAppOpen() async {
    await _enhancedService.logEvent('app_open', {'app': 'receituagro'});
  }

  Future<void> logAppBackground() async {
    await _enhancedService.logEvent('app_background', {'app': 'receituagro'});
  }

  Future<void> logFeatureUsed(String featureName) async {
    await _enhancedService.logEvent('feature_used', {'feature': featureName});
  }

  // ==========================================================================
  // RECEITUAGRO-SPECIFIC EVENTS
  // ==========================================================================

  Future<void> logCropAnalyzed({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.cropAnalyzed,
      additionalParameters: additionalData,
    );
  }

  Future<void> logReportViewed({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.reportViewed,
      additionalParameters: additionalData,
    );
  }

  Future<void> logDiagnosisRequested({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.diagnosisRequested,
      additionalParameters: additionalData,
    );
  }

  Future<void> logPremiumAnalysisUsed({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.premiumAnalysisUsed,
      additionalParameters: additionalData,
    );
  }

  Future<void> logDiseaseIdentified({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.diseaseIdentified,
      additionalParameters: additionalData,
    );
  }

  Future<void> logPestIdentified({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.pestIdentified,
      additionalParameters: additionalData,
    );
  }

  Future<void> logDeficiencyIdentified({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.deficiencyIdentified,
      additionalParameters: additionalData,
    );
  }

  Future<void> logTreatmentViewed({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.treatmentViewed,
      additionalParameters: additionalData,
    );
  }

  Future<void> logSymptomSearched(String query, {Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.symptomSearched,
      additionalParameters: {
        'query': query,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  Future<void> logFavoriteAdded({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.favoriteAdded,
      additionalParameters: additionalData,
    );
  }

  Future<void> logFavoriteRemoved({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.favoriteRemoved,
      additionalParameters: additionalData,
    );
  }

  Future<void> logCommentAdded({Map<String, dynamic>? additionalData}) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.commentAdded,
      additionalParameters: additionalData,
    );
  }

  Future<void> logShareContent(String contentType, String contentId) async {
    await _enhancedService.logAppSpecificEvent(
      ReceitAgroEvent.shareContent,
      additionalParameters: {
        'content_type': contentType,
        'content_id': contentId,
      },
    );
  }

  // ==========================================================================
  // PREMIUM EVENTS
  // ==========================================================================

  Future<void> logSubscriptionPurchased(String productId, double price) async {
    await _enhancedService.logPurchaseEvent(
      productId: productId,
      value: price,
      currency: 'USD', // TODO: Get from user locale or RevenueCat
      additionalParameters: {'subscription_type': 'premium'},
    );
  }

  Future<void> logTrialStarted() async {
    await _enhancedService.logEvent('trial_started', {
      'app': 'receituagro',
      'trial_type': 'premium',
    });
  }

  Future<void> logTrialEnded(String reason) async {
    await _enhancedService.logEvent('trial_ended', {
      'app': 'receituagro',
      'reason': reason,
    });
  }

  Future<void> logPremiumFeatureAttempted(String featureName) async {
    await _enhancedService.logEvent('premium_feature_attempted', {
      'feature': featureName,
      'app': 'receituagro',
    });
  }

  Future<void> logSubscriptionEvent(
    String eventType,
    String? productId, {
    Map<String, dynamic>? additionalData,
  }) async {
    switch (eventType) {
      case 'viewed':
        await logEvent('subscription_viewed', {
          if (productId != null) 'product_id': productId,
          ...?additionalData,
        });
        break;
      case 'purchased':
        await logEvent('subscription_purchased', {
          if (productId != null) 'product_id': productId,
          ...?additionalData,
        });
        break;
      case 'cancelled':
        await logEvent('subscription_cancelled', {
          if (productId != null) 'product_id': productId,
          ...?additionalData,
        });
        break;
    }
  }

  Future<void> logPremiumAttempt(String featureName) async {
    await logPremiumFeatureAttempted(featureName);
  }

  // ==========================================================================
  // SEARCH AND DISCOVERY EVENTS
  // ==========================================================================

  Future<void> logSearch(String query, int resultCount) async {
    await _enhancedService.logEvent('search', {
      'query': query,
      'result_count': resultCount,
      'category': 'agricultural_diagnostics',
    });
  }

  Future<void> logContentViewed(String contentType, String contentId) async {
    await _enhancedService.logEvent('content_viewed', {
      'content_type': contentType,
      'content_id': contentId,
    });
  }

  // ==========================================================================
  // ENGAGEMENT EVENTS
  // ==========================================================================

  Future<void> logUserEngagement(String action, int durationSeconds) async {
    await _enhancedService.logEvent('user_engagement', {
      'action': action,
      'duration_seconds': durationSeconds,
      'engagement_time_msec': durationSeconds * 1000,
    });
  }

  Future<void> logSessionStart() async {
    await _enhancedService.logEvent('session_start', {
      'app': 'receituagro',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logSessionEnd(int durationSeconds) async {
    await _enhancedService.logEvent('session_end', {
      'app': 'receituagro',
      'duration_seconds': durationSeconds,
    });
  }

  // ==========================================================================
  // LEGACY COMPATIBILITY METHODS
  // ==========================================================================

  void trackLogin(String method, {Map<String, dynamic>? metadata}) {
    logLogin(method);
  }

  void trackSignup(String method, {required bool success}) {
    logSignUp(method);
  }

  void trackLogout(String reason) {
    logLogout();
  }

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    logEvent(eventName, parameters);
  }

  void trackError(String context, String error, {
    bool fatal = false,
    Map<String, dynamic>? metadata,
  }) {
    recordError(
      Exception('$context: $error'),
      StackTrace.current,
      reason: context,
    );
  }

  void trackAuthFunnelStep(String step) {
    logEvent('auth_funnel', {
      'step': step,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackDeviceAdded(String platform) {
    logEvent('device_added', {
      'platform': platform,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackDeviceLimitReached() {
    logEvent('device_limit_reached', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackMigrationStart() {
    logEvent('migration_started', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackMigrationComplete(int migratedCount, int duration) {
    logEvent('migration_completed', {
      'migrated_count': migratedCount,
      'duration_ms': duration,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================================
  // DEVELOPMENT AND TESTING
  // ==========================================================================

  Future<void> testCrash() async {
    await _enhancedService.testCrash();
  }

  Future<void> testAnalyticsEvent() async {
    await _enhancedService.testAnalyticsEvent();
  }

  Future<void> logDevelopmentEvent(String event, Map<String, dynamic>? data) async {
    if (kDebugMode) {
      await _enhancedService.logEvent('dev_$event', {
        'is_development': true,
        if (data != null) ...data,
      });
    }
  }

  // ==========================================================================
  // CONVENIENCE GETTERS
  // ==========================================================================

  /// Whether analytics is enabled in the current environment
  bool get isAnalyticsEnabled => EnvironmentConfig.enableAnalytics;

  /// Whether debug mode is enabled
  bool get isDebugMode => kDebugMode;
}
