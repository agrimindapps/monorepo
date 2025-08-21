import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

class AnalyticsProvider {
  final IAnalyticsRepository _analyticsRepository;
  final ICrashlyticsRepository _crashlyticsRepository;

  AnalyticsProvider({
    required IAnalyticsRepository analyticsRepository,
    required ICrashlyticsRepository crashlyticsRepository,
  }) : _analyticsRepository = analyticsRepository,
       _crashlyticsRepository = crashlyticsRepository;

  /// Verifica se o analytics está habilitado baseado no ambiente
  bool get _isAnalyticsEnabled => EnvironmentConfig.enableAnalytics;

  /// Verifica se está em modo debug para logs locais
  bool get _isDebugMode => EnvironmentConfig.isDebugMode;

  // Analytics methods
  Future<void> logScreenView(String screenName) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('📊 [DEV] Analytics: Screen view - $screenName');
      }
      return;
    }

    try {
      await _analyticsRepository.setCurrentScreen(screenName: screenName);
      await _analyticsRepository.logEvent(
        'screen_view',
        parameters: {'screen_name': screenName},
      );
      debugPrint('📊 Analytics: Screen view logged - $screenName');
    } catch (e, stackTrace) {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to log screen view: $screenName',
      );
    }
  }

  Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint(
          '📊 [DEV] Analytics: Event - $eventName ${parameters ?? ''}',
        );
      }
      return;
    }

    try {
      await _analyticsRepository.logEvent(eventName, parameters: parameters);
      debugPrint('📊 Analytics: Event logged - $eventName');
    } catch (e, stackTrace) {
      await _crashlyticsRepository.recordError(
        exception: e,
        stackTrace: stackTrace,
        reason: 'Failed to log event: $eventName',
      );
    }
  }

  Future<void> logUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent('user_action', {'action': action, ...?parameters});
  }

  // Auth events
  Future<void> logLogin(String method) async {
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('📊 [DEV] Analytics: Login - $method');
      }
      return;
    }
    await _analyticsRepository.logLogin(method: method);
  }

  Future<void> logSignUp(String method) async {
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('📊 [DEV] Analytics: SignUp - $method');
      }
      return;
    }
    await _analyticsRepository.logSignUp(method: method);
  }

  Future<void> logLogout() async {
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('📊 [DEV] Analytics: Logout');
      }
      return;
    }
    await _analyticsRepository.logLogout();
  }

  // App lifecycle events
  Future<void> logAppOpen() async {
    await logEvent('app_open', null);
  }

  Future<void> logAppBackground() async {
    await logEvent('app_background', null);
  }

  // Feature usage events
  Future<void> logFeatureUsed(String featureName) async {
    await logEvent('feature_used', {'feature': featureName});
  }

  Future<void> logPlantCreated() async {
    await logEvent('plant_created', null);
  }

  Future<void> logTaskCompleted(String taskType) async {
    await logEvent('task_completed', {'task_type': taskType});
  }

  Future<void> logSpaceCreated() async {
    await logEvent('space_created', null);
  }

  // Premium events
  Future<void> logPremiumFeatureAttempted(String featureName) async {
    await logEvent('premium_feature_attempted', {'feature': featureName});
  }

  // Crashlytics methods
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? customKeys,
  }) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('🔥 [DEV] Crashlytics: Error - ${error.toString()}');
        if (reason != null) debugPrint('🔥 [DEV] Reason: $reason');
      }
      return;
    }

    if (customKeys != null) {
      await _crashlyticsRepository.setCustomKeys(keys: customKeys);
    }

    await _crashlyticsRepository.recordError(
      exception: error,
      stackTrace: stackTrace ?? StackTrace.current,
      reason: reason,
    );

    debugPrint('🔥 Crashlytics: Error recorded - ${error.toString()}');
  }

  Future<void> recordNonFatalError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint(
          '⚠️ [DEV] Crashlytics: Non-fatal error - ${error.toString()}',
        );
        if (reason != null) debugPrint('⚠️ [DEV] Reason: $reason');
      }
      return;
    }

    await _crashlyticsRepository.recordNonFatalError(
      exception: error,
      stackTrace: stackTrace ?? StackTrace.current,
      reason: reason,
    );

    debugPrint(
      '⚠️ Crashlytics: Non-fatal error recorded - ${error.toString()}',
    );
  }

  Future<void> log(String message) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('📝 [DEV] Crashlytics: Log - $message');
      }
      return;
    }

    await _crashlyticsRepository.log(message);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('🔑 [DEV] Crashlytics: Custom key - $key: $value');
      }
      return;
    }

    await _crashlyticsRepository.setCustomKey(key: key, value: value);
  }

  Future<void> setUserId(String userId) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('👤 [DEV] Analytics/Crashlytics: User ID - $userId');
      }
      return;
    }

    await _analyticsRepository.setUserId(userId);
    await _crashlyticsRepository.setUserId(userId);
  }

  Future<void> setUserProperties(Map<String, String> properties) async {
    // Em development, apenas loga localmente
    if (!_isAnalyticsEnabled) {
      if (_isDebugMode) {
        debugPrint('👤 [DEV] Analytics: User properties - $properties');
      }
      return;
    }

    await _analyticsRepository.setUserProperties(properties: properties);
  }

  // Test methods for development
  Future<void> testCrash() async {
    if (kDebugMode) {
      throw Exception('Test crash from Analytics Provider');
    }
  }

  Future<void> testNonFatalError() async {
    if (kDebugMode) {
      await recordNonFatalError(
        Exception('Test non-fatal error'),
        StackTrace.current,
        reason: 'Testing non-fatal error reporting',
      );
    }
  }
}
