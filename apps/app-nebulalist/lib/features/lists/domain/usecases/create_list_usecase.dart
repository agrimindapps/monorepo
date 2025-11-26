import 'package:core/core.dart';
import '../entities/list_entity.dart';
import '../repositories/i_list_repository.dart';

/// Use case for creating a new list
/// Implements business rules from RN-L001 and RN-L002 (BUSINESS_RULES.md)
class CreateListUseCase {
  final IListRepository _repository;

  CreateListUseCase(this._repository);

  /// Creates a new list with validations
  /// Returns Either<Failure, ListEntity>
  ///
  /// Validations:
  /// - Name: 1-100 characters, not just spaces
  /// - Description: 0-500 characters
  /// - Checks free tier limit (max 10 active lists)
  Future<Either<Failure, ListEntity>> call({
    required String name,
    String? description,
    List<String> tags = const [],
    String category = 'outros',
  }) async {
    // Validation: Name
    if (name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Nome da lista é obrigatório'),
      );
    }

    if (name.length > 100) {
      return const Left(
        ValidationFailure('Nome deve ter no máximo 100 caracteres'),
      );
    }

    // Validation: Description
    if (description != null && description.length > 500) {
      return const Left(
        ValidationFailure('Descrição deve ter no máximo 500 caracteres'),
      );
    }

    // Check free tier limit (RN-L002)
    final canCreateResult = await _repository.canCreateList();
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
          'Você atingiu o limite de 10 listas no plano gratuito. '
          'Faça upgrade para Premium para criar listas ilimitadas.',
        ),
      );
    }

    // Create list entity
    // Note: ID, ownerId, and timestamps will be set by the repository
    final list = ListEntity(
      id: '', // Will be set by repository
      name: name.trim(),
      description: description?.trim() ?? '',
      tags: tags,
      category: category,
      ownerId: '', // Will be set by repository
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createList(list);
  }
}
