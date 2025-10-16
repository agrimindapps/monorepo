import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/defensivo.dart';
import '../repositories/defensivos_repository.dart';

/// Use case for updating an existing defensivo
@lazySingleton
class UpdateDefensivoUseCase {
  final DefensivosRepository repository;

  const UpdateDefensivoUseCase(this.repository);

  /// Execute the use case
  /// Validates business rules and delegates to repository
  Future<Either<Failure, Defensivo>> call(Defensivo defensivo) async {
    // Business validation
    if (defensivo.id.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo é obrigatório'));
    }

    if (defensivo.nomeComum.trim().isEmpty) {
      return const Left(ValidationFailure('Nome comum é obrigatório'));
    }

    if (defensivo.nomeComum.trim().length < 3) {
      return const Left(
        ValidationFailure('Nome comum deve ter no mínimo 3 caracteres'),
      );
    }

    if (defensivo.fabricante.trim().isEmpty) {
      return const Left(ValidationFailure('Fabricante é obrigatório'));
    }

    if (defensivo.ingredienteAtivo.trim().isEmpty) {
      return const Left(ValidationFailure('Ingrediente ativo é obrigatório'));
    }

    // Delegate to repository
    return repository.updateDefensivo(defensivo);
  }
}
