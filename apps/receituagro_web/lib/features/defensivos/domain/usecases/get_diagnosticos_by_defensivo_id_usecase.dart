import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/diagnostico.dart';
import '../repositories/diagnosticos_repository.dart';

/// Use case for getting all diagnosticos for a specific defensivo
@lazySingleton
class GetDiagnosticosByDefensivoIdUseCase {
  final DiagnosticosRepository repository;

  const GetDiagnosticosByDefensivoIdUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, List<Diagnostico>>> call(String defensivoId) async {
    // Validation
    if (defensivoId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo é obrigatório'));
    }

    // Delegate to repository
    return repository.getDiagnosticosByDefensivoId(defensivoId);
  }
}
