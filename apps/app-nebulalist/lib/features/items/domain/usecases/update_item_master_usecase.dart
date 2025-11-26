import 'package:core/core.dart';
import '../entities/item_master_entity.dart';
import '../repositories/i_item_master_repository.dart';

/// Use case for updating an ItemMaster
/// Implements business rules from RN-I008 (BUSINESS_RULES.md)
class UpdateItemMasterUseCase {
  final IItemMasterRepository _repository;

  UpdateItemMasterUseCase(this._repository);

  /// Updates an ItemMaster with validations
  /// Changes DO NOT affect existing ListItems (only future additions)
  Future<Either<Failure, ItemMasterEntity>> call(
    ItemMasterEntity itemMaster,
  ) async {
    // Validation: Name
    if (itemMaster.name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Nome do item é obrigatório'),
      );
    }

    if (itemMaster.name.length > 200) {
      return const Left(
        ValidationFailure('Nome deve ter no máximo 200 caracteres'),
      );
    }

    // Update with trimmed values
    final cleanedItem = ItemMasterEntity(
      id: itemMaster.id,
      ownerId: itemMaster.ownerId,
      name: itemMaster.name.trim(),
      description: itemMaster.description.trim(),
      tags: itemMaster.tags,
      category: itemMaster.category,
      photoUrl: itemMaster.photoUrl,
      estimatedPrice: itemMaster.estimatedPrice,
      preferredBrand: itemMaster.preferredBrand,
      notes: itemMaster.notes?.trim(),
      usageCount: itemMaster.usageCount,
      createdAt: itemMaster.createdAt,
      updatedAt: DateTime.now(),
    );

    return await _repository.updateItemMaster(cleanedItem);
  }
}
