import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../repositories/example_repository.dart';

/// Parameters for deleting an example
class DeleteExampleParams {
  const DeleteExampleParams({required this.id});

  final String id;
}

/// Use case for deleting an example
/// Validates input and delegates to repository
@injectable
class DeleteExampleUseCase implements UseCase<void, DeleteExampleParams> {
  const DeleteExampleUseCase(this._repository);

  final ExampleRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteExampleParams params) async {
    // Validate input
    final validationFailure = _validate(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Check if example exists
    final existsResult = await _repository.getExampleById(params.id.trim());

    return existsResult.fold(
      (failure) => Left(failure),
      (example) async {
        // Example exists, proceed with deletion
        return _repository.deleteExample(params.id.trim());
      },
    );
  }

  /// Validate params
  ValidationFailure? _validate(DeleteExampleParams params) {
    // ID is required
    if (params.id.trim().isEmpty) {
      return const ValidationFailure('ID do item é obrigatório');
    }

    return null;
  }
}
