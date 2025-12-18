import 'package:core/core.dart';
import '../entities/list_item_entity.dart';
import '../repositories/i_item_master_repository.dart';
import '../repositories/i_list_item_repository.dart';

/// Use case for adding an item to a list
/// Implements business rules from RN-I002 and RN-I003 (BUSINESS_RULES.md)
class AddItemToListUseCase {
  final IListItemRepository _listItemRepository;
  final IItemMasterRepository _itemMasterRepository;

  AddItemToListUseCase(
    this._listItemRepository,
    this._itemMasterRepository,
  );

  /// Adds a ListItem to a list and increments ItemMaster usage count
  /// Returns `Either<Failure, ListItemEntity>`
  ///
  /// Validations:
  /// - Quantity: 0-50 characters if provided
  /// - Notes: 0-500 characters if provided
  Future<Either<Failure, ListItemEntity>> call(
    ListItemEntity listItem,
  ) async {
    // Validation: Quantity
    if (listItem.quantity.length > 50) {
      return const Left(
        ValidationFailure('Quantidade deve ter no máximo 50 caracteres'),
      );
    }

    // Validation: Notes
    if (listItem.notes != null && listItem.notes!.length > 500) {
      return const Left(
        ValidationFailure('Nota deve ter no máximo 500 caracteres'),
      );
    }

    // Add item to list
    final result = await _listItemRepository.addItemToList(listItem);

    if (result.isRight()) {
      // Increment ItemMaster usage count (fire and forget)
      await _itemMasterRepository.incrementUsageCount(listItem.itemMasterId);
    }

    return result;
  }
}
