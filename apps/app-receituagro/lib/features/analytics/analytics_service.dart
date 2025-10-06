import 'package:core/core.dart';

import '../../core/enums/analytics_user_type.dart';

export '../../core/enums/analytics_user_type.dart' show AnalyticsUserType;
// Export types
export 'enhanced_analytics_notifier.dart' show EnhancedAnalyticsNotifier;

/// Analytics events specific to ReceitaAgro
enum ReceitaAgroAnalyticsEvent {
  // App lifecycle
  appOpened('app_opened'),
  appClosed('app_closed'),

  // User journey
  onboardingStarted('onboarding_started'),
  onboardingCompleted('onboarding_completed'),
  onboardingSkipped('onboarding_skipped'),

  // Content interaction
  plagueViewed('plague_viewed'),
  plagueSearched('plague_searched'),
  cultureViewed('culture_viewed'),
  diagnosticStarted('diagnostic_started'),
  diagnosticCompleted('diagnostic_completed'),

  // Premium features
  premiumFeatureAttempted('premium_feature_attempted'),
  subscriptionViewed('subscription_viewed'),
  subscriptionPurchased('subscription_purchased'),
  subscriptionCancelled('subscription_cancelled'),

  // Sharing and export
  contentShared('content_shared'),
  reportExported('report_exported'),

  // Performance and errors
  performanceIssue('performance_issue'),
  errorOccurred('error_occurred'),

  // Feature usage
  featureUsed('feature_used'),
  settingChanged('setting_changed'),

  // Device management
  deviceRegistered('device_registered'),
  deviceRemoved('device_removed');

  const ReceitaAgroAnalyticsEvent(this.eventName);
  final String eventName;
}

/// ReceitaAgroAnalyticsService - Service wrapper for Core Package analytics
/// This class provides a simplified interface for analytics operations
/// Uses Core Package services directly instead of Riverpod notifier
///
/// This approach is used for:
/// 1. GetIt dependency injection compatibility
/// 2. Service-layer analytics operations (not UI state management)
/// 3. Backward compatibility with existing analytics code
class ReceitaAgroAnalyticsService {
  final IAnalyticsRepository _analyticsRepository;
  final ICrashlyticsRepository _crashlyticsRepository;

  ReceitaAgroAnalyticsService({
    required IAnalyticsRepository analyticsRepository,
    required ICrashlyticsRepository crashlyticsRepository,
  }) : _analyticsRepository = analyticsRepository,
       _crashlyticsRepository = crashlyticsRepository;

  // Core analytics operations
  Future<void> initialize() async {
    // Analytics repository doesn't have initialize method - it's auto-initialized
  }

  Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    await _analyticsRepository.logEvent(eventName, parameters: parameters);
  }

  Future<void> setUserId(String userId) async {
    await _analyticsRepository.setUserId(userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analyticsRepository.setUserProperties(properties: {name: value});
  }

  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    await _crashlyticsRepository.recordError(
      exception: error,
      stackTrace: stackTrace ?? StackTrace.empty,
      reason: reason,
    );
  }

  Future<void> logLogin(String method) async {
    await _analyticsRepository.logLogin(method: method);
  }

  Future<void> logSignUp(String method) async {
    await _analyticsRepository.logSignUp(method: method);
  }

  Future<void> logLogout() async {
    await _analyticsRepository.logLogout();
  }

  Future<void> logAppOpen() async {
    await logEvent('app_open', null);
  }

  Future<void> logSubscriptionEvent(
    String eventType,
    String? productId, {
    Map<String, dynamic>? additionalData,
  }) async {
    final params = <String, dynamic>{
      'event_type': eventType,
      if (productId != null) 'product_id': productId,
      ...?additionalData,
    };
    await logEvent('subscription_event', params);
  }

  Future<void> logPremiumAttempt(String featureName) async {
    await logEvent('premium_attempt', {'feature': featureName});
  }

  // Legacy compatibility methods
  void trackLogin(String method, {Map<String, dynamic>? metadata}) {
    logLogin(method);
    if (metadata != null) logEvent('login_metadata', metadata);
  }

  void trackSignup(String method, {required bool success}) {
    if (success) {
      logSignUp(method);
    } else {
      logEvent('signup_failed', {'method': method});
    }
  }

  void trackLogout(String reason) {
    logEvent('logout', {'reason': reason});
  }

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    logEvent(eventName, parameters);
  }

  void trackError(
    String context,
    String error, {
    bool fatal = false,
    Map<String, dynamic>? metadata,
  }) {
    recordError(
      error,
      StackTrace.current,
      reason: '$context${fatal ? ' (FATAL)' : ''}',
    );
  }

  Future<void> setUserProperties({
    required AnalyticsUserType userType,
    required bool isPremium,
    required int deviceCount,
  }) async {
    await setUserProperty('user_type', userType.toString().split('.').last);
    await setUserProperty('is_premium', isPremium.toString());
    await setUserProperty('device_count', deviceCount.toString());
  }

  Future<void> clearUser() async {
    await setUserId('');
  }

  void trackAuthFunnelStep(String step) {
    logEvent('auth_funnel_step', {'step': step});
  }

  void trackDeviceAdded(String platform) {
    logEvent('device_added', {'platform': platform});
  }

  void trackDeviceLimitReached() {
    logEvent('device_limit_reached', null);
  }

  void trackMigrationStart() {
    logEvent('migration_start', null);
  }

  void trackMigrationComplete(int migratedCount, int duration) {
    logEvent('migration_complete', {
      'migrated_count': migratedCount,
      'duration_ms': duration,
    });
  }
}

/// Secondary alias for backward compatibility
typedef AnalyticsService = ReceitaAgroAnalyticsService;
