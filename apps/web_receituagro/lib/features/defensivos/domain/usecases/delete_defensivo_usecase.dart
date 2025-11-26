import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/defensivos_info_repository.dart';
import '../repositories/defensivos_repository.dart';
import '../repositories/diagnosticos_repository.dart';

/// Use case for deleting a defensivo
/// Handles cascade deletion of related data (diagnosticos and defensivo_info)
class DeleteDefensivoUseCase {
  final DefensivosRepository defensivosRepository;
  final DiagnosticosRepository diagnosticosRepository;
  final DefensivosInfoRepository defensivosInfoRepository;

  const DeleteDefensivoUseCase(
    this.defensivosRepository,
    this.diagnosticosRepository,
    this.defensivosInfoRepository,
  );

  /// Execute the use case
  /// Validates business rules and performs cascade deletion
  Future<Either<Failure, Unit>> call(String defensivoId) async {
    // Business validation
    if (defensivoId.trim().isEmpty) {
      return const Left(ValidationFailure('ID do defensivo é obrigatório'));
    }

    // Step 1: Delete all diagnosticos related to this defensivo
    final diagnosticosResult = await diagnosticosRepository
        .deleteDiagnosticosByDefensivoId(defensivoId);

    if (diagnosticosResult.isLeft()) {
      return diagnosticosResult;
    }

    // Step 2: Delete defensivo_info if exists
    final infoResult = await defensivosInfoRepository
        .deleteDefensivoInfoByDefensivoId(defensivoId);

    if (infoResult.isLeft()) {
      return infoResult;
    }

    // Step 3: Delete the defensivo itself
    return defensivosRepository.deleteDefensivo(defensivoId);
  }
}
