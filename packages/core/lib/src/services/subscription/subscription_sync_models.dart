/// Estratégia para resolução de conflitos entre múltiplas fontes
enum ConflictResolutionStrategy {
  /// Baseado em prioridade dos providers
  ///
  /// A fonte com maior prioridade sempre vence.
  /// Ex: RevenueCat (100) > Firebase (80) > Webhook (60)
  priorityBased,

  /// Baseado no timestamp mais recente
  ///
  /// A subscription com updatedAt mais recente vence,
  /// independente da fonte
  timestampBased,

  /// Mais permissivo vence
  ///
  /// Se qualquer fonte diz que é premium, considera premium.
  /// Útil para evitar false negatives
  mostPermissive,

  /// Mais restritivo vence
  ///
  /// Apenas considera premium se TODAS as fontes confirmarem.
  /// Útil para segurança máxima
  mostRestrictive,

  /// Override manual do app
  ///
  /// O app implementa lógica customizada de resolução
  manualOverride,
}

/// Nível de log para debug de sync
enum SubscriptionSyncLogLevel {
  /// Sem logs
  none,

  /// Apenas erros
  error,

  /// Avisos e erros
  warning,

  /// Informações gerais + avisos + erros
  info,

  /// Tudo, incluindo debug detalhado
  debug,
}

/// Fonte de atualização de subscription
enum SubscriptionSyncSource {
  /// RevenueCat (in-app purchases)
  revenueCat,

  /// Firebase Firestore
  firebase,

  /// Webhook de pagamento
  webhook,

  /// Cache local
  local,

  /// Inicialização do app
  initialization,

  /// Sincronização manual/forçada
  manual,

  /// Desconhecida
  unknown,
}

/// Configuração para o serviço de sincronização avançado
class AdvancedSyncConfiguration {
  const AdvancedSyncConfiguration({
    this.conflictStrategy = ConflictResolutionStrategy.priorityBased,
    this.enableDebounce = true,
    this.debounceDuration = const Duration(seconds: 2),
    this.enableRetry = true,
    this.maxRetryAttempts = 3,
    this.retryBackoffMultiplier = 2.0,
    this.enablePeriodicSync = true,
    this.syncInterval = const Duration(minutes: 30),
    this.enableOfflineSupport = true,
    this.logLevel = SubscriptionSyncLogLevel.info,
  });

  /// Estratégia de resolução de conflitos
  final ConflictResolutionStrategy conflictStrategy;

  /// Se deve usar debounce para evitar múltiplas atualizações rápidas
  final bool enableDebounce;

  /// Duração do debounce
  final Duration debounceDuration;

  /// Se deve fazer retry automático em caso de erro
  final bool enableRetry;

  /// Número máximo de tentativas de retry
  final int maxRetryAttempts;

  /// Multiplicador para backoff exponencial (2.0 = dobra a cada tentativa)
  final double retryBackoffMultiplier;

  /// Se deve fazer sync periódico automático
  final bool enablePeriodicSync;

  /// Intervalo entre syncs periódicos
  final Duration syncInterval;

  /// Se deve suportar modo offline com fallback para cache
  final bool enableOfflineSupport;

  /// Nível de log
  final SubscriptionSyncLogLevel logLevel;

  /// Copia a configuração com valores modificados
  AdvancedSyncConfiguration copyWith({
    ConflictResolutionStrategy? conflictStrategy,
    bool? enableDebounce,
    Duration? debounceDuration,
    bool? enableRetry,
    int? maxRetryAttempts,
    double? retryBackoffMultiplier,
    bool? enablePeriodicSync,
    Duration? syncInterval,
    bool? enableOfflineSupport,
    SubscriptionSyncLogLevel? logLevel,
  }) {
    return AdvancedSyncConfiguration(
      conflictStrategy: conflictStrategy ?? this.conflictStrategy,
      enableDebounce: enableDebounce ?? this.enableDebounce,
      debounceDuration: debounceDuration ?? this.debounceDuration,
      enableRetry: enableRetry ?? this.enableRetry,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      retryBackoffMultiplier:
          retryBackoffMultiplier ?? this.retryBackoffMultiplier,
      enablePeriodicSync: enablePeriodicSync ?? this.enablePeriodicSync,
      syncInterval: syncInterval ?? this.syncInterval,
      enableOfflineSupport: enableOfflineSupport ?? this.enableOfflineSupport,
      logLevel: logLevel ?? this.logLevel,
    );
  }

  /// Configuração padrão (balanceada)
  static const AdvancedSyncConfiguration standard = AdvancedSyncConfiguration();

  /// Configuração agressiva (sync frequente, retry rápido)
  static const AdvancedSyncConfiguration aggressive = AdvancedSyncConfiguration(
    enableDebounce: false,
    maxRetryAttempts: 5,
    syncInterval: Duration(minutes: 10),
    logLevel: SubscriptionSyncLogLevel.debug,
  );

  /// Configuração conservadora (sync menos frequente, economiza bateria/dados)
  static const AdvancedSyncConfiguration conservative =
      AdvancedSyncConfiguration(
        debounceDuration: Duration(seconds: 5),
        maxRetryAttempts: 2,
        syncInterval: Duration(hours: 1),
        logLevel: SubscriptionSyncLogLevel.warning,
      );
}
