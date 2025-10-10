import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// Parameters for updating an example
class UpdateExampleParams {
  const UpdateExampleParams({
    required this.id,
    this.name,
    this.description,
  });

  final String id;
  final String? name;
  final String? description;
}

/// Use case for updating an existing example
/// Validates input, fetches current entity, applies changes
@injectable
class UpdateExampleUseCase
    implements UseCase<ExampleEntity, UpdateExampleParams> {
  const UpdateExampleUseCase(this._repository);

  final ExampleRepository _repository;

  @override
  Future<Either<Failure, ExampleEntity>> call(
    UpdateExampleParams params,
  ) async {
    // Validate input
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Get existing example
    final existingResult = await _repository.getExampleById(params.id.trim());

    return existingResult.fold(
      (failure) => Left(failure),
      (existing) async {
        // Apply updates
        final updated = existing.copyWith(
          name: params.name?.trim() ?? existing.name,
          description:
              params.description?.trim() ?? existing.description,
          updatedAt: DateTime.now(),
          isDirty: true, // Mark as needing sync
        );

        // Update in repository
        return _repository.updateExample(updated);
      },
    );
  }

  /// Validate params
  ValidationFailure? _validate(UpdateExampleParams params) {
    // ID is required
    if (params.id.trim().isEmpty) {
      return const ValidationFailure('ID do item é obrigatório');
    }

    // If name is provided, validate it
    if (params.name != null) {
      if (params.name!.trim().isEmpty) {
        return const ValidationFailure('Nome não pode ser vazio');
      }

      if (params.name!.trim().length < 2) {
        return const ValidationFailure(
          'Nome deve ter pelo menos 2 caracteres',
        );
      }

      if (params.name!.trim().length > 100) {
        return const ValidationFailure(
          'Nome deve ter no máximo 100 caracteres',
        );
      }
    }

    // If description is provided, validate it
    if (params.description != null &&
        params.description!.trim().length > 500) {
      return const ValidationFailure(
        'Descrição deve ter no máximo 500 caracteres',
      );
    }

    return null;
  }
}
