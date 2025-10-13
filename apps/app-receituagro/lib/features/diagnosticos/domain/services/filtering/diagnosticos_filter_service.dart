import 'package:core/core.dart';

import '../../entities/diagnostico_entity.dart';
import '../../repositories/i_diagnosticos_repository.dart';
import 'i_diagnosticos_filter_service.dart';

/// Implementation of filtering service for diagnosticos
///
/// Delegates server-side queries to repository and provides
/// client-side filtering utilities for in-memory operations.
@Injectable(as: IDiagnosticosFilterService)
class DiagnosticosFilterService implements IDiagnosticosFilterService {
  final IDiagnosticosRepository _repository;

  DiagnosticosFilterService(this._repository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByDefensivo(
    String idDefensivo,
  ) async {
    if (idDefensivo.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID do defensivo não pode estar vazio'),
      );
    }

    return _repository.queryByDefensivo(idDefensivo);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCultura(
    String idCultura,
  ) async {
    if (idCultura.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da cultura não pode estar vazio'),
      );
    }

    return _repository.queryByCultura(idCultura);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByPraga(
    String idPraga,
  ) async {
    if (idPraga.trim().isEmpty) {
      return const Left(
        ValidationFailure('ID da praga não pode estar vazio'),
      );
    }

    return _repository.queryByPraga(idPraga);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  }) async {
    // Validate at least one parameter is provided
    if (idDefensivo == null && idCultura == null && idPraga == null) {
      return const Left(
        ValidationFailure(
          'Pelo menos um filtro deve ser especificado (defensivo, cultura ou praga)',
        ),
      );
    }

    // Validate non-empty strings
    if (idDefensivo?.trim().isEmpty == true) {
      return const Left(
        ValidationFailure('ID do defensivo não pode estar vazio'),
      );
    }
    if (idCultura?.trim().isEmpty == true) {
      return const Left(
        ValidationFailure('ID da cultura não pode estar vazio'),
      );
    }
    if (idPraga?.trim().isEmpty == true) {
      return const Left(
        ValidationFailure('ID da praga não pode estar vazio'),
      );
    }

    return _repository.queryByTriplaCombinacao(
      idDefensivo: idDefensivo,
      idCultura: idCultura,
      idPraga: idPraga,
    );
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByTipoAplicacao(
    TipoAplicacao tipo,
  ) async {
    // Get all diagnosticos and filter in-memory
    final result = await _repository.getAll();
    return result.fold(
      (failure) => Left(failure),
      (diagnosticos) => Right(filterListByTipoAplicacao(diagnosticos, tipo)),
    );
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByCompletude(
    DiagnosticoCompletude completude,
  ) async {
    // Get all diagnosticos and filter in-memory
    final result = await _repository.getAll();
    return result.fold(
      (failure) => Left(failure),
      (diagnosticos) => Right(filterListByCompletude(diagnosticos, completude)),
    );
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> filterByFaixaDosagem({
    required double min,
    required double max,
  }) async {
    // Validate dosage range
    if (min < 0) {
      return const Left(
        ValidationFailure('Dosagem mínima não pode ser negativa'),
      );
    }
    if (max < 0) {
      return const Left(
        ValidationFailure('Dosagem máxima não pode ser negativa'),
      );
    }
    if (min >= max) {
      return const Left(
        ValidationFailure('Dosagem mínima deve ser menor que a máxima'),
      );
    }

    // Get all diagnosticos and filter in-memory
    final result = await _repository.getAll();
    return result.fold(
      (failure) => Left(failure),
      (diagnosticos) => Right(
        filterListByFaixaDosagem(diagnosticos, min: min, max: max),
      ),
    );
  }

  // ========== Client-side filtering methods ==========

  @override
  List<DiagnosticoEntity> filterListByTipoAplicacao(
    List<DiagnosticoEntity> diagnosticos,
    TipoAplicacao tipo,
  ) {
    return diagnosticos.where((diagnostico) {
      return diagnostico.aplicacao.tiposDisponiveis.contains(tipo);
    }).toList();
  }

  @override
  List<DiagnosticoEntity> filterListByCompletude(
    List<DiagnosticoEntity> diagnosticos,
    DiagnosticoCompletude completude,
  ) {
    return diagnosticos.where((diagnostico) {
      return diagnostico.completude == completude;
    }).toList();
  }

  @override
  List<DiagnosticoEntity> filterListByFaixaDosagem(
    List<DiagnosticoEntity> diagnosticos, {
    required double min,
    required double max,
  }) {
    // Validate range before filtering
    if (min < 0 || max < 0 || min >= max) {
      return [];
    }

    return diagnosticos.where((diagnostico) {
      final dosagem = diagnostico.dosagem.dosagemMaxima;
      return dosagem >= min && dosagem <= max;
    }).toList();
  }
}
