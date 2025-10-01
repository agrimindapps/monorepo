import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Estado do analytics para Riverpod StateNotifier
@immutable
class AnalyticsState {
  final bool isInitialized;
  final bool isAnalyticsEnabled;
  final String? errorMessage;

  const AnalyticsState({
    this.isInitialized = false,
    this.isAnalyticsEnabled = true,
    this.errorMessage,
  });

  /// Estado inicial padrão
  factory AnalyticsState.initial() {
    return AnalyticsState(
      isAnalyticsEnabled: EnvironmentConfig.enableAnalytics,
    );
  }

  /// Cria uma cópia com alterações
  AnalyticsState copyWith({
    bool? isInitialized,
    bool? isAnalyticsEnabled,
    String? errorMessage,
  }) {
    return AnalyticsState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAnalyticsEnabled: isAnalyticsEnabled ?? this.isAnalyticsEnabled,
      errorMessage: errorMessage,
    );
  }

  /// Remove erro
  AnalyticsState clearError() {
    return copyWith(errorMessage: null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalyticsState &&
        other.isInitialized == isInitialized &&
        other.isAnalyticsEnabled == isAnalyticsEnabled &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      isInitialized.hashCode ^
      isAnalyticsEnabled.hashCode ^
      errorMessage.hashCode;
}

/// StateNotifier para gerenciar analytics usando EnhancedAnalyticsService
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final EnhancedAnalyticsService _enhancedService;

  AnalyticsNotifier({
    required IAnalyticsRepository analyticsRepository,
    required ICrashlyticsRepository crashlyticsRepository,
  }) : _enhancedService = EnhancedAnalyticsService(
         analytics: analyticsRepository,
         crashlytics: crashlyticsRepository,
         config: AnalyticsConfig.forApp(
           appId: 'plantis',
           version: '1.0.0', // TODO: Get from package_info
           enableAnalytics: EnvironmentConfig.enableAnalytics,
           enableLogging: kDebugMode || EnvironmentConfig.enableLogging,
         ),
       ),
       super(AnalyticsState.initial()) {
    _initialize();
  }

  /// Inicialização do analytics
  void _initialize() {
    state = state.copyWith(
      isInitialized: true,
      isAnalyticsEnabled: EnvironmentConfig.enableAnalytics,
    );
  }

  /// Direct access to enhanced service para funcionalidades avançadas
  EnhancedAnalyticsService get enhancedService => _enhancedService;

  // ==========================================================================
  // MÉTODOS PRINCIPAIS DE ANALYTICS
  // ==========================================================================

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
        userId: 'current_user', // Será atualizado pelo user ID real
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
        logAsAnalyticsEvent:
            true, // Log erros críticos como eventos de analytics
      );
      state = state.clearError();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Erro ao registrar erro: $e');
    }
  }

  // ==========================================================================
  // EVENTOS DE AUTENTICAÇÃO
  // ==========================================================================

  Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
  }

  Future<void> logSignUp(String method) async {
    await logEvent('signup', {'method': method});
  }

  Future<void> logLogout() async {
    await logEvent('logout', null);
  }

  // ==========================================================================
  // EVENTOS DE LIFECYCLE DO APP
  // ==========================================================================

  Future<void> logAppOpen() async {
    await logEvent('app_open', {'app': 'plantis'});
  }

  Future<void> logAppBackground() async {
    await logEvent('app_background', {'app': 'plantis'});
  }

  // ==========================================================================
  // EVENTOS DE USO DE FUNCIONALIDADES
  // ==========================================================================

  Future<void> logFeatureUsed(String featureName) async {
    await logEvent('feature_used', {'feature': featureName});
  }

  // ==========================================================================
  // EVENTOS ESPECÍFICOS DO PLANTIS (Enhanced com eventos tipados)
  // ==========================================================================

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

  // ==========================================================================
  // EVENTOS PREMIUM
  // ==========================================================================

  Future<void> logSubscriptionPurchased(String productId, double price) async {
    if (!state.isAnalyticsEnabled) return;

    try {
      await _enhancedService.logPurchaseEvent(
        productId: productId,
        value: price,
        currency: 'USD', // TODO: Get from user locale or RevenueCat
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
      'app': 'plantis',
      'trial_type': 'premium',
    });
  }

  Future<void> logTrialEnded(String reason) async {
    await logEvent('trial_ended', {'app': 'plantis', 'reason': reason});
  }

  // ==========================================================================
  // EVENTOS DE PESQUISA E DESCOBERTA
  // ==========================================================================

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

  // ==========================================================================
  // EVENTOS DE ENGAJAMENTO
  // ==========================================================================

  Future<void> logUserEngagement(String action, int durationSeconds) async {
    await logEvent('user_engagement', {
      'action': action,
      'duration_seconds': durationSeconds,
      'engagement_time_msec': durationSeconds * 1000,
    });
  }

  Future<void> logSessionStart() async {
    await logEvent('session_start', {
      'app': 'plantis',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> logSessionEnd(int durationSeconds) async {
    await logEvent('session_end', {
      'app': 'plantis',
      'duration_seconds': durationSeconds,
    });
  }

  // ==========================================================================
  // DESENVOLVIMENTO E TESTES
  // ==========================================================================

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

// =============================================================================
// PROVIDERS PRINCIPAIS
// =============================================================================

/// Provider do repositório de analytics (obtido via DI)
final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  // TODO: Integrar com GetIt ou criar factory
  throw UnimplementedError('IAnalyticsRepository deve ser fornecido via DI');
});

/// Provider do repositório de crashlytics (obtido via DI)
final crashlyticsRepositoryProvider = Provider<ICrashlyticsRepository>((ref) {
  // TODO: Integrar com GetIt ou criar factory
  throw UnimplementedError('ICrashlyticsRepository deve ser fornecido via DI');
});

/// Provider principal do AnalyticsNotifier
final analyticsNotifierProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
      final analyticsRepository = ref.watch(analyticsRepositoryProvider);
      final crashlyticsRepository = ref.watch(crashlyticsRepositoryProvider);

      return AnalyticsNotifier(
        analyticsRepository: analyticsRepository,
        crashlyticsRepository: crashlyticsRepository,
      );
    });

// =============================================================================
// PROVIDERS DERIVADOS PARA FACILITAR USO
// =============================================================================

/// Provider para verificar se analytics está inicializado
final analyticsInitializedProvider = Provider<bool>((ref) {
  return ref.watch(analyticsNotifierProvider).isInitialized;
});

/// Provider para verificar se analytics está habilitado
final analyticsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(analyticsNotifierProvider).isAnalyticsEnabled;
});

/// Provider para mensagem de erro do analytics
final analyticsErrorProvider = Provider<String?>((ref) {
  return ref.watch(analyticsNotifierProvider).errorMessage;
});

/// Provider para verificar se está em modo debug
final isDebugModeProvider = Provider<bool>((ref) {
  return kDebugMode;
});

// =============================================================================
// PROVIDERS DE CONVENIÊNCIA PARA USO DIRETO
// =============================================================================

/// Provider para acesso direto ao AnalyticsNotifier para métodos específicos
final analyticsServiceProvider = Provider<AnalyticsNotifier>((ref) {
  return ref.watch(analyticsNotifierProvider.notifier);
});

/// Provider para verificar se deve mostrar configurações de analytics
final shouldShowAnalyticsSettingsProvider = Provider<bool>((ref) {
  final isDebug = ref.watch(isDebugModeProvider);
  final isEnabled = ref.watch(analyticsEnabledProvider);

  // Mostrar configurações apenas em modo debug ou se analytics estiver habilitado
  return isDebug || isEnabled;
});

/// Provider para status text do analytics
final analyticsStatusTextProvider = Provider<String>((ref) {
  final isEnabled = ref.watch(analyticsEnabledProvider);
  final isDebug = ref.watch(isDebugModeProvider);

  if (!isEnabled) {
    return 'Analytics desabilitado';
  }

  if (isDebug) {
    return 'Analytics habilitado (modo debug)';
  }

  return 'Analytics habilitado';
});

/// Provider para ícone do status de analytics
final analyticsStatusIconProvider = Provider<IconData>((ref) {
  final isEnabled = ref.watch(analyticsEnabledProvider);
  final hasError = ref.watch(analyticsErrorProvider) != null;

  if (hasError) {
    return Icons.error;
  }

  return isEnabled ? Icons.analytics : Icons.analytics_outlined;
});
