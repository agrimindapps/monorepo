import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import '../entities/item_master_entity.dart';
import '../repositories/i_item_master_repository.dart';

/// Use case for retrieving all ItemMasters
/// Items are sorted by usage count (most used first)
@injectable
class GetItemMastersUseCase {
  final IItemMasterRepository _repository;

  GetItemMastersUseCase(this._repository);

  /// Get all ItemMasters for current user
  /// Returns list sorted by usageCount descending
  Future<Either<Failure, List<ItemMasterEntity>>> call() async {
    final result = await _repository.getItemMasters();

    return result.map((items) {
      // Sort by usage count (most used first)
      final sortedItems = List<ItemMasterEntity>.from(items);
      sortedItems.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      return sortedItems;
    });
  }
}
