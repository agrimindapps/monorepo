import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/cultura.dart';
import '../repositories/culturas_repository.dart';

/// Use case for creating a new cultura
@lazySingleton
class CreateCulturaUseCase {
  final CulturasRepository repository;

  const CreateCulturaUseCase(this.repository);

  /// Execute the use case
  /// Validates business rules and delegates to repository
  Future<Either<Failure, Cultura>> call(Cultura cultura) async {
    // Business validation
    if (cultura.nomeComum.trim().isEmpty) {
      return const Left(ValidationFailure('Nome comum é obrigatório'));
    }

    if (cultura.nomeComum.trim().length < 3) {
      return const Left(
        ValidationFailure('Nome comum deve ter no mínimo 3 caracteres'),
      );
    }

    if (cultura.nomeCientifico.trim().isEmpty) {
      return const Left(ValidationFailure('Nome científico é obrigatório'));
    }

    if (cultura.nomeCientifico.trim().length < 3) {
      return const Left(
        ValidationFailure('Nome científico deve ter no mínimo 3 caracteres'),
      );
    }

    if (cultura.familia.trim().isEmpty) {
      return const Left(ValidationFailure('Família é obrigatória'));
    }

    // Delegate to repository
    return repository.createCultura(cultura);
  }
}
