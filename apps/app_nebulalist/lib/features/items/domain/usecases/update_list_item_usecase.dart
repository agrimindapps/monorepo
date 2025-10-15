import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../entities/list_item_entity.dart';
import '../repositories/i_list_item_repository.dart';

/// Use case for updating a ListItem
/// Can update quantity, priority, notes, etc.
@injectable
class UpdateListItemUseCase {
  final IListItemRepository _repository;

  UpdateListItemUseCase(this._repository);

  /// Updates a ListItem with validations
  Future<Either<Failure, ListItemEntity>> call(ListItemEntity listItem) async {
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

    // Update with current timestamp
    final updatedItem = ListItemEntity(
      id: listItem.id,
      listId: listItem.listId,
      itemMasterId: listItem.itemMasterId,
      quantity: listItem.quantity.trim(),
      priority: listItem.priority,
      isCompleted: listItem.isCompleted,
      completedAt: listItem.completedAt,
      notes: listItem.notes?.trim(),
      order: listItem.order,
      createdAt: listItem.createdAt,
      updatedAt: DateTime.now(),
      addedBy: listItem.addedBy,
    );

    return await _repository.updateListItem(updatedItem);
  }
}
