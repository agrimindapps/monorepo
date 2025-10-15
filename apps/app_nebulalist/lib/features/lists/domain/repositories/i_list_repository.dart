import 'package:core/core.dart';
import '../entities/list_entity.dart';

/// Repository interface for List operations
/// Follows Repository Pattern from Clean Architecture
abstract class IListRepository {
  /// Get all lists for the current user (non-archived)
  Future<Either<Failure, List<ListEntity>>> getLists();

  /// Get all lists including archived
  Future<Either<Failure, List<ListEntity>>> getAllLists();

  /// Get a specific list by ID
  Future<Either<Failure, ListEntity>> getListById(String id);

  /// Create a new list
  Future<Either<Failure, ListEntity>> createList(ListEntity list);

  /// Update an existing list
  Future<Either<Failure, ListEntity>> updateList(ListEntity list);

  /// Delete a list permanently
  Future<Either<Failure, void>> deleteList(String id);

  /// Archive a list (soft delete)
  Future<Either<Failure, void>> archiveList(String id);

  /// Restore an archived list
  Future<Either<Failure, void>> restoreList(String id);

  /// Get count of active (non-archived) lists
  Future<Either<Failure, int>> getActiveListsCount();

  /// Check if user has reached free tier limit
  Future<Either<Failure, bool>> canCreateList();
}
