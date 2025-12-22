import 'package:core/core.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/sync/nebulalist_sync_queue_service.dart';
import '../../../subscription/domain/usecases/get_subscription_status.dart';
import '../../domain/entities/list_entity.dart';
import '../../domain/repositories/i_list_repository.dart';
import '../datasources/list_local_datasource.dart';
import '../datasources/list_remote_datasource.dart';
import '../models/list_model.dart';

/// Repository implementation for Lists
/// Offline-first: Drift is primary, Firestore synced via queue
class ListRepository implements IListRepository {
  final IListLocalDataSource _localDataSource;
  // ignore: unused_field
  final IListRemoteDataSource _remoteDataSource; // For future sync features
  final AuthStateNotifier _authNotifier;
  final NebulalistSyncQueueService _syncQueueService;
  final GetSubscriptionStatus _getSubscriptionStatus;

  // Free tier limit
  static const int _freeListsLimit = 10;

  ListRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._authNotifier,
    this._syncQueueService,
    this._getSubscriptionStatus,
  );

  String get _currentUserId {
    final userId = _authNotifier.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getLists() async {
    try {
      final lists = await _localDataSource.getActiveLists(_currentUserId);
      return Right(lists.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get lists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ListEntity>>> getAllLists() async {
    try {
      final lists = await _localDataSource.getAllLists(_currentUserId);
      return Right(lists.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get all lists: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> getListById(String id) async {
    try {
      final list = await _localDataSource.getList(id);

      if (list == null) {
        return const Left(NotFoundFailure('Lista não encontrada'));
      }

      // Verify ownership
      if (list.ownerId != _currentUserId) {
        return const Left(
          PermissionFailure('Você não tem permissão para acessar esta lista'),
        );
      }

      return Right(list.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> createList(ListEntity list) async {
    try {
      // Generate ID if empty
      final listId = list.id.isEmpty ? const Uuid().v4() : list.id;

      // Create entity with user ID and timestamps
      final updatedEntity = list.copyWith(
        id: listId,
        ownerId: _currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Convert to model for storage
      final model = ListModel.fromEntity(updatedEntity);

      // Save locally (primary)
      await _localDataSource.saveList(model);

      // Enqueue for reliable sync (replaces best-effort try-catch)
      await _syncQueueService.enqueue(
        modelType: 'List',
        modelId: listId,
        operation: 'create',
        data: model.toJson(),
      );

      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create list: $e'));
    }
  }

  @override
  Future<Either<Failure, ListEntity>> updateList(ListEntity list) async {
    try {
      // Verify list exists
      final existing = await _localDataSource.getList(list.id);
      if (existing == null) {
        return const Left(NotFoundFailure('Lista não encontrada'));
      }

      // Verify ownership
      if (existing.ownerId != _currentUserId) {
        return const Left(
          PermissionFailure('Apenas o dono pode atualizar a lista'),
        );
      }

      // Update timestamp
      final updatedEntity = list.copyWith(
        updatedAt: DateTime.now(),
      );

      // Convert to model for storage
      final model = ListModel.fromEntity(updatedEntity);

      // Save locally (primary)
      await _localDataSource.saveList(model);

      // Enqueue for reliable sync (replaces best-effort try-catch)
      await _syncQueueService.enqueue(
        modelType: 'List',
        modelId: list.id,
        operation: 'update',
        data: model.toJson(),
      );

      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update list: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteList(String id) async {
    try {
      // Verify list exists
      final existing = await _localDataSource.getList(id);
      if (existing == null) {
        return const Left(NotFoundFailure('Lista não encontrada'));
      }

      // Verify ownership
      if (existing.ownerId != _currentUserId) {
        return const Left(
          PermissionFailure('Apenas o dono pode excluir a lista'),
        );
      }

      // Delete locally (primary)
      await _localDataSource.deleteList(id);

      // Enqueue for reliable sync (replaces best-effort try-catch)
      await _syncQueueService.enqueue(
        modelType: 'List',
        modelId: id,
        operation: 'delete',
        data: {'id': id}, // Minimal data for delete operation
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete list: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> archiveList(String id) async {
    try {
      // Get existing list
      final existing = await _localDataSource.getList(id);
      if (existing == null) {
        return const Left(NotFoundFailure('Lista não encontrada'));
      }

      // Verify ownership
      if (existing.ownerId != _currentUserId) {
        return const Left(
          PermissionFailure('Apenas o dono pode arquivar a lista'),
        );
      }

      // Archive
      final archivedEntity = existing.toEntity().copyWith(
        isArchived: true,
        archivedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Convert to model for storage
      final archived = ListModel.fromEntity(archivedEntity);

      await _localDataSource.saveList(archived);

      // Enqueue for reliable sync (replaces best-effort try-catch)
      await _syncQueueService.enqueue(
        modelType: 'List',
        modelId: id,
        operation: 'update',
        data: archived.toJson(),
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to archive list: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> restoreList(String id) async {
    try {
      // Get existing list
      final existing = await _localDataSource.getList(id);
      if (existing == null) {
        return const Left(NotFoundFailure('Lista não encontrada'));
      }

      // Verify ownership
      if (existing.ownerId != _currentUserId) {
        return const Left(
          PermissionFailure('Apenas o dono pode restaurar a lista'),
        );
      }

      // Restore
      final restoredEntity = existing.toEntity().copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
      );

      // Convert to model for storage
      final restored = ListModel.fromEntity(restoredEntity);

      await _localDataSource.saveList(restored);

      // Enqueue for reliable sync (replaces best-effort try-catch)
      await _syncQueueService.enqueue(
        modelType: 'List',
        modelId: id,
        operation: 'update',
        data: restored.toJson(),
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to restore list: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getActiveListsCount() async {
    try {
      final count = await _localDataSource.getActiveListsCount(_currentUserId);
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get active lists count: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> canCreateList() async {
    try {
      // Check if user is premium
      final isPremium = await _getSubscriptionStatus.isPremium();
      
      // Premium users have unlimited lists
      if (isPremium) {
        return const Right(true);
      }

      // Free tier: check limit
      final count = await _localDataSource.getActiveListsCount(_currentUserId);
      return Right(count < _freeListsLimit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check list limit: $e'));
    }
  }
}
