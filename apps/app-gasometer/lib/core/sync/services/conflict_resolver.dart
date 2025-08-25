import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/base_sync_model.dart';
import '../interfaces/i_conflict_resolver.dart';
import '../models/conflict_data.dart';
import '../strategies/conflict_resolution_strategy.dart';

class ConflictResolver<T extends BaseSyncModel> implements IConflictResolver<T> {
  
  @override
  T resolveConflict(
    ConflictData<T> conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) {
    debugPrint('🔀 Resolvendo conflito: ${conflictData.modelType} (${strategy.displayName})');

    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return conflictData.localData;
        
      case ConflictResolutionStrategy.remoteWins:
        return conflictData.remoteData;
        
      case ConflictResolutionStrategy.newerWins:
        return _resolveNewerWins(conflictData);
        
      case ConflictResolutionStrategy.versionWins:
        return _resolveVersionWins(conflictData);
        
      case ConflictResolutionStrategy.merge:
        return mergeEntities(conflictData.localData, conflictData.remoteData);
        
      case ConflictResolutionStrategy.custom:
        return _resolveCustom(conflictData);
        
      case ConflictResolutionStrategy.manual:
        throw UnimplementedError('Resolução manual ainda não implementada');
    }
  }

  @override
  T mergeEntities(T localEntity, T remoteEntity) {
    debugPrint('🔀 Merging entities: ${localEntity.runtimeType}');
    
    // Por enquanto, usa merge genérico
    // TODO: Implementar merge específico por tipo quando os models estiverem disponíveis
    return _mergeGeneric(localEntity, remoteEntity);
  }

  @override
  bool hasConflict(T localEntity, T remoteEntity) {
    // Verifica se há conflito baseado em timestamp e versão
    final localTimestamp = localEntity.updatedAt ?? localEntity.createdAt ?? DateTime.now();
    final remoteTimestamp = remoteEntity.updatedAt ?? remoteEntity.createdAt ?? DateTime.now();
    
    // Considera conflito se:
    // 1. Timestamps são diferentes E
    // 2. Versões são diferentes E  
    // 3. Diferença de timestamp é pequena (menos de 5 minutos)
    final timestampDiff = localTimestamp.difference(remoteTimestamp).abs();
    final hasTimestampConflict = timestampDiff.inMinutes < 5 && timestampDiff.inSeconds > 0;
    final hasVersionConflict = localEntity.version != remoteEntity.version;
    
    return hasTimestampConflict && hasVersionConflict;
  }

  @override
  ConflictData<T> getConflictData(T localEntity, T remoteEntity) {
    return ConflictData.fromEntities(
      localEntity,
      remoteEntity,
      conflictingFields: _getConflictingFields(localEntity, remoteEntity),
    );
  }

  // Métodos privados de resolução

  T _resolveNewerWins(ConflictData<T> conflictData) {
    if (conflictData.isLocalNewer) {
      debugPrint('📅 Local é mais recente, mantendo dados locais');
      return conflictData.localData;
    } else {
      debugPrint('📅 Remoto é mais recente, usando dados remotos');
      return conflictData.remoteData;
    }
  }

  T _resolveVersionWins(ConflictData<T> conflictData) {
    if (conflictData.isLocalVersionHigher) {
      debugPrint('🔢 Versão local é maior, mantendo dados locais');
      return conflictData.localData;
    } else {
      debugPrint('🔢 Versão remota é maior, usando dados remotos');
      return conflictData.remoteData;
    }
  }

  T _resolveCustom(ConflictData<T> conflictData) {
    // Lógica personalizada por tipo de modelo
    final modelType = conflictData.modelType;
    
    switch (modelType) {
      case 'VehicleModel':
        // Para veículos, prioriza dados com mais informações completas
        return _resolveVersionWins(conflictData);
      case 'FuelSupplyModel':
        // Para abastecimentos, prioriza o mais recente sempre
        return _resolveNewerWins(conflictData);
      case 'MaintenanceModel':
        // Para manutenções, merge inteligente
        return mergeEntities(conflictData.localData, conflictData.remoteData);
      default:
        // Fallback para newer wins
        return _resolveNewerWins(conflictData);
    }
  }

  T _mergeGeneric(T localEntity, T remoteEntity) {
    // Merge genérico - prefere dados locais mais recentes
    final localTimestamp = localEntity.updatedAt ?? localEntity.createdAt ?? DateTime.now();
    final remoteTimestamp = remoteEntity.updatedAt ?? remoteEntity.createdAt ?? DateTime.now();
    
    if (localTimestamp.isAfter(remoteTimestamp)) {
      return localEntity.copyWith(
        version: localEntity.version + 1,
        isDirty: true,
        lastSyncAt: DateTime.now(),
      ) as T;
    } else {
      return remoteEntity.copyWith(
        version: remoteEntity.version + 1,
        isDirty: true,
        lastSyncAt: DateTime.now(),
      ) as T;
    }
  }

  List<String> _getConflictingFields(T localEntity, T remoteEntity) {
    // Por simplicidade, retorna lista vazia
    // Em uma implementação real, compararia campo por campo
    return [];
  }
}

/// ConflictResolver específico para BaseSyncModel
@Named('BaseSyncModelConflictResolver')
@injectable
class BaseSyncModelConflictResolver extends ConflictResolver<BaseSyncModel> {}