import 'dart:math';

import '../data/models/base_sync_model.dart';
import '../../features/fuel/data/models/fuel_supply_model.dart';
import '../../features/maintenance/data/models/maintenance_model.dart';
import '../../features/vehicles/data/models/vehicle_model.dart';

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
  final T? localEntity;
  final T? remoteEntity;
  final T? mergedEntity;
  final ConflictAction action;

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

/// Resolver para VehicleModel (version-based + custom merge)
class VehicleConflictResolver implements ConflictResolver<VehicleModel> {
  @override
  ConflictResolution<VehicleModel> resolve(
    VehicleModel local,
    VehicleModel remote,
  ) {
    // Version-based comparison first
    if (remote.version > local.version) {
      return ConflictResolution.useRemote(remote);
    } else if (local.version > remote.version) {
      return ConflictResolution.useLocal(local);
    }

    // Versions iguais mas dados diferentes → custom merge
    final merged = _mergeVehicles(local, remote);
    return ConflictResolution.useMerged(merged);
  }

  /// Custom merge para VehicleModel
  /// Prioriza: dados mais recentes (updatedAt) e valores máximos (odometro)
  VehicleModel _mergeVehicles(VehicleModel local, VehicleModel remote) {
    final localUpdatedAt = local.updatedAt ?? DateTime(1970);
    final remoteUpdatedAt = remote.updatedAt ?? DateTime(1970);
    final isRemoteNewer = remoteUpdatedAt.isAfter(localUpdatedAt);

    return VehicleModel(
      id: local.id,
      createdAtMs: local.createdAtMs ?? remote.createdAtMs,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      lastSyncAtMs: DateTime.now().millisecondsSinceEpoch,
      isDirty: true,
      isDeleted: local.isDeleted || remote.isDeleted,
      version: local.version + 1, // Incrementa versão após merge
      userId: local.userId ?? remote.userId,
      moduleName: local.moduleName ?? remote.moduleName,
      // Campos específicos: usa mais recente
      marca: isRemoteNewer ? remote.marca : local.marca,
      modelo: isRemoteNewer ? remote.modelo : local.modelo,
      ano: isRemoteNewer ? remote.ano : local.ano,
      placa: isRemoteNewer ? remote.placa : local.placa,
      combustivel: isRemoteNewer ? remote.combustivel : local.combustivel,
      renavan: isRemoteNewer ? remote.renavan : local.renavan,
      chassi: isRemoteNewer ? remote.chassi : local.chassi,
      cor: isRemoteNewer ? remote.cor : local.cor,
      vendido: local.vendido || remote.vendido, // Se um vendeu, considera vendido
      valorVenda: max(local.valorVenda, remote.valorVenda), // Maior valor
      // Odômetro: sempre usa o maior valor (nunca regride)
      odometroInicial: max(local.odometroInicial, remote.odometroInicial),
      odometroAtual: max(local.odometroAtual, remote.odometroAtual),
      // Foto: prefere a mais recente
      foto: isRemoteNewer
          ? (remote.foto ?? local.foto)
          : (local.foto ?? remote.foto),
    );
  }
}

/// Resolver para FuelSupplyModel (last write wins - timestamp-based)
class FuelSupplyConflictResolver
    implements ConflictResolver<FuelSupplyModel> {
  @override
  ConflictResolution<FuelSupplyModel> resolve(
    FuelSupplyModel local,
    FuelSupplyModel remote,
  ) {
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

/// Resolver para MaintenanceModel (last write wins - timestamp-based)
class MaintenanceConflictResolver
    implements ConflictResolver<MaintenanceModel> {
  @override
  ConflictResolution<MaintenanceModel> resolve(
    MaintenanceModel local,
    MaintenanceModel remote,
  ) {
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

/// Factory para obter resolver apropriado baseado no tipo de entidade
class ConflictResolverFactory {
  static ConflictResolver<T>? getResolver<T extends BaseSyncModel>() {
    if (T == VehicleModel) {
      return VehicleConflictResolver() as ConflictResolver<T>;
    } else if (T == FuelSupplyModel) {
      return FuelSupplyConflictResolver() as ConflictResolver<T>;
    } else if (T == MaintenanceModel) {
      return MaintenanceConflictResolver() as ConflictResolver<T>;
    }
    return null;
  }

  static ConflictResolver? getResolverByType(String entityType) {
    switch (entityType) {
      case 'vehicle':
      case 'VehicleModel':
        return VehicleConflictResolver();
      case 'fuel_supply':
      case 'FuelSupplyModel':
        return FuelSupplyConflictResolver();
      case 'maintenance':
      case 'MaintenanceModel':
        return MaintenanceConflictResolver();
      default:
        return null;
    }
  }
}
