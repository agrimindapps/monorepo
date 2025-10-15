import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../repositories/i_list_repository.dart';

/// Use case for deleting a list
/// Implements soft delete (archive) by default
/// Follows RN-L003 and RN-L004 (BUSINESS_RULES.md)
@injectable
class DeleteListUseCase {
  final IListRepository _repository;

  DeleteListUseCase(this._repository);

  /// Delete a list (soft delete - archives it)
  /// For permanent deletion, use hardDelete parameter
  ///
  /// Soft delete (default):
  /// - Marks list as archived
  /// - Can be restored later
  /// - Doesn't count toward free tier limit
  ///
  /// Hard delete:
  /// - Permanently removes list
  /// - Cannot be undone
  /// - Requires confirmation from UI
  Future<Either<Failure, void>> call(
    String listId, {
    bool hardDelete = false,
  }) async {
    if (listId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da lista é obrigatório'),
      );
    }

    if (hardDelete) {
      // Permanent deletion
      return await _repository.deleteList(listId);
    } else {
      // Soft delete (archive)
      return await _repository.archiveList(listId);
    }
  }

  /// Restore an archived list
  Future<Either<Failure, void>> restore(String listId) async {
    if (listId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da lista é obrigatório'),
      );
    }

    return await _repository.restoreList(listId);
  }
}
