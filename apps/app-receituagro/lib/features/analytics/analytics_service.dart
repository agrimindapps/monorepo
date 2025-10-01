import 'package:core/core.dart';

// Import the enhanced provider
import 'enhanced_analytics_provider.dart';

// Export types from enhanced provider (including AnalyticsUserType and ReceitaAgroEnhancedAnalyticsProvider)
export 'enhanced_analytics_provider.dart' show ReceitaAgroEnhancedAnalyticsProvider, AnalyticsUserType;

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

/// ReceitaAgroAnalyticsService - Wrapper class for backward compatibility
/// This class delegates all calls to ReceitaAgroEnhancedAnalyticsProvider
///
/// This approach is used instead of typedef because:
/// 1. GetIt needs distinct runtime types for registration
/// 2. Typedef creates compile-time aliases but same runtime type
/// 3. This allows both types to be registered in GetIt independently
class ReceitaAgroAnalyticsService {
  final ReceitaAgroEnhancedAnalyticsProvider _provider;

  ReceitaAgroAnalyticsService({
    required IAnalyticsRepository analyticsRepository,
    required ICrashlyticsRepository crashlyticsRepository,
  }) : _provider = ReceitaAgroEnhancedAnalyticsProvider(
          analyticsRepository: analyticsRepository,
          crashlyticsRepository: crashlyticsRepository,
        );

  // Delegate all methods to the provider
  Future<void> initialize() => _provider.initialize();

  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) =>
      _provider.logEvent(eventName, parameters);

  Future<void> setUserId(String userId) => _provider.setUserId(userId);

  Future<void> setUserProperty(String name, String value) =>
      _provider.setUserProperty(name, value);

  Future<void> recordError(dynamic error, StackTrace? stackTrace, {String? reason}) =>
      _provider.recordError(error, stackTrace, reason: reason);

  Future<void> logLogin(String method) => _provider.logLogin(method);

  Future<void> logSignUp(String method) => _provider.logSignUp(method);

  Future<void> logLogout() => _provider.logLogout();

  Future<void> logAppOpen() => _provider.logAppOpen();

  Future<void> logSubscriptionEvent(String eventType, String? productId, {Map<String, dynamic>? additionalData}) =>
      _provider.logSubscriptionEvent(eventType, productId, additionalData: additionalData);

  Future<void> logPremiumAttempt(String featureName) =>
      _provider.logPremiumAttempt(featureName);

  // Legacy compatibility methods
  void trackLogin(String method, {Map<String, dynamic>? metadata}) =>
      _provider.trackLogin(method, metadata: metadata);

  void trackSignup(String method, {required bool success}) =>
      _provider.trackSignup(method, success: success);

  void trackLogout(String reason) => _provider.trackLogout(reason);

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) =>
      _provider.trackEvent(eventName, parameters: parameters);

  void trackError(String context, String error, {bool fatal = false, Map<String, dynamic>? metadata}) =>
      _provider.trackError(context, error, fatal: fatal, metadata: metadata);

  Future<void> setUserProperties({
    required AnalyticsUserType userType,
    required bool isPremium,
    required int deviceCount,
  }) => _provider.setUserProperties(
        userType: userType,
        isPremium: isPremium,
        deviceCount: deviceCount,
      );

  Future<void> clearUser() => _provider.clearUser();

  void trackAuthFunnelStep(String step) => _provider.trackAuthFunnelStep(step);

  void trackDeviceAdded(String platform) => _provider.trackDeviceAdded(platform);

  void trackDeviceLimitReached() => _provider.trackDeviceLimitReached();

  void trackMigrationStart() => _provider.trackMigrationStart();

  void trackMigrationComplete(int migratedCount, int duration) =>
      _provider.trackMigrationComplete(migratedCount, duration);
}

/// Secondary alias for backward compatibility
typedef AnalyticsService = ReceitaAgroAnalyticsService;