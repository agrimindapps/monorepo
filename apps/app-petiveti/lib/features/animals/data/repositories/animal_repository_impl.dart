import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;
import '../../../../core/services/data_integrity_service.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/sync/animal_sync_entity.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_datasource.dart';
import '../models/animal_model.dart';

/// AnimalRepository implementation using UnifiedSyncManager for offline-first sync
///
/// **Mudanças da versão anterior:**
/// - Usa UnifiedSyncManager para sincronização automática
/// - Marca entidades como dirty após operações CRUD
/// - Integra DataIntegrityService para ID reconciliation
/// - Simplifica lógica (sem dual remote/local datasource)
/// - Auto-sync triggers após operações de escrita
///
/// **Fluxo de operações:**
/// 1. CREATE: Salva local → Marca dirty → UnifiedSyncManager sincroniza em background
/// 2. UPDATE: Atualiza local → Marca dirty → Sync em background
/// 3. DELETE: Marca como deleted (soft delete) → Sync em background
/// 4. READ: Sempre lê do cache local (extremamente rápido)
class AnimalRepositoryImpl implements AnimalRepository {
  const AnimalRepositoryImpl(
    this._localDataSource,
    this._dataIntegrityService,
  );

  final AnimalLocalDataSource _localDataSource;
  final DataIntegrityService _dataIntegrityService;

  /// UnifiedSyncManager singleton instance (for future use)
  // ignore: unused_element
  UnifiedSyncManager get _syncManager => UnifiedSyncManager.instance;

  // ========================================================================
  // CREATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> addAnimal(Animal animal) async {
    try {
      // 1. Converter para AnimalSyncEntity e marcar como dirty para sync posterior
      final syncEntity = AnimalSyncEntity.fromLegacyAnimal(
        animal,
        moduleName: 'petiveti',
      ).markAsDirty();

      // 2. Salvar localmente (usando AnimalModel para compatibilidade com Hive)
      final animalModel = AnimalModel.fromEntity(syncEntity.toLegacyAnimal());
      await _localDataSource.addAnimal(animalModel);

      if (kDebugMode) {
        debugPrint('[AnimalRepository] Animal created locally: ${animal.id}');
      }

      // 3. Trigger sync em background (não-bloqueante)
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[AnimalRepository] Error creating animal: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(local_failures.ServerFailure(message: 'Failed to create animal: $e'));
    }
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Animal>>> getAnimals() async {
    try {
      // Sempre lê do cache local (rápido)
      final localAnimals = await _localDataSource.getAnimals();

      // Filtrar animals deletados (isActive = false)
      final activeAnimals = localAnimals
          .where((model) => !model.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Right(activeAnimals);
    } catch (e) {
      return Left(local_failures.CacheFailure(message: 'Failed to get animals: $e'));
    }
  }

  @override
  Future<Either<local_failures.Failure, Animal?>> getAnimalById(String id) async {
    try {
      // Sempre lê do cache local (rápido)
      final localAnimal = await _localDataSource.getAnimalById(id);

      if (localAnimal != null) {
        // Filtrar se deletado
        if (localAnimal.isDeleted) {
          return Left(local_failures.CacheFailure(message: 'Animal was deleted'));
        }
        return Right(localAnimal.toEntity());
      }

      return Left(local_failures.CacheFailure(message: 'Animal not found'));
    } catch (e) {
      return Left(local_failures.CacheFailure(message: 'Failed to get animal: $e'));
    }
  }

  @override
  Stream<List<Animal>> watchAnimals() {
    // Watch do cache local (reactive)
    return _localDataSource
        .watchAnimals()
        .map((models) => models
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList());
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> updateAnimal(Animal animal) async {
    try {
      // 1. Buscar animal atual para preservar sync fields
      final currentAnimal = await _localDataSource.getAnimalById(animal.id);
      if (currentAnimal == null) {
        return Left(local_failures.CacheFailure(message: 'Animal not found'));
      }

      // 2. Converter para SyncEntity e marcar como dirty
      final syncEntity = AnimalSyncEntity.fromLegacyAnimal(
        animal,
        moduleName: 'petiveti',
      ).markAsDirty().incrementVersion();

      // 3. Atualizar localmente
      final animalModel = AnimalModel.fromEntity(syncEntity.toLegacyAnimal());
      await _localDataSource.updateAnimal(animalModel);

      if (kDebugMode) {
        debugPrint('[AnimalRepository] Animal updated locally: ${animal.id}');
      }

      // 4. Trigger sync em background
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(message: 'Failed to update animal: $e'));
    }
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> deleteAnimal(String id) async {
    try {
      final localAnimal = await _localDataSource.getAnimalById(id);
      if (localAnimal == null) {
        return Left(local_failures.CacheFailure(message: 'Animal not found'));
      }

      // Soft delete: marcar como deleted (isActive = false)
      // O datasource já implementa isso via copyWith(isActive: false)
      await _localDataSource.deleteAnimal(id);

      if (kDebugMode) {
        debugPrint('[AnimalRepository] Animal soft-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(message: 'Failed to delete animal: $e'));
    }
  }

  // ========================================================================
  // SYNC (DEPRECATED - UnifiedSyncManager handles this)
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> syncAnimals() async {
    // Este método é mantido para compatibilidade mas será removido
    // UnifiedSyncManager gerencia sync automaticamente
    if (kDebugMode) {
      debugPrint(
        '[AnimalRepository] syncAnimals() is deprecated - UnifiedSyncManager handles sync automatically',
      );
    }

    // Pode chamar forceSync() se necessário
    return await forceSync();
  }

  // ========================================================================
  // SYNC HELPERS
  // ========================================================================

  /// Trigger sync em background (não-bloqueante)
  /// UnifiedSyncManager gerencia filas e throttling automaticamente
  void _triggerBackgroundSync() {
    // TODO: Implementar quando UnifiedSyncManager tiver método trigger manual
    // Por enquanto, AutoSyncService fará sync periódico automaticamente
    if (kDebugMode) {
      debugPrint(
        '[AnimalRepository] Background sync will be triggered by AutoSyncService',
      );
    }
  }

  /// Force sync manual (bloqueante) - para uso em casos específicos
  Future<Either<local_failures.Failure, void>> forceSync() async {
    try {
      // TODO: Implementar quando UnifiedSyncManager tiver método forceSync
      // await _syncManager.forceSyncApp('petiveti');

      if (kDebugMode) {
        debugPrint(
          '[AnimalRepository] Manual sync requested (not yet implemented)',
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(message: 'Failed to force sync: $e'));
    }
  }

  /// Verifica integridade dos dados (útil após sync)
  Future<Either<local_failures.Failure, IntegrityReport>> verifyIntegrity() async {
    return _dataIntegrityService.verifyAnimalIntegrity();
  }
}
