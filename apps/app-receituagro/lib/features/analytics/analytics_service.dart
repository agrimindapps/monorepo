import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

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

/// Enum de tipos de usuário para analytics
enum AnalyticsUserType { guest, registered, premium }

/// Serviço de Analytics específico do ReceitauAgro
/// Integra com Firebase Analytics e outros serviços de tracking
class ReceitaAgroAnalyticsService {
  final IAnalyticsRepository _analyticsRepository;
  final ICrashlyticsRepository _crashlyticsRepository;

  ReceitaAgroAnalyticsService({
    required IAnalyticsRepository analyticsRepository,
    required ICrashlyticsRepository crashlyticsRepository,
  })  : _analyticsRepository = analyticsRepository,
        _crashlyticsRepository = crashlyticsRepository;

  // Factory for dependency injection compatibility
  factory ReceitaAgroAnalyticsService.withRepositories(
    IAnalyticsRepository analyticsRepository,
    ICrashlyticsRepository crashlyticsRepository,
  ) {
    return ReceitaAgroAnalyticsService(
      analyticsRepository: analyticsRepository,
      crashlyticsRepository: crashlyticsRepository,
    );
  }

  // Initialize method for backward compatibility
  Future<void> initialize() async {
    // Core Package analytics are already initialized
    // This is a placeholder for backward compatibility
    if (kDebugMode) {
      print('✅ ReceitaAgro Analytics Service initialized with Core Package');
    }
  }

  // ===== USER MANAGEMENT =====
  
  Future<void> setUserId(String userId) async {
    try {
      await _analyticsRepository.setUserId(userId);
      await _crashlyticsRepository.setUserId(userId);
    } catch (e) {
      if (kDebugMode) print('❌ Analytics: Error setting user ID - $e');
    }
  }

  Future<void> setUserProperties({
    required AnalyticsUserType userType,
    required bool isPremium,
    required int deviceCount,
  }) async {
    try {
      final result = await _analyticsRepository.setUserProperties(properties: {
        'user_type': userType.toString(),
        'is_premium': isPremium.toString(),
        'device_count': deviceCount.toString(),
      });
      
      result.fold(
        (failure) => _handleAnalyticsError('setUserProperties', failure.message),
        (_) => null,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Analytics: Error setting user properties - $e');
    }
  }

  Future<void> clearUser() async {
    try {
      final result = await _analyticsRepository.setUserId(null);
      result.fold(
        (failure) => _handleAnalyticsError('clearUser', failure.message),
        (_) => null,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Analytics: Error clearing user - $e');
    }
  }

  // ===== AUTHENTICATION EVENTS =====

  void trackLogin(String method, {Map<String, dynamic>? metadata}) {
    _trackEvent('user_login', {
      'method': method,
      'timestamp': DateTime.now().toIso8601String(),
      ...?metadata,
    });
  }

  void trackSignup(String method, {required bool success}) {
    _trackEvent('user_signup', {
      'method': method,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackLogout(String reason) {
    _trackEvent('user_logout', {
      'reason': reason, // 'user_action', 'session_expired', 'device_limit'
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ===== AUTH FUNNEL TRACKING =====

  void trackAuthFunnelStep(String step) {
    final funnelSteps = {
      'auth_page_viewed',
      'login_attempt',
      'login_success',
      'signup_attempt',
      'signup_success',
      'anonymous_upgrade_attempt',
      'anonymous_upgrade_success',
    };

    if (funnelSteps.contains(step)) {
      _trackEvent('auth_funnel', {
        'step': step,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // ===== MIGRATION EVENTS =====

  void trackMigrationStart() {
    _trackEvent('migration_started', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackMigrationComplete(int migratedCount, int duration) {
    _trackEvent('migration_completed', {
      'migrated_count': migratedCount,
      'duration_ms': duration,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ===== DEVICE EVENTS =====

  void trackDeviceAdded(String platform) {
    _trackEvent('device_added', {
      'platform': platform,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void trackDeviceLimitReached() {
    _trackEvent('device_limit_reached', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ===== GENERIC EVENTS =====

  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    _trackEvent(eventName, parameters ?? {});
  }

  void trackError(String context, String error, {
    bool fatal = false,
    Map<String, dynamic>? metadata,
  }) {
    _trackEvent('app_error', {
      'context': context,
      'error': error,
      'fatal': fatal,
      ...?metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Also report to Crashlytics
    _crashlyticsRepository.recordError(
      exception: Exception('$context: $error'),
      stackTrace: StackTrace.current,
      fatal: fatal,
    );
  }

  // ===== PREMIUM EVENTS =====

  Future<void> logEvent(
    ReceitaAgroAnalyticsEvent event, {
    Map<String, dynamic>? parameters,
  }) async {
    _trackEvent(event.eventName, parameters ?? {});
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  }) async {
    await _crashlyticsRepository.recordError(
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
      fatal: fatal,
    );
  }

  Future<void> logSubscriptionEvent(
    String eventType,
    String? productId, {
    Map<String, dynamic>? additionalData,
  }) async {
    ReceitaAgroAnalyticsEvent event;
    switch (eventType) {
      case 'viewed':
        event = ReceitaAgroAnalyticsEvent.subscriptionViewed;
        break;
      case 'purchased':
        event = ReceitaAgroAnalyticsEvent.subscriptionPurchased;
        break;
      case 'cancelled':
        event = ReceitaAgroAnalyticsEvent.subscriptionCancelled;
        break;
      default:
        return;
    }

    await logEvent(
      event,
      parameters: {
        if (productId != null) 'product_id': productId,
        ...?additionalData,
      },
    );
  }

  Future<void> logPremiumAttempt(String featureName) async {
    await logEvent(
      ReceitaAgroAnalyticsEvent.premiumFeatureAttempted,
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  // ===== PRIVATE METHODS =====

  void _trackEvent(String eventName, Map<String, dynamic> parameters) {
    try {
      _analyticsRepository.logEvent(
        eventName,
        parameters: parameters,
      ).then((result) {
        result.fold(
          (failure) => _handleAnalyticsError(eventName, failure.message),
          (_) => null,
        );
      });
      
      if (kDebugMode) {
        print('📊 Analytics: $eventName - $parameters');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Analytics: Error tracking event $eventName - $e');
    }
  }

  void _handleAnalyticsError(String context, String error) {
    if (kDebugMode) print('❌ Analytics Error [$context]: $error');
  }
}