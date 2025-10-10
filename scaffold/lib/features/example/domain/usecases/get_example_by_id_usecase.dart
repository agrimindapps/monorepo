import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/example_entity.dart';
import '../repositories/example_repository.dart';

/// Parameters for getting an example by ID
class GetExampleByIdParams {
  const GetExampleByIdParams({required this.id});

  final String id;
}

/// Use case for getting a specific example by ID
/// Validates ID and fetches from repository
@injectable
class GetExampleByIdUseCase
    implements UseCase<ExampleEntity, GetExampleByIdParams> {
  const GetExampleByIdUseCase(this._repository);

  final ExampleRepository _repository;

  @override
  Future<Either<Failure, ExampleEntity>> call(
    GetExampleByIdParams params,
  ) async {
    // Validate input
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    return _repository.getExampleById(params.id.trim());
  }

  /// Validate params
  ValidationFailure? _validate(GetExampleByIdParams params) {
    // ID is required
    if (params.id.trim().isEmpty) {
      return const ValidationFailure('ID do item é obrigatório');
    }

    return null;
  }
}
