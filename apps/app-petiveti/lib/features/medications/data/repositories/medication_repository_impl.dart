import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;
import '../../domain/entities/medication.dart';
import '../../domain/entities/sync/medication_sync_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_datasource.dart';
import '../models/medication_model.dart';
import '../services/medication_error_handling_service.dart';

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
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles data access
/// - **Dependency Inversion**: Depends on abstractions (datasource, services)
/// - **Open/Closed**: Error handling extracted to service
class MedicationRepositoryImpl implements MedicationRepository {
  const MedicationRepositoryImpl(
    this._localDataSource,
    this._errorHandlingService,
  );

  final MedicationLocalDataSource _localDataSource;
  final MedicationErrorHandlingService _errorHandlingService;

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
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
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
      },
      errorMessage: 'Failed to create medication',
      isCache: false,
    );
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getMedications() async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications = await _localDataSource.getMedications();
        final activeMedications = localMedications
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList();
        return activeMedications;
      },
      errorMessage: 'Failed to get medications',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getMedicationsByAnimalId(String animalId) async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications =
            await _localDataSource.getMedicationsByAnimalId(animalId);
        final activeMedications = localMedications
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList();
        return activeMedications;
      },
      errorMessage: 'Failed to get medications by animal',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getActiveMedications() async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications = await _localDataSource.getActiveMedications();
        final medications =
            localMedications.map((model) => model.toEntity()).toList();
        return medications;
      },
      errorMessage: 'Failed to get active medications',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getActiveMedicationsByAnimalId(String animalId) async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications =
            await _localDataSource.getActiveMedicationsByAnimalId(animalId);
        final medications =
            localMedications.map((model) => model.toEntity()).toList();
        return medications;
      },
      errorMessage: 'Failed to get active medications by animal',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>>
      getExpiringSoonMedications() async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications =
            await _localDataSource.getExpiringSoonMedications();
        final medications =
            localMedications.map((model) => model.toEntity()).toList();
        return medications;
      },
      errorMessage: 'Failed to get expiring medications',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, Medication>> getMedicationById(
    String id,
  ) async {
    return _errorHandlingService.executeNullableOperation(
      operation: () async {
        final localMedication = await _localDataSource.getMedicationById(id);

        if (localMedication != null && localMedication.isDeleted) {
          throw Exception('Medication was deleted');
        }

        return localMedication?.toEntity();
      },
      errorMessage: 'Failed to get medication',
      notFoundMessage: 'Medication not found',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>> searchMedications(
    String query,
  ) async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications =
            await _localDataSource.searchMedications(query);
        final medications = localMedications
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList();
        return medications;
      },
      errorMessage: 'Failed to search medications',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, List<Medication>>> getMedicationHistory(
    String animalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final localMedications = await _localDataSource.getMedicationHistory(
          animalId,
          startDate,
          endDate,
        );
        final medications =
            localMedications.map((model) => model.toEntity()).toList();
        return medications;
      },
      errorMessage: 'Failed to get medication history',
      isCache: true,
    );
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> updateMedication(
    Medication medication,
  ) async {
    return _errorHandlingService.executeWithValidation(
      operation: () async {
        // 1. Buscar medication atual para preservar sync fields
        final currentMedication =
            await _localDataSource.getMedicationById(medication.id);
        if (currentMedication == null) {
          throw Exception('Medication not found');
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
      },
      validator: (_) => const Right(null),
      errorMessage: 'Failed to update medication',
      isCache: false,
    );
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> deleteMedication(
      String id) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // Soft delete (datasource já implementa)
        await _localDataSource.deleteMedication(id);

        if (kDebugMode) {
          debugPrint('[MedicationRepository] Medication soft-deleted: $id');
        }

        // Trigger sync para propagar delete
        _triggerBackgroundSync();
      },
      errorMessage: 'Failed to delete medication',
      isCache: false,
    );
  }

  @override
  Future<Either<local_failures.Failure, void>> hardDeleteMedication(
    String id,
  ) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // Hard delete (remover permanentemente)
        await _localDataSource.hardDeleteMedication(id);

        if (kDebugMode) {
          debugPrint('[MedicationRepository] Medication hard-deleted: $id');
        }

        // Trigger sync para propagar delete
        _triggerBackgroundSync();
      },
      errorMessage: 'Failed to hard delete medication',
      isCache: false,
    );
  }

  @override
  Future<Either<local_failures.Failure, void>> discontinueMedication(
    String id,
    String reason,
  ) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // Descontinuar medication (marca como discontinued)
        await _localDataSource.discontinueMedication(id, reason);

        if (kDebugMode) {
          debugPrint(
            '[MedicationRepository] Medication discontinued: $id (reason: $reason)',
          );
        }

        // Trigger sync para propagar mudança
        _triggerBackgroundSync();
      },
      errorMessage: 'Failed to discontinue medication',
      isCache: false,
    );
  }

  // ========================================================================
  // WATCH OPERATIONS
  // ========================================================================

  @override
  Stream<List<Medication>> watchMedications() {
    return _localDataSource.watchMedications().map((models) => models
        .where((model) => !model.isDeleted)
        .map((model) => model.toEntity())
        .toList());
  }

  @override
  Stream<List<Medication>> watchMedicationsByAnimalId(String animalId) {
    return _localDataSource.watchMedicationsByAnimalId(animalId).map((models) =>
        models
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
    return _errorHandlingService.executeOperation(
      operation: () async {
        final medicationModel = MedicationModel.fromEntity(medication);
        final conflictModels =
            await _localDataSource.checkMedicationConflicts(medicationModel);
        final conflicts =
            conflictModels.map((model) => model.toEntity()).toList();
        return conflicts;
      },
      errorMessage: 'Failed to check medication conflicts',
      isCache: true,
    );
  }

  // ========================================================================
  // STATISTICS
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, int>> getActiveMedicationsCount(
    String animalId,
  ) async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final count =
            await _localDataSource.getActiveMedicationsCount(animalId);
        return count;
      },
      errorMessage: 'Failed to count active medications',
      isCache: true,
    );
  }

  // ========================================================================
  // EXPORT/IMPORT
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Map<String, dynamic>>>>
      exportMedicationsData() async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        final medicationModels = await _localDataSource.getMedications();
        final data = medicationModels.map((model) => model.toJson()).toList();
        return data;
      },
      errorMessage: 'Failed to export medications data',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, void>> importMedicationsData(
    List<Map<String, dynamic>> data,
  ) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
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
      },
      errorMessage: 'Failed to import medications data',
      isCache: true,
    );
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
