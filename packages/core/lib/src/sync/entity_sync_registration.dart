import 'package:dartz/dartz.dart';

import '../domain/entities/base_sync_entity.dart';
import '../domain/repositories/i_sync_repository.dart';
import '../shared/utils/failure.dart';

/// Configuração declarativa para registrar entidades no sistema de sync unificado
class EntitySyncRegistration<T extends BaseSyncEntity> {
  const EntitySyncRegistration({
    required this.entityType,
    required this.collectionName,
    required this.fromMap,
    required this.toMap,
    this.conflictStrategy = ConflictStrategy.timestamp,
    this.priority = SyncPriority.normal,
    this.batchSize = 50,
    this.enableRealtime = true,
    this.enableOfflineMode = true,
    this.syncInterval = const Duration(minutes: 5),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 30),
    this.customResolver,
  });

  /// Tipo da entidade (usado como chave de identificação)
  final Type entityType;

  /// Nome da coleção no Firebase
  final String collectionName;

  /// Função para converter de Map para entidade
  final T Function(Map<String, dynamic>) fromMap;

  /// Função para converter de entidade para Map
  final Map<String, dynamic> Function(T) toMap;

  /// Estratégia de resolução de conflitos
  final ConflictStrategy conflictStrategy;

  /// Prioridade de sincronização
  final SyncPriority priority;

  /// Tamanho do lote para sincronização
  final int batchSize;

  /// Se deve sincronizar em tempo real
  final bool enableRealtime;

  /// Se deve funcionar offline
  final bool enableOfflineMode;

  /// Intervalo entre sincronizações automáticas
  final Duration syncInterval;

  /// Máximo de tentativas em caso de erro
  final int maxRetries;

  /// Delay entre tentativas
  final Duration retryDelay;

  /// Resolver de conflitos customizado (opcional)
  final IConflictResolver<T>? customResolver;

  /// Converte para SyncConfig compatível com SyncFirebaseService
  SyncConfig toSyncConfig() {
    return SyncConfig(
      syncInterval: syncInterval,
      batchSize: batchSize,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      enableRealtimeSync: enableRealtime,
      enableOfflineMode: enableOfflineMode,
      conflictResolution: _convertConflictStrategy(),
    );
  }

  ConflictResolutionStrategy _convertConflictStrategy() {
    switch (conflictStrategy) {
      case ConflictStrategy.timestamp:
        return ConflictResolutionStrategy.timestamp;
      case ConflictStrategy.version:
        return ConflictResolutionStrategy.version;
      case ConflictStrategy.localWins:
        return ConflictResolutionStrategy.localWins;
      case ConflictStrategy.remoteWins:
        return ConflictResolutionStrategy.remoteWins;
      case ConflictStrategy.manual:
        return ConflictResolutionStrategy.manual;
      case ConflictStrategy.custom:
        return ConflictResolutionStrategy.manual; // Será tratado pelo custom resolver
    }
  }

  /// Cria uma configuração para entidades simples
  factory EntitySyncRegistration.simple({
    required Type entityType,
    required String collectionName,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
  }) {
    return EntitySyncRegistration<T>(
      entityType: entityType,
      collectionName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
      conflictStrategy: ConflictStrategy.timestamp,
      priority: SyncPriority.normal,
      enableRealtime: false,
      syncInterval: const Duration(minutes: 10),
      batchSize: 25,
    );
  }

  /// Cria uma configuração para entidades complexas/críticas
  factory EntitySyncRegistration.advanced({
    required Type entityType,
    required String collectionName,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
    ConflictStrategy conflictStrategy = ConflictStrategy.version,
    SyncPriority priority = SyncPriority.high,
    IConflictResolver<T>? customResolver,
  }) {
    return EntitySyncRegistration<T>(
      entityType: entityType,
      collectionName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
      conflictStrategy: conflictStrategy,
      priority: priority,
      enableRealtime: true,
      syncInterval: const Duration(minutes: 2),
      batchSize: 100,
      maxRetries: 5,
      customResolver: customResolver,
    );
  }

  @override
  String toString() {
    return 'EntitySyncRegistration<$entityType>(collection: $collectionName, '
           'strategy: $conflictStrategy, priority: $priority)';
  }
}

/// Estratégias de resolução de conflitos expandidas
enum ConflictStrategy {
  /// Usar timestamp mais recente
  timestamp,
  
  /// Usar versão maior
  version,
  
  /// Priorizar versão local
  localWins,
  
  /// Priorizar versão remota
  remoteWins,
  
  /// Resolução manual (requer intervenção do usuário)
  manual,
  
  /// Resolver usando strategy customizada
  custom,
}

/// Prioridades de sincronização
enum SyncPriority {
  /// Baixa prioridade - sync em background quando possível
  low,
  
  /// Prioridade normal - sync regular
  normal,
  
  /// Alta prioridade - sync imediata
  high,
  
  /// Prioridade crítica - sync prioritária sobre outras
  critical,
}

/// Interface para resolvers de conflito customizados
abstract class IConflictResolver<T extends BaseSyncEntity> {
  /// Resolve conflito entre versões local e remota
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion);

  /// Verifica se pode resolver automaticamente
  bool canAutoResolve(T localVersion, T remoteVersion);

  /// Estratégia de resolução
  ConflictStrategy get strategy => ConflictStrategy.custom;
}

/// Registro de entidade com configuração de dependências
class EntitySyncWithDependencies<T extends BaseSyncEntity> extends EntitySyncRegistration<T> {
  const EntitySyncWithDependencies({
    required super.entityType,
    required super.collectionName,
    required super.fromMap,
    required super.toMap,
    super.conflictStrategy,
    super.priority,
    super.batchSize,
    super.enableRealtime,
    super.enableOfflineMode,
    super.syncInterval,
    super.maxRetries,
    super.retryDelay,
    super.customResolver,
    this.dependencies = const [],
    this.dependents = const [],
    this.syncOrder = 0,
  });

  /// Entidades que devem ser sincronizadas antes desta
  final List<Type> dependencies;

  /// Entidades que dependem desta (serão sincronizadas após)
  final List<Type> dependents;

  /// Ordem de sincronização (menor = primeiro)
  final int syncOrder;

  /// Verifica se tem dependências
  bool get hasDependencies => dependencies.isNotEmpty;

  /// Verifica se é uma entidade raiz (sem dependências)
  bool get isRoot => dependencies.isEmpty;

  /// Verifica se é uma entidade folha (sem dependentes)
  bool get isLeaf => dependents.isEmpty;
}

/// Configuração de batch sync para múltiplas entidades relacionadas
class BatchSyncConfiguration {
  const BatchSyncConfiguration({
    required this.entities,
    this.batchSize = 50,
    this.maxConcurrentBatches = 3,
    this.respectDependencies = true,
    this.failOnFirstError = false,
  });

  /// Lista de entidades para sincronizar em lote
  final List<Type> entities;

  /// Tamanho do lote
  final int batchSize;

  /// Máximo de lotes concorrentes
  final int maxConcurrentBatches;

  /// Se deve respeitar dependências entre entidades
  final bool respectDependencies;

  /// Se deve parar no primeiro erro ou continuar
  final bool failOnFirstError;
}

/// Configuração de sync em tempo real para entidades específicas
class RealtimeSyncConfiguration {
  const RealtimeSyncConfiguration({
    required this.entityType,
    this.enableCreate = true,
    this.enableUpdate = true,
    this.enableDelete = true,
    this.debounceMs = 500,
    this.batchUpdates = true,
  });

  /// Tipo da entidade
  final Type entityType;

  /// Se deve sincronizar criações em tempo real
  final bool enableCreate;

  /// Se deve sincronizar atualizações em tempo real
  final bool enableUpdate;

  /// Se deve sincronizar deleções em tempo real
  final bool enableDelete;

  /// Debounce em millisegundos para evitar sync excessivo
  final int debounceMs;

  /// Se deve agrupar múltiplas atualizações em lotes
  final bool batchUpdates;
}

/// Factory para criar registros de entidades com padrões comuns
class EntityRegistrationFactory {
  /// Cria registro para entidade de usuário (alta prioridade, real-time)
  static EntitySyncRegistration<T> userEntity<T extends BaseSyncEntity>({
    required String collectionName,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
  }) {
    return EntitySyncRegistration<T>.advanced(
      entityType: T,
      collectionName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
      conflictStrategy: ConflictStrategy.version,
      priority: SyncPriority.high,
    );
  }

  /// Cria registro para entidade de configuração (crítica, imediata)
  static EntitySyncRegistration<T> configEntity<T extends BaseSyncEntity>({
    required String collectionName,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
  }) {
    return EntitySyncRegistration<T>(
      entityType: T,
      collectionName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
      conflictStrategy: ConflictStrategy.remoteWins, // Config sempre do servidor
      priority: SyncPriority.critical,
      enableRealtime: true,
      syncInterval: const Duration(minutes: 1),
      maxRetries: 5,
    );
  }

  /// Cria registro para entidade de log (low priority, batch)
  static EntitySyncRegistration<T> logEntity<T extends BaseSyncEntity>({
    required String collectionName,
    required T Function(Map<String, dynamic>) fromMap,
    required Map<String, dynamic> Function(T) toMap,
  }) {
    return EntitySyncRegistration<T>(
      entityType: T,
      collectionName: collectionName,
      fromMap: fromMap,
      toMap: toMap,
      conflictStrategy: ConflictStrategy.localWins, // Logs locais têm prioridade
      priority: SyncPriority.low,
      enableRealtime: false,
      syncInterval: const Duration(hours: 1),
      batchSize: 200,
      maxRetries: 1, // Não insistir em logs
    );
  }
}
