import 'package:core/core.dart';
import '../repositories/i_list_item_repository.dart';

/// Use case for removing an item from a list
/// NOTE: This only removes the ListItem, not the ItemMaster
class RemoveItemFromListUseCase {
  final IListItemRepository _repository;

  RemoveItemFromListUseCase(this._repository);

  /// Removes a ListItem from a list
  /// The ItemMaster remains in the user's bank
  Future<Either<Failure, void>> call(String listItemId) async {
    if (listItemId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do item é obrigatório'),
      );
    }

    return await _repository.removeItemFromList(listItemId);
  }
}
