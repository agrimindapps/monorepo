import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/culturas_repository.dart';

/// Use case for deleting a cultura
class DeleteCulturaUseCase {
  final CulturasRepository repository;

  const DeleteCulturaUseCase(this.repository);

  /// Execute the use case
  /// Validates business rules and delegates to repository
  Future<Either<Failure, Unit>> call(String culturaId) async {
    // Business validation
    if (culturaId.trim().isEmpty) {
      return const Left(ValidationFailure('ID da cultura é obrigatório'));
    }

    // Delegate to repository
    final result = await repository.deleteCultura(culturaId);

    // Convert void to Unit for consistency
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(unit),
    );
  }
}
