import 'package:dartz/dartz.dart';

import '../../domain/entities/base_sync_entity.dart';
import '../../shared/utils/failure.dart';
import '../entity_sync_registration.dart';

/// Factory para criar resolvers de conflito baseado na estratégia configurada
class ConflictResolverFactory {
  static final Map<ConflictStrategy, IConflictResolver> _defaultResolvers = {
    ConflictStrategy.timestamp: TimestampConflictResolver(),
    ConflictStrategy.version: VersionConflictResolver(),
    ConflictStrategy.localWins: LocalWinsConflictResolver(),
    ConflictStrategy.remoteWins: RemoteWinsConflictResolver(),
    ConflictStrategy.manual: ManualConflictResolver(),
  };

  static final Map<Type, IConflictResolver> _customResolvers = {};

  /// Obtém resolver para uma estratégia específica
  static IConflictResolver<T> getResolver<T extends BaseSyncEntity>(
    ConflictStrategy strategy, {
    IConflictResolver<T>? customResolver,
  }) {
    if (strategy == ConflictStrategy.custom && customResolver != null) {
      return customResolver;
    }

    final resolver = _customResolvers[T] ?? _defaultResolvers[strategy];
    if (resolver == null) {
      throw ArgumentError('No resolver found for strategy: $strategy');
    }

    return resolver as IConflictResolver<T>;
  }

  /// Registra resolver customizado para um tipo específico
  static void registerCustomResolver<T extends BaseSyncEntity>(
    IConflictResolver<T> resolver,
  ) {
    _customResolvers[T] = resolver;
  }

  /// Remove resolver customizado
  static void unregisterCustomResolver<T extends BaseSyncEntity>() {
    _customResolvers.remove(T);
  }

  /// Lista todos os resolvers registrados
  static Map<String, String> listResolvers() {
    final result = <String, String>{};
    
    for (final entry in _defaultResolvers.entries) {
      result['${entry.key.name}_default'] = entry.value.runtimeType.toString();
    }
    
    for (final entry in _customResolvers.entries) {
      result['${entry.key.toString()}_custom'] = entry.value.runtimeType.toString();
    }
    
    return result;
  }
}

/// Resolver baseado em timestamp - usa data mais recente
class TimestampConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    try {
      final localTimestamp = localVersion.updatedAt ?? localVersion.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final remoteTimestamp = remoteVersion.updatedAt ?? remoteVersion.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      
      final result = localTimestamp.isAfter(remoteTimestamp) ? localVersion : remoteVersion;
      return Right(result.incrementVersion() as T);
    } catch (e) {
      return Left(SyncFailure('Timestamp conflict resolution failed: $e'));
    }
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) => true;

  @override
  ConflictStrategy get strategy => ConflictStrategy.timestamp;
}

/// Resolver baseado em versão - usa versão maior
class VersionConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    try {
      if (localVersion.version == remoteVersion.version) {
        return await TimestampConflictResolver<T>().resolveConflict(localVersion, remoteVersion);
      }
      
      final result = localVersion.version > remoteVersion.version ? localVersion : remoteVersion;
      return Right(result.incrementVersion() as T);
    } catch (e) {
      return Left(SyncFailure('Version conflict resolution failed: $e'));
    }
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) => true;

  @override
  ConflictStrategy get strategy => ConflictStrategy.version;
}

/// Resolver que sempre prioriza versão local
class LocalWinsConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    try {
      return Right(localVersion.incrementVersion() as T);
    } catch (e) {
      return Left(SyncFailure('Local wins conflict resolution failed: $e'));
    }
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) => true;

  @override
  ConflictStrategy get strategy => ConflictStrategy.localWins;
}

/// Resolver que sempre prioriza versão remota
class RemoteWinsConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    try {
      return Right(remoteVersion.incrementVersion() as T);
    } catch (e) {
      return Left(SyncFailure('Remote wins conflict resolution failed: $e'));
    }
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) => true;

  @override
  ConflictStrategy get strategy => ConflictStrategy.remoteWins;
}

/// Resolver que requer intervenção manual
class ManualConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    return Left(ConflictResolutionFailure(
      'Manual conflict resolution required for ${T.toString()} with ID: ${localVersion.id}',
      localVersion,
      remoteVersion,
    ));
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) => false;

  @override
  ConflictStrategy get strategy => ConflictStrategy.manual;
}

/// Resolver inteligente que tenta múltiplas estratégias
class SmartConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  const SmartConflictResolver({
    this.strategies = const [
      ConflictStrategy.version,
      ConflictStrategy.timestamp,
    ],
  });

  final List<ConflictStrategy> strategies;

  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    for (final strategy in strategies) {
      try {
        final resolver = ConflictResolverFactory.getResolver<T>(strategy);
        if (resolver.canAutoResolve(localVersion, remoteVersion)) {
          return await resolver.resolveConflict(localVersion, remoteVersion);
        }
      } catch (e) {
        continue;
      }
    }
    return Left(ConflictResolutionFailure(
      'Smart resolver could not resolve conflict automatically',
      localVersion,
      remoteVersion,
    ));
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) {
    return strategies.any((strategy) {
      try {
        final resolver = ConflictResolverFactory.getResolver<T>(strategy);
        return resolver.canAutoResolve(localVersion, remoteVersion);
      } catch (e) {
        return false;
      }
    });
  }

  @override
  ConflictStrategy get strategy => ConflictStrategy.custom;
}

/// Resolver baseado em prioridade de campos
class FieldPriorityConflictResolver<T extends BaseSyncEntity> implements IConflictResolver<T> {
  const FieldPriorityConflictResolver({
    required this.fieldMergeRules,
    this.fallbackStrategy = ConflictStrategy.timestamp,
  });

  /// Regras de merge por campo
  final Map<String, FieldMergeRule> fieldMergeRules;

  /// Estratégia de fallback para campos não especificados
  final ConflictStrategy fallbackStrategy;

  @override
  Future<Either<Failure, T>> resolveConflict(T localVersion, T remoteVersion) async {
    try {
      final fallbackResolver = ConflictResolverFactory.getResolver<T>(fallbackStrategy);
      return await fallbackResolver.resolveConflict(localVersion, remoteVersion);
    } catch (e) {
      return Left(SyncFailure('Field priority conflict resolution failed: $e'));
    }
  }

  @override
  bool canAutoResolve(T localVersion, T remoteVersion) => true;

  @override
  ConflictStrategy get strategy => ConflictStrategy.custom;
}

/// Regras de merge para campos específicos
enum FieldMergeRule {
  /// Usar valor local
  useLocal,
  
  /// Usar valor remoto
  useRemote,
  
  /// Usar valor mais recente baseado em timestamp
  useNewest,
  
  /// Usar valor maior (para números)
  useGreater,
  
  /// Usar valor menor (para números)
  useSmaller,
  
  /// Concatenar valores (para strings/arrays)
  concatenate,
  
  /// Fazer merge inteligente (para objetos complexos)
  smartMerge,
}

/// Resultado de resolução de conflito com detalhes
class ConflictResolutionResult<T extends BaseSyncEntity> {
  const ConflictResolutionResult({
    required this.resolvedEntity,
    required this.strategy,
    this.wasAutoResolved = true,
    this.details,
    this.appliedRules = const [],
  });

  /// Entidade após resolução do conflito
  final T resolvedEntity;

  /// Estratégia usada para resolver
  final ConflictStrategy strategy;

  /// Se foi resolvido automaticamente
  final bool wasAutoResolved;

  /// Detalhes da resolução
  final String? details;

  /// Regras aplicadas durante a resolução
  final List<String> appliedRules;

  @override
  String toString() {
    return 'ConflictResolutionResult(strategy: $strategy, auto: $wasAutoResolved, '
           'rules: ${appliedRules.length})';
  }
}

/// Falha específica de sincronização
class SyncFailure extends Failure {
  const SyncFailure(String message) : super(message: message);
}

/// Falha específica de resolução de conflito
class ConflictResolutionFailure extends Failure {
  const ConflictResolutionFailure(
    String message,
    this.localVersion,
    this.remoteVersion,
  ) : super(message: message);

  final BaseSyncEntity localVersion;
  final BaseSyncEntity remoteVersion;

  @override
  String toString() {
    return 'ConflictResolutionFailure: $message\n'
           'Local: ${localVersion.id} (v${localVersion.version})\n'
           'Remote: ${remoteVersion.id} (v${remoteVersion.version})';
  }
}