import 'package:core/core.dart';
import '../entities/item_master_entity.dart';
import '../repositories/i_item_master_repository.dart';

/// Use case for creating a new ItemMaster
/// Implements business rules from RN-I001 (BUSINESS_RULES.md)
class CreateItemMasterUseCase {
  final IItemMasterRepository _repository;

  CreateItemMasterUseCase(this._repository);

  /// Creates a new ItemMaster with validations
  /// Returns `Either<Failure, ItemMasterEntity>`
  ///
  /// Validations:
  /// - Name: 1-200 characters, not just spaces
  /// - Checks free tier limit (max 200 ItemMasters)
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

    // Check free tier limit (RN-I005: max 200 ItemMasters)
    final canCreateResult = await _repository.canCreateItemMaster();
    if (canCreateResult.isLeft()) {
      return canCreateResult.fold(
        (failure) => Left(failure),
        (_) => const Left(UnexpectedFailure('Erro ao verificar limite')),
      );
    }

    final canCreate = canCreateResult.getOrElse(() => false);
    if (!canCreate) {
      return const Left(
        LimitReachedFailure(
          'Você atingiu o limite de 200 itens únicos no plano gratuito. '
          'Faça upgrade para Premium para itens ilimitados.',
        ),
      );
    }

    // Create with trimmed name
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
      usageCount: 0,
      createdAt: itemMaster.createdAt,
      updatedAt: itemMaster.updatedAt,
    );

    return await _repository.createItemMaster(cleanedItem);
  }
}
