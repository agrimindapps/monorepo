import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/diagnostico.dart';
import '../repositories/diagnosticos_repository.dart';

/// Use case for creating a new diagnostico entry
@lazySingleton
class CreateDiagnosticoUseCase {
  final DiagnosticosRepository repository;

  const CreateDiagnosticoUseCase(this.repository);

  /// Execute the use case
  /// Validates business rules and delegates to repository
  Future<Either<Failure, Diagnostico>> call(Diagnostico diagnostico) async {
    // Business validation
    if (diagnostico.defensivoId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo é obrigatório'));
    }

    if (diagnostico.culturaId.trim().isEmpty) {
      return const Left(ValidationFailure('ID da cultura é obrigatório'));
    }

    if (diagnostico.pragaId.trim().isEmpty) {
      return const Left(ValidationFailure('ID da praga é obrigatório'));
    }

    // Validate dosage fields if provided
    if (diagnostico.dsMin != null && diagnostico.dsMax != null) {
      final min = double.tryParse(diagnostico.dsMin!);
      final max = double.tryParse(diagnostico.dsMax!);

      if (min != null && max != null && min > max) {
        return const Left(
          ValidationFailure('Dosagem mínima não pode ser maior que a máxima'),
        );
      }
    }

    // Delegate to repository
    return repository.createDiagnostico(diagnostico);
  }
}
