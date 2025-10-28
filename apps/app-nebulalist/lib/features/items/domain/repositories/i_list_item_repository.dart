import 'package:core/core.dart';
import '../entities/list_item_entity.dart';

/// Repository interface for ListItem operations
/// Follows Repository Pattern from Clean Architecture
abstract class IListItemRepository {
  /// Get all list items for a specific list
  Future<Either<Failure, List<ListItemEntity>>> getListItems(String listId);

  /// Get a specific list item by ID
  Future<Either<Failure, ListItemEntity>> getListItemById(String id);

  /// Add a new item to a list
  Future<Either<Failure, ListItemEntity>> addItemToList(ListItemEntity item);

  /// Update an existing list item
  Future<Either<Failure, ListItemEntity>> updateListItem(ListItemEntity item);

  /// Remove an item from a list
  Future<Either<Failure, void>> removeItemFromList(String id);

  /// Toggle item completion status
  Future<Either<Failure, ListItemEntity>> toggleItemCompletion(String id);

  /// Get count of items in a specific list
  Future<Either<Failure, int>> getListItemsCount(String listId);

  /// Get count of completed items in a specific list
  Future<Either<Failure, int>> getCompletedItemsCount(String listId);

  /// Check if item (by name) already exists in list
  Future<Either<Failure, bool>> isItemInList(String listId, String itemName);

  /// Reorder items in a list
  Future<Either<Failure, void>> reorderListItems(
    String listId,
    List<String> itemIdsInOrder,
  );
}
