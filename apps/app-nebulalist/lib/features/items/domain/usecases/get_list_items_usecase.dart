import 'package:core/core.dart';
import '../entities/list_item_entity.dart';
import '../repositories/i_list_item_repository.dart';

/// Use case for retrieving all items in a list
/// Items are sorted by order field
class GetListItemsUseCase {
  final IListItemRepository _repository;

  GetListItemsUseCase(this._repository);

  /// Get all ListItems for a specific list
  /// Returns list sorted by order
  Future<Either<Failure, List<ListItemEntity>>> call(String listId) async {
    if (listId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da lista é obrigatório'),
      );
    }

    final result = await _repository.getListItems(listId);

    return result.map((items) {
      // Sort by order
      final sortedItems = List<ListItemEntity>.from(items);
      sortedItems.sort((a, b) => a.order.compareTo(b.order));
      return sortedItems;
    });
  }
}
