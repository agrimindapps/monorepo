import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart' as local_failures;
import '../../domain/entities/animal.dart';
import '../../domain/entities/sync/animal_sync_entity.dart';
import '../../domain/repositories/animal_repository.dart';
import '../../domain/repositories/isync_manager.dart';
import '../datasources/animal_local_datasource.dart';
import '../models/animal_model.dart';
import '../services/animal_error_handling_service.dart';

/// AnimalRepository implementation - Responsabilidades ÚNICAS (SRP):
/// 1. Orquestrar operações CRUD entre datasource e entities
/// 2. Traduzir resultados para Either<Failure, T> (pattern funcional)
/// 3. Delegar sincronização para ISyncManager (DIP)
/// 4. Delegar verificação de integridade para DataIntegrityService
///
/// O que NÃO faz:
/// - Gerenciar detalhes de sincronização (responsabilidade do SyncManager)
/// - Acesso direto ao banco de dados (responsabilidade do DataSource)
/// - Transformações de dados complexas (responsabilidade de Adapters)
///
/// **Fluxo de operações:**
/// 1. CREATE: Salva local → Marca dirty → ISyncManager sincroniza em background
/// 2. UPDATE: Atualiza local → Marca dirty → ISyncManager sincroniza
/// 3. DELETE: Marca como deletado (soft delete) → ISyncManager sincroniza
/// 4. READ: Lê do cache local (rápido) via DataSource
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles data access orchestration
/// - **Dependency Inversion**: Depends on abstractions (datasource, sync manager, error service)
/// - **Open/Closed**: Error handling extracted to service
class AnimalRepositoryImpl implements AnimalRepository {
  AnimalRepositoryImpl(
    this._localDataSource,
    this._syncManager,
    this._errorHandlingService,
  );

  final AnimalLocalDataSource _localDataSource;
  final ISyncManager _syncManager;
  final AnimalErrorHandlingService _errorHandlingService;

  /// Get current user ID from Firebase Auth
  /// Returns 'default-user' if no user is authenticated
  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? 'default-user';
  }

  // ========================================================================
  // CREATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> addAnimal(Animal animal) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // 1. Converter para AnimalSyncEntity e marcar como dirty para sync posterior
        final syncEntity = AnimalSyncEntity.fromLegacyAnimal(
          animal,
          moduleName: 'petiveti',
        ).markAsDirty();

        // 2. Salvar localmente (usando AnimalModel para compatibilidade)
        final animalModel = AnimalModel.fromEntity(syncEntity.toLegacyAnimal());
        await _localDataSource.addAnimal(animalModel);

        if (kDebugMode) {
          debugPrint('[AnimalRepository] Animal created locally: ${animal.id}');
        }

        // 3. Trigger sync em background (não-bloqueante)
        // Delegado para ISyncManager - responsabilidade separada
        _syncManager.triggerBackgroundSync('petiveti').ignore();
      },
      errorMessage: 'Failed to create animal',
      isCache: false,
    );
  }

  // ========================================================================
  // READ
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, List<Animal>>> getAnimals() async {
    return _errorHandlingService.executeOperation(
      operation: () async {
        // Sempre lê do cache local (rápido)
        final localAnimals = await _localDataSource.getAnimals(_userId);

        // Filtrar animals deletados (isActive = false)
        final activeAnimals = localAnimals
            .where((model) => !model.isDeleted)
            .map((model) => model.toEntity())
            .toList();

        return activeAnimals;
      },
      errorMessage: 'Failed to get animals',
      isCache: true,
    );
  }

  @override
  Future<Either<local_failures.Failure, Animal?>> getAnimalById(
      String id) async {
    return _errorHandlingService.executeWithValidation(
      operation: () async {
        // Convert String ID to int for datasource
        final intId = int.tryParse(id);
        if (intId == null) {
          throw Exception('Invalid animal ID format');
        }
        
        // Sempre lê do cache local (rápido)
        final localAnimal = await _localDataSource.getAnimalById(intId);

        if (localAnimal != null && localAnimal.isDeleted) {
          throw Exception('Animal was deleted');
        }

        return localAnimal?.toEntity();
      },
      validator: (animal) {
        if (animal == null) {
          return const Left(
            local_failures.CacheFailure(message: 'Animal not found'),
          );
        }
        return const Right(null);
      },
      errorMessage: 'Failed to get animal',
      isCache: true,
    );
  }

  @override
  Stream<List<Animal>> watchAnimals() {
    // Watch do cache local (reactive)
    return _localDataSource.watchAnimals(_userId).map((models) => models
        .where((model) => !model.isDeleted)
        .map((model) => model.toEntity())
        .toList());
  }

  // ========================================================================
  // UPDATE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> updateAnimal(
      Animal animal) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // Convert String ID to int for datasource
        final intId = int.tryParse(animal.id);
        if (intId == null) {
          throw Exception('Invalid animal ID format');
        }
        
        // 1. Buscar animal atual para preservar sync fields
        final currentAnimal = await _localDataSource.getAnimalById(intId);
        if (currentAnimal == null) {
          throw Exception('Animal not found');
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

        // 4. Trigger sync em background via ISyncManager
        _syncManager.triggerBackgroundSync('petiveti').ignore();
      },
      errorMessage: 'Failed to update animal',
      isCache: false,
    );
  }

  // ========================================================================
  // DELETE
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> deleteAnimal(String id) async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // Convert String ID to int for datasource
        final intId = int.tryParse(id);
        if (intId == null) {
          throw Exception('Invalid animal ID format');
        }
        
        final localAnimal = await _localDataSource.getAnimalById(intId);
        if (localAnimal == null) {
          throw Exception('Animal not found');
        }

        // Soft delete: marcar como deleted (isActive = false)
        // O datasource já implementa isso via copyWith(isActive: false)
        await _localDataSource.deleteAnimal(intId);

        if (kDebugMode) {
          debugPrint('[AnimalRepository] Animal soft-deleted: $id');
        }

        // Trigger sync para propagar delete via ISyncManager
        _syncManager.triggerBackgroundSync('petiveti').ignore();
      },
      errorMessage: 'Failed to delete animal',
      isCache: false,
    );
  }

  // ========================================================================
  // SYNC (DEPRECATED - UnifiedSyncManager handles this)
  // ========================================================================

  @override
  Future<Either<local_failures.Failure, void>> syncAnimals() async {
    return _errorHandlingService.executeVoidOperation(
      operation: () async {
        // Delegado para ISyncManager - manter por compatibilidade apenas
        final result = await _syncManager.forceSync('petiveti');
        result.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );
      },
      errorMessage: 'Failed to sync animals',
      isCache: false,
    );
  }
}
