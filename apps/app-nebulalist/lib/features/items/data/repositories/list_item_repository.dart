import 'package:core/core.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/auth/auth_state_notifier.dart';
import '../../../lists/domain/repositories/i_list_repository.dart';
import '../../domain/entities/list_item_entity.dart';
import '../../domain/repositories/i_list_item_repository.dart';
import '../datasources/list_item_local_datasource.dart';
import '../datasources/list_item_remote_datasource.dart';
import '../models/list_item_model.dart';

/// Implementation of ListItem repository
/// Offline-first: Hive is primary, Firestore is optional sync
/// Updates list counts when items change
class ListItemRepository implements IListItemRepository {
  final ListItemLocalDataSource _localDataSource;
  final ListItemRemoteDataSource _remoteDataSource;
  final IListRepository _listRepository;
  final AuthStateNotifier _authNotifier;

  ListItemRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._listRepository,
    this._authNotifier,
  );

  String? get _currentUserId => _authNotifier.userId;

  @override
  Future<Either<Failure, List<ListItemEntity>>> getListItems(
    String listId,
  ) async {
    try {
      final models = _localDataSource.getListItems(listId);
      final entities = models.map((m) => m.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar itens: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ListItemEntity>> getListItemById(String id) async {
    try {
      final model = _localDataSource.getListItemById(id);

      if (model == null) {
        return const Left(NotFoundFailure('Item não encontrado'));
      }

      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ListItemEntity>> addItemToList(
    ListItemEntity item,
  ) async {
    try {
      if (_currentUserId == null) {
        return const Left(
          AuthFailure('Usuário não autenticado'),
        );
      }

      // Get next order number
      final existingItems = _localDataSource.getListItems(item.listId);
      final maxOrder =
          existingItems.isEmpty ? 0 : existingItems.map((i) => i.order).reduce((a, b) => a > b ? a : b);

      // Create with generated ID and order
      final newItem = ListItemEntity(
        id: const Uuid().v4(),
        listId: item.listId,
        itemMasterId: item.itemMasterId,
        quantity: item.quantity,
        priority: item.priority,
        isCompleted: false,
        notes: item.notes,
        order: maxOrder + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        addedBy: _currentUserId,
      );

      final model = ListItemModel.fromEntity(newItem);

      // Save to local storage
      await _localDataSource.saveListItem(model);

      // Update list item count
      await _updateListCounts(item.listId);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.saveListItem(model).ignore();

      return Right(newItem);
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ListItemEntity>> updateListItem(
    ListItemEntity item,
  ) async {
    try {
      final model = ListItemModel.fromEntity(item);

      // Update in local storage
      await _localDataSource.saveListItem(model);

      // Update list counts (in case completion status changed)
      await _updateListCounts(item.listId);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.saveListItem(model).ignore();

      return Right(item);
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeItemFromList(String id) async {
    try {
      // Get item to know which list to update
      final model = _localDataSource.getListItemById(id);
      if (model == null) {
        return const Left(NotFoundFailure('Item não encontrado'));
      }

      final listId = model.listId;

      // Delete from local storage
      await _localDataSource.deleteListItem(id);

      // Update list item count
      await _updateListCounts(listId);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.deleteListItem(id).ignore();

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ListItemEntity>> toggleItemCompletion(
    String id,
  ) async {
    try {
      final model = _localDataSource.getListItemById(id);

      if (model == null) {
        return const Left(NotFoundFailure('Item não encontrado'));
      }

      // Toggle completion
      final isCompleting = !model.isCompleted;

      final updated = ListItemModel(
        id: model.id,
        listId: model.listId,
        itemMasterId: model.itemMasterId,
        quantity: model.quantity,
        priorityIndex: model.priorityIndex,
        isCompleted: isCompleting,
        completedAt: isCompleting ? DateTime.now() : null,
        notes: model.notes,
        order: model.order,
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
        addedBy: model.addedBy,
      );

      await _localDataSource.saveListItem(updated);

      // Update list counts
      await _updateListCounts(model.listId);

      // Optional: Sync to remote (fire and forget)
      _remoteDataSource.saveListItem(updated).ignore();

      return Right(updated.toEntity());
    } catch (e) {
      return Left(
        CacheFailure('Erro ao marcar item: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getListItemsCount(String listId) async {
    try {
      final count = _localDataSource.getListItemsCount(listId);
      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar itens: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCompletedItemsCount(String listId) async {
    try {
      final count = _localDataSource.getCompletedItemsCount(listId);
      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar itens: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isItemInList(
    String listId,
    String itemName,
  ) async {
    try {
      // TODO: Implement proper item check - this is a placeholder
      // Should check ItemMaster names in the list
      return const Right(false); // Placeholder
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> reorderListItems(
    String listId,
    List<String> itemIdsInOrder,
  ) async {
    try {
      for (var i = 0; i < itemIdsInOrder.length; i++) {
        final itemId = itemIdsInOrder[i];
        final model = _localDataSource.getListItemById(itemId);

        if (model != null) {
          final updated = ListItemModel(
            id: model.id,
            listId: model.listId,
            itemMasterId: model.itemMasterId,
            quantity: model.quantity,
            priorityIndex: model.priorityIndex,
            isCompleted: model.isCompleted,
            completedAt: model.completedAt,
            notes: model.notes,
            order: i,
            createdAt: model.createdAt,
            updatedAt: DateTime.now(),
            addedBy: model.addedBy,
          );

          await _localDataSource.saveListItem(updated);

          // Optional: Sync to remote (fire and forget)
          _remoteDataSource.saveListItem(updated).ignore();
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao reordenar itens: ${e.toString()}'));
    }
  }

  /// Update list's itemCount and completedCount
  Future<void> _updateListCounts(String listId) async {
    try {
      final listResult = await _listRepository.getListById(listId);

      listResult.fold(
        (failure) => null, // Ignore if list not found
        (list) async {
          final itemCount = _localDataSource.getListItemsCount(listId);
          final completedCount =
              _localDataSource.getCompletedItemsCount(listId);

          final updated = list.copyWith(
            itemCount: itemCount,
            completedCount: completedCount,
            updatedAt: DateTime.now(),
          );

          await _listRepository.updateList(updated);
        },
      );
    } catch (e) {
      // Silently fail - counts will be eventually consistent
    }
  }
}
