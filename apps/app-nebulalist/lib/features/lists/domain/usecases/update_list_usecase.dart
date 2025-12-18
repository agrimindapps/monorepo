import 'package:core/core.dart';
import '../entities/list_entity.dart';
import '../repositories/i_list_repository.dart';

/// Use case for updating an existing list
/// Implements validation rules from RN-L001 (BUSINESS_RULES.md)
class UpdateListUseCase {
  final IListRepository _repository;

  UpdateListUseCase(this._repository);

  /// Update a list with validations
  /// Returns `Either<Failure, ListEntity>`
  ///
  /// Validations:
  /// - Name: 1-100 characters, not just spaces
  /// - Description: 0-500 characters
  Future<Either<Failure, ListEntity>> call(ListEntity list) async {
    // Validation: Name
    if (list.name.trim().isEmpty) {
      return const Left(
        ValidationFailure('Nome da lista é obrigatório'),
      );
    }

    if (list.name.length > 100) {
      return const Left(
        ValidationFailure('Nome deve ter no máximo 100 caracteres'),
      );
    }

    // Validation: Description
    if (list.description.length > 500) {
      return const Left(
        ValidationFailure('Descrição deve ter no máximo 500 caracteres'),
      );
    }

    // Update timestamp
    final updatedList = list.copyWith(
      name: list.name.trim(),
      description: list.description.trim(),
      updatedAt: DateTime.now(),
    );

    return await _repository.updateList(updatedList);
  }
}
