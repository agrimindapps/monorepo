import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';
import '../../repositories/i_diagnosticos_repository.dart';
import 'i_diagnosticos_validation_service.dart';

/// Implementation of validation service for diagnosticos
///
/// Provides comprehensive validation logic for diagnosticos
/// including existence, compatibility, and completeness checks.
@Injectable(as: IDiagnosticosValidationService)
class DiagnosticosValidationService implements IDiagnosticosValidationService {
  final IDiagnosticosRepository _repository;

  DiagnosticosValidationService(this._repository);

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    if (id.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do diagnóstico não pode estar vazio'),
      );
    }

    return _repository.exists(id);
  }

  @override
  Future<Either<Failure, bool>> validateCompatibility({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    // Validate parameters
    if (idDefensivo.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do defensivo não pode estar vazio'),
      );
    }

    if (idCultura.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da cultura não pode estar vazio'),
      );
    }

    if (idPraga.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da praga não pode estar vazio'),
      );
    }

    return _repository.validarCompatibilidade(
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
    );
  }

  @override
  Either<Failure, DiagnosticoValidationResult> validateDiagnosticoCompleteness(
    DiagnosticoEntity diagnostico,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate IDs
    if (diagnostico.id.trim().isEmpty) {
      errors.add('ID do diagnóstico está vazio');
    }

    if (diagnostico.idDefensivo.trim().isEmpty) {
      errors.add('ID do defensivo está vazio');
    }

    if (diagnostico.idCultura.trim().isEmpty) {
      errors.add('ID da cultura está vazio');
    }

    if (diagnostico.idPraga.trim().isEmpty) {
      errors.add('ID da praga está vazio');
    }

    // Validate names (warnings only - not critical)
    if (!diagnostico.hasDefensivoInfo) {
      warnings.add('Nome do defensivo não está disponível');
    }

    if (!diagnostico.hasCulturaInfo) {
      warnings.add('Nome da cultura não está disponível');
    }

    if (!diagnostico.hasPragaInfo) {
      warnings.add('Nome da praga não está disponível');
    }

    // Validate dosage
    if (!diagnostico.hasDosagemValida) {
      errors.add('Informações de dosagem inválidas ou ausentes');
    } else {
      // Check for valid dosage values
      if (diagnostico.dosagem.dosagemMaxima <= 0) {
        errors.add('Dosagem máxima deve ser maior que zero');
      }

      if (diagnostico.dosagem.dosagemMinima != null &&
          diagnostico.dosagem.dosagemMinima! < 0) {
        errors.add('Dosagem mínima não pode ser negativa');
      }

      if (diagnostico.dosagem.hasRange &&
          diagnostico.dosagem.dosagemMinima! >=
              diagnostico.dosagem.dosagemMaxima) {
        errors.add('Dosagem mínima deve ser menor que a máxima');
      }

      if (diagnostico.dosagem.unidadeMedida.trim().isEmpty) {
        errors.add('Unidade de medida da dosagem está vazia');
      }
    }

    // Validate application
    if (!diagnostico.hasAplicacaoValida) {
      errors.add('Informações de aplicação inválidas ou ausentes');
    } else {
      // Check if at least one application type is valid
      final hasValidTerrestre =
          diagnostico.aplicacao.terrestre?.isValid == true;
      final hasValidAerea = diagnostico.aplicacao.aerea?.isValid == true;

      if (!hasValidTerrestre && !hasValidAerea) {
        errors.add(
          'Pelo menos um tipo de aplicação (terrestre ou aérea) deve ser válido',
        );
      }
    }

    // Determine result
    if (errors.isNotEmpty) {
      return Right(
        DiagnosticoValidationResult.invalid(
          errors: errors,
          warnings: warnings,
          completude: diagnostico.completude,
        ),
      );
    }

    return Right(
      DiagnosticoValidationResult.valid(
        warnings: warnings,
      ),
    );
  }

  @override
  Either<Failure, bool> validateDosageRange({
    required double min,
    required double max,
  }) {
    // Validate minimum value
    if (min < 0) {
      return const Left(
        ValidationFailure('Dosagem mínima não pode ser negativa'),
      );
    }

    // Validate maximum value
    if (max < 0) {
      return const Left(
        ValidationFailure('Dosagem máxima não pode ser negativa'),
      );
    }

    // Validate range
    if (min >= max) {
      return const Left(
        ValidationFailure('Dosagem mínima deve ser menor que a máxima'),
      );
    }

    // Validate reasonable bounds (optional - adjust as needed)
    if (max > 10000) {
      return const Left(
        ValidationFailure(
          'Dosagem máxima excede limite razoável (10000)',
        ),
      );
    }

    return const Right(true);
  }
}
