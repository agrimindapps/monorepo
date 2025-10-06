import '../domain/repositories/i_sync_repository.dart';
import 'entity_sync_registration.dart';

/// Configuração de sincronização específica por aplicativo
class AppSyncConfig {
  const AppSyncConfig({
    required this.appName,
    this.enableAutoSync = true,
    this.syncInterval = const Duration(minutes: 5),
    this.enableRealtimeSync = true,
    this.enableOfflineMode = true,
    this.batchSize = 50,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 30),
    this.globalConflictStrategy = ConflictStrategy.timestamp,
    this.enableOrchestration = false,
    this.enableSyncMetrics = true,
    this.enableDebugMode = false,
    this.syncTimeout = const Duration(minutes: 10),
    this.maxConcurrentSyncs = 3,
  });

  /// Nome único do aplicativo
  final String appName;

  /// Se deve sincronizar automaticamente em intervalos
  final bool enableAutoSync;

  /// Intervalo entre sincronizações automáticas
  final Duration syncInterval;

  /// Se deve sincronizar em tempo real (Firebase listeners)
  final bool enableRealtimeSync;

  /// Se deve funcionar offline
  final bool enableOfflineMode;

  /// Tamanho padrão dos lotes para sincronização
  final int batchSize;

  /// Máximo de tentativas em caso de erro
  final int maxRetries;

  /// Delay entre tentativas
  final Duration retryDelay;

  /// Estratégia global de resolução de conflitos (pode ser sobrescrita por entidade)
  final ConflictStrategy globalConflictStrategy;

  /// Se deve usar orquestração de dependências entre entidades
  final bool enableOrchestration;

  /// Se deve coletar métricas de sincronização
  final bool enableSyncMetrics;

  /// Se deve habilitar logs detalhados de debug
  final bool enableDebugMode;

  /// Timeout para operações de sincronização
  final Duration syncTimeout;

  /// Máximo de sincronizações concorrentes
  final int maxConcurrentSyncs;

  /// Cria configuração simples (para apps básicos como Plantis)
  factory AppSyncConfig.simple({
    required String appName,
    Duration syncInterval = const Duration(minutes: 10),
    ConflictStrategy conflictStrategy = ConflictStrategy.timestamp,
  }) {
    return AppSyncConfig(
      appName: appName,
      enableAutoSync: true,
      syncInterval: syncInterval,
      enableRealtimeSync: false,
      enableOfflineMode: true,
      batchSize: 25,
      maxRetries: 2,
      globalConflictStrategy: conflictStrategy,
      enableOrchestration: false,
      enableSyncMetrics: false,
      enableDebugMode: false,
      maxConcurrentSyncs: 1,
    );
  }

  /// Cria configuração avançada (para apps complexos como Gasometer)
  factory AppSyncConfig.advanced({
    required String appName,
    Duration syncInterval = const Duration(minutes: 2),
    ConflictStrategy conflictStrategy = ConflictStrategy.version,
    bool enableOrchestration = true,
  }) {
    return AppSyncConfig(
      appName: appName,
      enableAutoSync: true,
      syncInterval: syncInterval,
      enableRealtimeSync: true,
      enableOfflineMode: true,
      batchSize: 100,
      maxRetries: 5,
      retryDelay: const Duration(seconds: 15),
      globalConflictStrategy: conflictStrategy,
      enableOrchestration: enableOrchestration,
      enableSyncMetrics: true,
      enableDebugMode: false,
      syncTimeout: const Duration(minutes: 5),
      maxConcurrentSyncs: 5,
    );
  }

  /// Cria configuração para desenvolvimento/debug
  factory AppSyncConfig.development({
    required String appName,
    Duration syncInterval = const Duration(minutes: 1),
  }) {
    return AppSyncConfig(
      appName: appName,
      enableAutoSync: true,
      syncInterval: syncInterval,
      enableRealtimeSync: true,
      enableOfflineMode: true,
      batchSize: 10,
      maxRetries: 2,
      retryDelay: const Duration(seconds: 5),
      globalConflictStrategy: ConflictStrategy.timestamp,
      enableOrchestration: true,
      enableSyncMetrics: true,
      enableDebugMode: true,
      syncTimeout: const Duration(minutes: 2),
      maxConcurrentSyncs: 2,
    );
  }

  /// Cria configuração offline-first (para apps que funcionam principalmente offline)
  factory AppSyncConfig.offlineFirst({
    required String appName,
    Duration syncInterval = const Duration(hours: 1),
  }) {
    return AppSyncConfig(
      appName: appName,
      enableAutoSync: true,
      syncInterval: syncInterval,
      enableRealtimeSync: false,
      enableOfflineMode: true,
      batchSize: 200,
      maxRetries: 10,
      retryDelay: const Duration(minutes: 5),
      globalConflictStrategy: ConflictStrategy.localWins,
      enableOrchestration: false,
      enableSyncMetrics: false,
      enableDebugMode: false,
      syncTimeout: const Duration(minutes: 30),
      maxConcurrentSyncs: 1,
    );
  }

  /// Converte para SyncConfig base compatível com SyncFirebaseService
  SyncConfig toBaseSyncConfig() {
    return SyncConfig(
      syncInterval: syncInterval,
      batchSize: batchSize,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      enableRealtimeSync: enableRealtimeSync,
      enableOfflineMode: enableOfflineMode,
      conflictResolution: _convertConflictStrategy(),
    );
  }

  ConflictResolutionStrategy _convertConflictStrategy() {
    switch (globalConflictStrategy) {
      case ConflictStrategy.timestamp:
        return ConflictResolutionStrategy.timestamp;
      case ConflictStrategy.version:
        return ConflictResolutionStrategy.version;
      case ConflictStrategy.localWins:
        return ConflictResolutionStrategy.localWins;
      case ConflictStrategy.remoteWins:
        return ConflictResolutionStrategy.remoteWins;
      case ConflictStrategy.manual:
      case ConflictStrategy.custom:
        return ConflictResolutionStrategy.manual;
    }
  }

  /// Informações para debug
  Map<String, dynamic> toDebugMap() {
    return {
      'app_name': appName,
      'enable_auto_sync': enableAutoSync,
      'sync_interval_minutes': syncInterval.inMinutes,
      'enable_realtime_sync': enableRealtimeSync,
      'enable_offline_mode': enableOfflineMode,
      'batch_size': batchSize,
      'max_retries': maxRetries,
      'retry_delay_seconds': retryDelay.inSeconds,
      'global_conflict_strategy': globalConflictStrategy.name,
      'enable_orchestration': enableOrchestration,
      'enable_sync_metrics': enableSyncMetrics,
      'enable_debug_mode': enableDebugMode,
      'sync_timeout_minutes': syncTimeout.inMinutes,
      'max_concurrent_syncs': maxConcurrentSyncs,
    };
  }

  /// Cria cópia com modificações
  AppSyncConfig copyWith({
    String? appName,
    bool? enableAutoSync,
    Duration? syncInterval,
    bool? enableRealtimeSync,
    bool? enableOfflineMode,
    int? batchSize,
    int? maxRetries,
    Duration? retryDelay,
    ConflictStrategy? globalConflictStrategy,
    bool? enableOrchestration,
    bool? enableSyncMetrics,
    bool? enableDebugMode,
    Duration? syncTimeout,
    int? maxConcurrentSyncs,
  }) {
    return AppSyncConfig(
      appName: appName ?? this.appName,
      enableAutoSync: enableAutoSync ?? this.enableAutoSync,
      syncInterval: syncInterval ?? this.syncInterval,
      enableRealtimeSync: enableRealtimeSync ?? this.enableRealtimeSync,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      batchSize: batchSize ?? this.batchSize,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      globalConflictStrategy: globalConflictStrategy ?? this.globalConflictStrategy,
      enableOrchestration: enableOrchestration ?? this.enableOrchestration,
      enableSyncMetrics: enableSyncMetrics ?? this.enableSyncMetrics,
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      syncTimeout: syncTimeout ?? this.syncTimeout,
      maxConcurrentSyncs: maxConcurrentSyncs ?? this.maxConcurrentSyncs,
    );
  }

  @override
  String toString() {
    return 'AppSyncConfig(app: $appName, autoSync: $enableAutoSync, '
           'interval: ${syncInterval.inMinutes}min, realtime: $enableRealtimeSync)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSyncConfig &&
        other.appName == appName &&
        other.enableAutoSync == enableAutoSync &&
        other.syncInterval == syncInterval &&
        other.enableRealtimeSync == enableRealtimeSync &&
        other.enableOfflineMode == enableOfflineMode &&
        other.batchSize == batchSize &&
        other.maxRetries == maxRetries &&
        other.retryDelay == retryDelay &&
        other.globalConflictStrategy == globalConflictStrategy &&
        other.enableOrchestration == enableOrchestration &&
        other.enableSyncMetrics == enableSyncMetrics &&
        other.enableDebugMode == enableDebugMode &&
        other.syncTimeout == syncTimeout &&
        other.maxConcurrentSyncs == maxConcurrentSyncs;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      appName,
      enableAutoSync,
      syncInterval,
      enableRealtimeSync,
      enableOfflineMode,
      batchSize,
      maxRetries,
      retryDelay,
      globalConflictStrategy,
      enableOrchestration,
      enableSyncMetrics,
      enableDebugMode,
      syncTimeout,
      maxConcurrentSyncs,
    ]);
  }
}

/// Configuração específica de performance
class SyncPerformanceConfig {
  const SyncPerformanceConfig({
    this.enableBatchOptimization = true,
    this.enableCompressionForLargeBatches = true,
    this.compressionThreshold = 1000, // bytes
    this.enableConnectionPooling = true,
    this.maxConnectionPoolSize = 5,
    this.enableRequestCaching = true,
    this.cacheTtl = const Duration(minutes: 5),
    this.enableNetworkOptimization = true,
    this.preferWifiForLargeSync = true,
    this.pauseSyncOnLowBattery = true,
    this.batteryThreshold = 20, // percent
  });

  /// Se deve otimizar lotes automaticamente
  final bool enableBatchOptimization;

  /// Se deve comprimir dados para lotes grandes
  final bool enableCompressionForLargeBatches;

  /// Threshold em bytes para ativar compressão
  final int compressionThreshold;

  /// Se deve usar pool de conexões
  final bool enableConnectionPooling;

  /// Tamanho máximo do pool de conexões
  final int maxConnectionPoolSize;

  /// Se deve cachear requisições
  final bool enableRequestCaching;

  /// Time-to-live do cache
  final Duration cacheTtl;

  /// Se deve otimizar para diferentes tipos de rede
  final bool enableNetworkOptimization;

  /// Se deve preferir WiFi para syncs grandes
  final bool preferWifiForLargeSync;

  /// Se deve pausar sync quando bateria está baixa
  final bool pauseSyncOnLowBattery;

  /// Threshold de bateria em porcentagem
  final int batteryThreshold;
}

/// Configuração de segurança para sync
class SyncSecurityConfig {
  const SyncSecurityConfig({
    this.enableEncryptionAtRest = true,
    this.enableEncryptionInTransit = true,
    this.requireAuthentication = true,
    this.enableDataValidation = true,
    this.enableIntegrityCheck = true,
    this.enableAuditLog = false,
    this.maxSyncAttemptsPerMinute = 60,
    this.enableRateLimiting = true,
    this.allowAnonymousSync = false,
    this.requireSecureNetwork = false,
  });

  /// Se deve criptografar dados locais
  final bool enableEncryptionAtRest;

  /// Se deve criptografar dados em trânsito
  final bool enableEncryptionInTransit;

  /// Se deve requerer autenticação para sync
  final bool requireAuthentication;

  /// Se deve validar dados antes do sync
  final bool enableDataValidation;

  /// Se deve verificar integridade dos dados
  final bool enableIntegrityCheck;

  /// Se deve manter log de auditoria
  final bool enableAuditLog;

  /// Máximo de tentativas de sync por minuto
  final int maxSyncAttemptsPerMinute;

  /// Se deve limitar rate de requisições
  final bool enableRateLimiting;

  /// Se deve permitir sync anônimo
  final bool allowAnonymousSync;

  /// Se deve requerer rede segura (HTTPS/WiFi confiável)
  final bool requireSecureNetwork;
}
