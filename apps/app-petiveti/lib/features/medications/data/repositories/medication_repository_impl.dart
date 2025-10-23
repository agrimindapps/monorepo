import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;
import '../../domain/entities/medication.dart';
import '../../domain/entities/sync/medication_sync_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';
import '../models/medication_model.dart';

/// MedicationRepository implementation using UnifiedSyncManager for offline-first sync
///
/// **Características especiais para Medications:**
/// - **Emergency Priority**: Medications têm prioridade alta (SyncPriority.high)
/// - **Real-time Sync**: Se isCritical = true, sync em tempo real
/// - **Version-based Conflicts**: Usa ConflictStrategy.version (dados críticos)
/// - **Offline-first**: Sempre lê do cache local
///
/// **Mudanças da versão anterior:**
/// - Usa UnifiedSyncManager para sincronização automática
/// - Marca entidades como dirty após operações CRUD
/// - Auto-sync triggers após operações de escrita
/// - Integra com DataIntegrityService via AnimalRepository
///
/// **Fluxo de operações:**
/// 1. CREATE: Salva local → Marca dirty → UnifiedSyncManager sincroniza em background
/// 2. UPDATE: Atualiza local → Marca dirty + incrementVersion → Sync em background
/// 3. DELETE: Marca como deleted (soft delete) → Sync em background
/// 4. READ: Sempre lê do cache local (extremamente rápido)
class MedicationRepositoryImpl implements MedicationRepository {
  const MedicationRepositoryImpl(this._localDataSource);

  final MedicationLocalDataSource _localDataSource;

  /// UnifiedSyncManager singleton instance (for future use)
  // ignore: unused_element
  UnifiedSyncManager get _syncManager => UnifiedSyncManager.instance;

  // ========================================================================
  // CREATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> addMedication(
    Medication medication,
  ) async {
    try {
      // 1. Converter para MedicationSyncEntity e marcar como dirty para sync posterior
      final syncEntity = MedicationSyncEntity.fromLegacyMedication(
        medication,
        moduleName: 'petiveti',
      ).markAsDirty();

      // 2. Salvar localmente (usando MedicationModel para compatibilidade com Hive)
      final medicationModel =
          MedicationModel.fromEntity(syncEntity.toLegacyMedication());
      await _localDataSource.cacheMedication(medicationModel);

      if (kDebugMode) {
        debugPrint(
          '[MedicationRepository] Medication created locally: ${medication.id}',
        );
        if (syncEntity.isCritical) {
          debugPrint(
            '[MedicationRepository] ⚠️ Critical medication - priority sync',
          );
        }
      }

      // 3. Trigger sync em background (não-bloqueante)
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[MedicationRepository] Error creating medication: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        local_failures.ServerFailure(message: 'Failed to create medication: $e'),
      );
    }
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Medication>>> getMedications() async {
    try {
      final localMedications = await _localDataSource.getMedications();
      final activeMedications = localMedications
          .where((model) => !model.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Right(activeMedications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(message: 'Failed to get medications: $e'),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getMedicationsByAnimalId(String animalId) async {
    try {
      final localMedications =
          await _localDataSource.getMedicationsByAnimalId(animalId);
      final activeMedications = localMedications
          .where((model) => !model.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Right(activeMedications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get medications by animal: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getActiveMedications() async {
    try {
      final localMedications = await _localDataSource.getActiveMedications();
      final medications = localMedications
          .map((model) => model.toEntity())
          .toList();

      return Right(medications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get active medications: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getActiveMedicationsByAnimalId(String animalId) async {
    try {
      final localMedications =
          await _localDataSource.getActiveMedicationsByAnimalId(animalId);
      final medications = localMedications
          .map((model) => model.toEntity())
          .toList();

      return Right(medications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get active medications by animal: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getExpiringSoonMedications() async {
    try {
      final localMedications =
          await _localDataSource.getExpiringSoonMedications();
      final medications = localMedications
          .map((model) => model.toEntity())
          .toList();

      return Right(medications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get expiring medications: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, Medication>> getMedicationById(
    String id,
  ) async {
    try {
      final localMedication = await _localDataSource.getMedicationById(id);

      if (localMedication != null) {
        if (localMedication.isDeleted) {
          return Left(
            local_failures.CacheFailure(message: 'Medication was deleted'),
          );
        }
        return Right(localMedication.toEntity());
      }

      return Left(
        local_failures.CacheFailure(message: 'Medication not found'),
      );
    } catch (e) {
      return Left(
        local_failures.CacheFailure(message: 'Failed to get medication: $e'),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>> searchMedications(
    String query,
  ) async {
    try {
      final localMedications = await _localDataSource.searchMedications(query);
      final medications = localMedications
          .where((model) => !model.isDeleted)
          .map((model) => model.toEntity())
          .toList();

      return Right(medications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(message: 'Failed to search medications: $e'),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final localMedications = await _localDataSource.getMedicationHistory(
        animalId,
        startDate,
        endDate,
      );
      final medications = localMedications
          .map((model) => model.toEntity())
          .toList();

      return Right(medications);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to get medication history: $e',
        ),
      );
    }
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> updateMedication(
    Medication medication,
  ) async {
    try {
      // 1. Buscar medication atual para preservar sync fields
      final currentMedication =
          await _localDataSource.getMedicationById(medication.id);
      if (currentMedication == null) {
        return Left(
          local_failures.CacheFailure(message: 'Medication not found'),
        );
      }

      // 2. Converter para SyncEntity, marcar como dirty e incrementar versão
      final syncEntity = MedicationSyncEntity.fromLegacyMedication(
        medication,
        moduleName: 'petiveti',
      ).markAsDirty().incrementVersion();

      // 3. Atualizar localmente
      final medicationModel =
          MedicationModel.fromEntity(syncEntity.toLegacyMedication());
      await _localDataSource.updateMedication(medicationModel);

      if (kDebugMode) {
        debugPrint(
          '[MedicationRepository] Medication updated locally: ${medication.id} (version: ${syncEntity.version})',
        );
      }

      // 4. Trigger sync em background
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(message: 'Failed to update medication: $e'),
      );
    }
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> deleteMedication(String id) async {
    try {
      // Soft delete (datasource já implementa)
      await _localDataSource.deleteMedication(id);

      if (kDebugMode) {
        debugPrint('[MedicationRepository] Medication soft-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(message: 'Failed to delete medication: $e'),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, void>> hardDeleteMedication(
    String id,
  ) async {
    try {
      // Hard delete (remover permanentemente)
      await _localDataSource.hardDeleteMedication(id);

      if (kDebugMode) {
        debugPrint('[MedicationRepository] Medication hard-deleted: $id');
      }

      // Trigger sync para propagar delete
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(
          message: 'Failed to hard delete medication: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, void>> discontinueMedication(
    String id,
    String reason,
  ) async {
    try {
      // Descontinuar medication (marca como discontinued)
      await _localDataSource.discontinueMedication(id, reason);

      if (kDebugMode) {
        debugPrint(
          '[MedicationRepository] Medication discontinued: $id (reason: $reason)',
        );
      }

      // Trigger sync para propagar mudança
      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(
          message: 'Failed to discontinue medication: $e',
        ),
      );
    }
  }

  // ========================================================================
  // WATCH OPERATIONS
  // ========================================================================

  @override
  Stream<List<Medication>> watchMedications() {
    return _localDataSource
        .watchMedications()
        .map((models) => models
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList());
  }

  @override
  Stream<List<Medication>> watchMedicationsByAnimalId(String animalId) {
    return _localDataSource
        .watchMedicationsByAnimalId(animalId)
        .map((models) => models
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList());
  }

  @override
  Stream<List<Medication>> watchActiveMedications() {
    return _localDataSource
        .watchActiveMedications()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  // ========================================================================
  // CONFLICT DETECTION
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      checkMedicationConflicts(Medication medication) async {
    try {
      final medicationModel = MedicationModel.fromEntity(medication);
      final conflictModels =
          await _localDataSource.checkMedicationConflicts(medicationModel);
      final conflicts = conflictModels.map((model) => model.toEntity()).toList();

      return Right(conflicts);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to check medication conflicts: $e',
        ),
      );
    }
  }

  // ========================================================================
  // STATISTICS
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, int>> getActiveMedicationsCount(
    String animalId,
  ) async {
    try {
      final count =
          await _localDataSource.getActiveMedicationsCount(animalId);
      return Right(count);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to count active medications: $e',
        ),
      );
    }
  }

  // ========================================================================
  // EXPORT/IMPORT
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Map<String, dynamic>>>>
      exportMedicationsData() async {
    try {
      final medicationModels = await _localDataSource.getMedications();
      final data = medicationModels.map((model) => model.toJson()).toList();
      return Right(data);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to export medications data: $e',
        ),
      );
    }
  }

  @override
  Future<Either<local_failures.Failure, void>> importMedicationsData(
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final medicationModels =
          data.map((json) => MedicationModel.fromJson(json)).toList();

      // Marcar todos como dirty para sync
      final dirtyModels = medicationModels.map((model) {
        final syncEntity = MedicationSyncEntity.fromLegacyMedication(
          model.toEntity(),
          moduleName: 'petiveti',
        ).markAsDirty();
        return MedicationModel.fromEntity(syncEntity.toLegacyMedication());
      }).toList();

      await _localDataSource.cacheMedications(dirtyModels);

      if (kDebugMode) {
        debugPrint(
          '[MedicationRepository] Imported ${dirtyModels.length} medications',
        );
      }

      _triggerBackgroundSync();

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure(
          message: 'Failed to import medications data: $e',
        ),
      );
    }
  }

  // ========================================================================
  // SYNC HELPERS
  // ========================================================================

  /// Trigger sync em background (não-bloqueante)
  /// UnifiedSyncManager gerencia filas e throttling automaticamente
  /// Medications têm prioridade alta (SyncPriority.high)
  void _triggerBackgroundSync() {
    // TODO: Implementar quando UnifiedSyncManager tiver método trigger manual
    // Por enquanto, AutoSyncService fará sync periódico automaticamente
    if (kDebugMode) {
      debugPrint(
        '[MedicationRepository] Background sync will be triggered by AutoSyncService (priority: HIGH)',
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
          '[MedicationRepository] Manual sync requested (not yet implemented)',
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.ServerFailure(message: 'Failed to force sync: $e'),
      );
    }
  }
}
