import 'package:core/core.dart';
import '../entities/item_master_entity.dart';

/// Repository interface for ItemMaster operations
/// Follows Repository Pattern from Clean Architecture
abstract class IItemMasterRepository {
  /// Get all item masters for the current user
  Future<Either<Failure, List<ItemMasterEntity>>> getItemMasters();

  /// Get a specific item master by ID
  Future<Either<Failure, ItemMasterEntity>> getItemMasterById(String id);

  /// Create a new item master
  Future<Either<Failure, ItemMasterEntity>> createItemMaster(
    ItemMasterEntity itemMaster,
  );

  /// Update an existing item master
  Future<Either<Failure, ItemMasterEntity>> updateItemMaster(
    ItemMasterEntity itemMaster,
  );

  /// Delete an item master permanently
  Future<Either<Failure, void>> deleteItemMaster(String id);

  /// Get count of item masters for current user
  Future<Either<Failure, int>> getItemMastersCount();

  /// Increment usage count for an item master
  Future<Either<Failure, void>> incrementUsageCount(String id);

  /// Search item masters by name (fuzzy match)
  Future<Either<Failure, List<ItemMasterEntity>>> searchItemMasters(
    String query,
  );

  /// Check if user has reached free tier limit
  Future<Either<Failure, bool>> canCreateItemMaster();
}
