import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:core/core.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// Parameters for adding a new example
class AddExampleParams {
  const AddExampleParams({
    required this.name,
    this.description,
    this.userId,
  });

  final String name;
  final String? description;
  final String? userId;
}

/// Use case for adding a new example
/// Validates input and delegates to repository
@injectable
class AddExampleUseCase implements UseCase<ExampleEntity, AddExampleParams> {
  const AddExampleUseCase(this._repository);

  final ExampleRepository _repository;
  static const _uuid = Uuid();

  @override
  Future<Either<Failure, ExampleEntity>> call(AddExampleParams params) async {
    // Validate input
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Create entity with proper initialization
    final example = ExampleEntity(
      id: _uuid.v4(),
      name: params.name.trim(),
      description: params.description?.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true, // Mark as needing sync
      userId: params.userId,
      moduleName: 'example',
    );

    // Add to repository
    return _repository.addExample(example);
  }

  /// Validate params
  ValidationFailure? _validate(AddExampleParams params) {
    // Name is required
    if (params.name.trim().isEmpty) {
      return const ValidationFailure('Nome é obrigatório');
    }

    // Name minimum length
    if (params.name.trim().length < 2) {
      return const ValidationFailure(
        'Nome deve ter pelo menos 2 caracteres',
      );
    }

    // Name maximum length
    if (params.name.trim().length > 100) {
      return const ValidationFailure(
        'Nome deve ter no máximo 100 caracteres',
      );
    }

    // Description maximum length (if provided)
    if (params.description != null &&
        params.description!.trim().length > 500) {
      return const ValidationFailure(
        'Descrição deve ter no máximo 500 caracteres',
      );
    }

    return null;
  }
}
