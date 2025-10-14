import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';
import '../../repositories/i_diagnosticos_repository.dart';
import 'i_diagnosticos_search_service.dart';

/// Implementation of search service for diagnosticos
///
/// Delegates complex searches to repository and provides
/// client-side search utilities for in-memory operations.
@Injectable(as: IDiagnosticosSearchService)
class DiagnosticosSearchService implements IDiagnosticosSearchService {
  final IDiagnosticosRepository _repository;

  DiagnosticosSearchService(this._repository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    // Validate filters object is not null (should always be provided)
    if (!filters.hasFilters) {
      return const Left(
        ValidationFailure(
          'Nenhum filtro especificado para a busca',
        ),
      );
    }

    // Validate dosage range if specified
    if (filters.dosagemMinima != null && filters.dosagemMaxima != null) {
      if (filters.dosagemMinima! < 0) {
        return const Left(
          ValidationFailure('Dosagem mínima não pode ser negativa'),
        );
      }
      if (filters.dosagemMaxima! < 0) {
        return const Left(
          ValidationFailure('Dosagem máxima não pode ser negativa'),
        );
      }
      if (filters.dosagemMinima! >= filters.dosagemMaxima!) {
        return const Left(
          ValidationFailure('Dosagem mínima deve ser menor que a máxima'),
        );
      }
    }

    return _repository.searchWithFilters(
      defensivo: filters.idDefensivo,
      cultura: filters.idCultura,
      praga: filters.idPraga,
      tipoAplicacao: filters.tipoAplicacao?.toString(),
    );
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(
    String pattern,
  ) async {
    if (pattern.trim().isEmpty) {
      return const Left(
        ValidationFailure('Padrão de busca não pode estar vazio'),
      );
    }

    // Minimum pattern length for performance
    if (pattern.trim().length < 2) {
      return const Left(
        ValidationFailure(
          'Padrão de busca deve ter pelo menos 2 caracteres',
        ),
      );
    }

    return _repository.queryByPattern(pattern);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> findSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  }) async {
    if (diagnosticoId.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do diagnóstico não pode estar vazio'),
      );
    }

    if (limit < 1) {
      return const Left(
        ValidationFailure('Limite deve ser maior que zero'),
      );
    }

    if (limit > 50) {
      return const Left(
        ValidationFailure('Limite não pode exceder 50 resultados'),
      );
    }

    return _repository.getSimilarDiagnosticos(diagnosticoId);
  }

  // ========== Client-side search methods ==========

  @override
  List<DiagnosticoEntity> searchInList(
    List<DiagnosticoEntity> diagnosticos,
    String pattern,
  ) {
    // Return empty if pattern is too short
    if (pattern.trim().isEmpty || pattern.trim().length < 2) {
      return [];
    }

    final lowerPattern = pattern.toLowerCase().trim();

    return diagnosticos.where((diagnostico) {
      // Search in defensivo name
      final defensivoMatch = diagnostico.nomeDefensivo
              ?.toLowerCase()
              .contains(lowerPattern) ==
          true;

      // Search in cultura name
      final culturaMatch =
          diagnostico.nomeCultura?.toLowerCase().contains(lowerPattern) ==
              true;

      // Search in praga name
      final pragaMatch =
          diagnostico.nomePraga?.toLowerCase().contains(lowerPattern) == true;

      return defensivoMatch || culturaMatch || pragaMatch;
    }).toList();
  }
}
