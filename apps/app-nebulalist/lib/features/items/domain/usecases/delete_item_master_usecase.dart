import 'package:core/core.dart';
import '../repositories/i_item_master_repository.dart';

/// Use case for deleting an ItemMaster
/// NOTE: Deleting an ItemMaster does NOT delete ListItems that reference it
class DeleteItemMasterUseCase {
  final IItemMasterRepository _repository;

  DeleteItemMasterUseCase(this._repository);

  /// Deletes an ItemMaster permanently
  /// ListItems referencing this ItemMaster will still exist
  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do item é obrigatório'),
      );
    }

    return await _repository.deleteItemMaster(id);
  }
}
