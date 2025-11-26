import 'package:core/core.dart';
import '../entities/list_item_entity.dart';
import '../repositories/i_list_item_repository.dart';

/// Use case for toggling item completion status
/// Implements business rules from RN-I006 (BUSINESS_RULES.md)
class ToggleItemCompletionUseCase {
  final IListItemRepository _repository;

  ToggleItemCompletionUseCase(this._repository);

  /// Toggles completion status of a ListItem
  /// Updates completedAt timestamp accordingly
  /// Note: List count updates are handled in the repository layer
  Future<Either<Failure, ListItemEntity>> call(String listItemId) async {
    if (listItemId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do item é obrigatório'),
      );
    }

    return await _repository.toggleItemCompletion(listItemId);
  }
}
