import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'analytics_state.dart';

part 'analytics_notifier.g.dart';

/// Provider do repositório de analytics (obtido via DI)
@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return FirebaseAnalyticsService();
}

/// Provider do repositório de crashlytics (obtido via DI)
@riverpod
ICrashlyticsRepository crashlyticsRepository(Ref ref) {
  return FirebaseCrashlyticsService();
}

/// Notifier principal para gerenciar analytics com @riverpod
@riverpod
class Analytics extends _$Analytics {
  late final EnhancedAnalyticsService _enhancedService;

  @override
  PlantisAnalyticsState build() {
    final analyticsRepo = ref.watch(analyticsRepositoryProvider);
    final crashlyticsRepo = ref.watch(crashlyticsRepositoryProvider);

    _enhancedService = EnhancedAnalyticsService(
      analytics: analyticsRepo,
      crashlytics: crashlyticsRepo,
      config: AnalyticsConfig.forApp(
        appId: AppConstants.appId,
        version: AppConstants.defaultVersion,
        enableAnalytics: EnvironmentConfig.enableAnalytics,
        enableLogging: kDebugMode || EnvironmentConfig.enableLogging,
      ),
    );

    return PlantisAnalyticsStateX.initial().copyWith(isInitialized: true);
  }

  /// Direct access to enhanced service para funcionalidades avançadas
  EnhancedAnalyticsService get enhancedService => _enhancedService;

  /// Logs screen view com tratamento de erro aprimorado
  Future<void> logScreenView(String screenName) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.setCurrentScreen(screenName);
      await _enhancedService.logEvent('screen_view', {
        'screen_name': screenName,
      });
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao registrar tela: $e');
    }
  }

  /// Logs custom event com tratamento de erro aprimorado
  Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logEvent(eventName, parameters);
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao registrar evento: $e');
    }
  }

  /// Define user ID em analytics e crashlytics
  Future<void> setUserId(String userId) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.setUser(userId: userId);
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao definir usuário: $e');
    }
  }

  /// Define propriedades do usuário
  Future<void> setUserProperty(String name, String value) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.setUser(
        userId: 'current_user',
        properties: {name: value},
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao definir propriedade: $e');
    }
  }

  /// Registra erro com reporte aprimorado
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    try {
      await _enhancedService.recordError(
        error,
        stackTrace,
        reason: reason,
        logAsAnalyticsEvent: true,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao registrar erro: $e');
    }
  }

  Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
  }

  Future<void> logSignUp(String method) async {
    await logEvent('signup', {'method': method});
  }

  Future<void> logLogout() async {
    await logEvent('logout', null);
  }

  Future<void> logAppOpen() async {
    await logEvent('app_open', {
      AppConstants.analyticsAppParam: AppConstants.appId,
    });
  }

  Future<void> logAppBackground() async {
    await logEvent('app_background', {
      AppConstants.analyticsAppParam: AppConstants.appId,
    });
  }

  Future<void> logFeatureUsed(String featureName) async {
    await logEvent('feature_used', {'feature': featureName});
  }

  Future<void> logPlantCreated({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.plantCreated,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar criação de planta: $e',
      );
    }
  }

  Future<void> logPlantDeleted({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.plantDeleted,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar exclusão de planta: $e',
      );
    }
  }

  Future<void> logPlantUpdated({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.plantUpdated,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar atualização de planta: $e',
      );
    }
  }

  Future<void> logTaskCompleted(
    String taskType, {
    Map<String, dynamic>? additionalData,
  }) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.taskCompleted,
        additionalParameters: {
          'task_type': taskType,
          if (additionalData != null) ...additionalData,
        },
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar conclusão de tarefa: $e',
      );
    }
  }

  Future<void> logTaskCreated({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.taskCreated,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar criação de tarefa: $e',
      );
    }
  }

  Future<void> logSpaceCreated({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.spaceCreated,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar criação de espaço: $e',
      );
    }
  }

  Future<void> logSpaceDeleted({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.spaceDeleted,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar exclusão de espaço: $e',
      );
    }
  }

  Future<void> logPremiumFeatureAttempted(
    String featureName, {
    Map<String, dynamic>? additionalData,
  }) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.premiumFeatureAttempted,
        additionalParameters: {
          'feature': featureName,
          if (additionalData != null) ...additionalData,
        },
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Erro ao registrar tentativa de funcionalidade premium: $e',
      );
    }
  }

  Future<void> logCareLogAdded({Map<String, dynamic>? additionalData}) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.careLogAdded,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar log de cuidado: $e',
      );
    }
  }

  Future<void> logPlantPhotoAdded({
    Map<String, dynamic>? additionalData,
  }) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logAppSpecificEvent(
        PlantisEvent.plantPhotoAdded,
        additionalParameters: additionalData,
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar adição de foto: $e',
      );
    }
  }

  Future<void> logSubscriptionPurchased(String productId, double price) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logPurchaseEvent(
        productId: productId,
        value: price,
        currency: 'USD',
        additionalParameters: {'subscription_type': 'premium'},
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao registrar compra de assinatura: $e',
      );
    }
  }

  Future<void> logTrialStarted() async {
    await logEvent('trial_started', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'trial_type': 'premium',
    });
  }

  Future<void> logTrialEnded(String reason) async {
    await logEvent('trial_ended', {'app': 'plantis', 'reason': reason});
  }

  Future<void> logSearch(String query, int resultCount) async {
    await logEvent('search', {
      'query': query,
      'result_count': resultCount,
      'category': 'plants',
    });
  }

  Future<void> logContentViewed(String contentType, String contentId) async {
    await logEvent('content_viewed', {
      'content_type': contentType,
      'content_id': contentId,
    });
  }

  Future<void> logUserEngagement(String action, int durationSeconds) async {
    await logEvent('user_engagement', {
      'action': action,
      'duration_seconds': durationSeconds,
      'engagement_time_msec': durationSeconds * 1000,
    });
  }

  Future<void> logSessionStart() async {
    await logEvent('session_start', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logSessionEnd(int durationSeconds) async {
    await logEvent('session_end', {
      AppConstants.analyticsAppParam: AppConstants.appId,
      'duration_seconds': durationSeconds,
    });
  }

  Future<void> testCrash() async {
    try {
      await _enhancedService.testCrash();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro no teste de crash: $e');
    }
  }

  Future<void> testAnalyticsEvent() async {
    try {
      await _enhancedService.testAnalyticsEvent();
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro no teste de analytics: $e');
    }
  }

  /// Registra evento de desenvolvimento para depuração
  Future<void> logDevelopmentEvent(
    String event,
    Map<String, dynamic>? data,
  ) async {
    if (kDebugMode && state.isAnalyticsEnabled) {
      await logEvent('dev_$event', {
        'is_development': true,
        if (data != null) ...data,
      });
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    if (state.errorMessage != null) {
      state = state.clearError();
    }
  }

  /// Atualiza se analytics está habilitado
  void updateAnalyticsEnabled(bool enabled) {
    state = state.copyWith(isAnalyticsEnabled: enabled);
  }
}

// ============================================================================
// DERIVED STATE PROVIDERS (Computed values)
// ============================================================================

/// Provider para verificar se analytics está inicializado
@riverpod
bool analyticsInitialized(Ref ref) {
  return ref.watch(analyticsProvider).isInitialized;
}

/// Provider para verificar se analytics está habilitado
@riverpod
bool analyticsEnabled(Ref ref) {
  return ref.watch(analyticsProvider).isAnalyticsEnabled;
}

/// Provider para mensagem de erro do analytics
@riverpod
String? analyticsError(Ref ref) {
  return ref.watch(analyticsProvider).errorMessage;
}

/// Provider para verificar se está em modo debug
@riverpod
bool isDebugMode(Ref ref) {
  return kDebugMode;
}

/// Provider para acesso direto ao Analytics para métodos específicos
@riverpod
Analytics analyticsService(Ref ref) {
  return ref.watch(analyticsProvider.notifier);
}

/// Provider para verificar se deve mostrar configurações de analytics
@riverpod
bool shouldShowAnalyticsSettings(Ref ref) {
  final isDebug = ref.watch(isDebugModeProvider);
  final isEnabled = ref.watch(analyticsEnabledProvider);
  return isDebug || isEnabled;
}

/// Provider para status text do analytics
@riverpod
String analyticsStatusText(Ref ref) {
  final isEnabled = ref.watch(analyticsEnabledProvider);
  final isDebug = ref.watch(isDebugModeProvider);

  if (!isEnabled) {
    return 'Analytics desabilitado';
  }

  if (isDebug) {
    return 'Analytics habilitado (modo debug)';
  }

  return 'Analytics habilitado';
}

/// Provider para ícone do status de analytics
@riverpod
IconData analyticsStatusIcon(Ref ref) {
  final isEnabled = ref.watch(analyticsEnabledProvider);
  final hasError = ref.watch(analyticsErrorProvider) != null;

  if (hasError) {
    return Icons.error;
  }

  return isEnabled ? Icons.analytics : Icons.analytics_outlined;
}
