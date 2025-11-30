import '../data/models/base_sync_model.dart';

/// Estratégias disponíveis para resolução de conflitos
enum ConflictStrategy {
  /// Timestamp-based: Mantém o registro mais recente
  lastWriteWins,

  /// Version-based: Mantém o registro com versão maior
  versionBased,

  /// Custom merge: Mescla campos específicos de forma inteligente
  customMerge,

  /// Ask user: Delega decisão ao usuário (não implementado ainda)
  askUser,
}

/// Ação tomada após resolução de conflito
enum ConflictAction {
  /// Mantém dados locais
  keepLocal,

  /// Mantém dados remotos
  keepRemote,

  /// Usa versão mesclada (merged)
  useMerged,
}

/// Resultado da resolução de conflito
class ConflictResolution<T> {

  const ConflictResolution._({
    this.localEntity,
    this.remoteEntity,
    this.mergedEntity,
    required this.action,
  });

  factory ConflictResolution.useLocal(T local) {
    return ConflictResolution._(
      localEntity: local,
      action: ConflictAction.keepLocal,
    );
  }

  factory ConflictResolution.useRemote(T remote) {
    return ConflictResolution._(
      remoteEntity: remote,
      action: ConflictAction.keepRemote,
    );
  }

  factory ConflictResolution.useMerged(T merged) {
    return ConflictResolution._(
      mergedEntity: merged,
      action: ConflictAction.useMerged,
    );
  }
  final T? localEntity;
  final T? remoteEntity;
  final T? mergedEntity;
  final ConflictAction action;

  /// Retorna a entidade resolvida (independente da ação)
  T get resolvedEntity {
    switch (action) {
      case ConflictAction.keepLocal:
        return localEntity!;
      case ConflictAction.keepRemote:
        return remoteEntity!;
      case ConflictAction.useMerged:
        return mergedEntity!;
    }
  }
}

/// Interface para resolvers de conflitos
abstract class ConflictResolver<T> {
  ConflictResolution<T> resolve(T local, T remote);
}

/// Resolver genérico baseado em timestamp (last write wins)
class TimestampBasedResolver<T extends BaseSyncModel>
    implements ConflictResolver<T> {
  @override
  ConflictResolution<T> resolve(T local, T remote) {
    final localUpdatedAt = local.updatedAt ?? DateTime(1970);
    final remoteUpdatedAt = remote.updatedAt ?? DateTime(1970);

    // Last Write Wins: timestamp mais recente prevalece
    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      return ConflictResolution.useRemote(remote);
    } else {
      return ConflictResolution.useLocal(local);
    }
  }
}

/// Resolver genérico baseado em versão
class VersionBasedResolver<T extends BaseSyncModel>
    implements ConflictResolver<T> {
  @override
  ConflictResolution<T> resolve(T local, T remote) {
    // Version-based comparison
    if (remote.version > local.version) {
      return ConflictResolution.useRemote(remote);
    } else if (local.version > remote.version) {
      return ConflictResolution.useLocal(local);
    }

    // Versions iguais: fallback para timestamp
    final localUpdatedAt = local.updatedAt ?? DateTime(1970);
    final remoteUpdatedAt = remote.updatedAt ?? DateTime(1970);

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      return ConflictResolution.useRemote(remote);
    } else {
      return ConflictResolution.useLocal(local);
    }
  }
}

/// Factory para obter resolver apropriado baseado na estratégia
class ConflictResolverFactory {
  static ConflictResolver<T> getResolver<T extends BaseSyncModel>({
    ConflictStrategy strategy = ConflictStrategy.lastWriteWins,
  }) {
    switch (strategy) {
      case ConflictStrategy.lastWriteWins:
        return TimestampBasedResolver<T>();
      case ConflictStrategy.versionBased:
        return VersionBasedResolver<T>();
      case ConflictStrategy.customMerge:
      case ConflictStrategy.askUser:
        // Fallback para timestamp-based
        return TimestampBasedResolver<T>();
    }
  }
}
