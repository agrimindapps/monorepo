import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../entities/list_entity.dart';
import '../repositories/i_list_repository.dart';

/// Use case for retrieving user lists
/// Returns only non-archived lists by default
@injectable
class GetListsUseCase {
  final IListRepository _repository;

  GetListsUseCase(this._repository);

  /// Get all active (non-archived) lists for current user
  /// Lists are sorted by:
  /// 1. Favorites first
  /// 2. Then by updatedAt (most recent first)
  Future<Either<Failure, List<ListEntity>>> call({
    bool includeArchived = false,
  }) async {
    final result = includeArchived
        ? await _repository.getAllLists()
        : await _repository.getLists();

    return result.fold(
      (failure) => Left(failure),
      (lists) {
        // Sort: favorites first, then by updatedAt
        final sortedLists = List<ListEntity>.from(lists);
        sortedLists.sort((a, b) {
          // Favorites first
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;

          // Then by updatedAt (most recent first)
          return b.updatedAt.compareTo(a.updatedAt);
        });

        return Right(sortedLists);
      },
    );
  }
}
