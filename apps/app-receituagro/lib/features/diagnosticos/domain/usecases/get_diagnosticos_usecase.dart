import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';
import '../repositories/i_diagnosticos_repository.dart';
import 'get_diagnosticos_params.dart';

/// Use Case consolidado para todas as operações de diagnósticos

class GetDiagnosticosUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosUseCase(this._repository);

  Future<Either<Failure, dynamic>> call(GetDiagnosticosParams params) async {
    try {
      return switch (params) {
        GetAllDiagnosticosParams p => await _getAll(p),
        GetDiagnosticoByIdParams p => await _getById(p),
        GetRecomendacoesParams p => await _getRecomendacoes(p),
        GetDiagnosticosByDefensivoParams p => await _getByDefensivo(p),
        GetDiagnosticosByCulturaParams p => await _getByCultura(p),
        GetDiagnosticosByPragaParams p => await _getByPraga(p),
        SearchDiagnosticosWithFiltersParams p => await _searchWithFilters(p),
        GetDiagnosticoStatsParams p => await _getStats(p),
        ValidateCompatibilidadeParams p => await _validateCompatibilidade(p),
        SearchDiagnosticosByPatternParams p => await _searchByPattern(p),
        GetDiagnosticoFiltersDataParams p => await _getFiltersData(p),
        _ => const Left(CacheFailure('Parâmetros inválidos para diagnósticos')),
      };
    } catch (e) {
      return Left(
        CacheFailure('Erro ao processar diagnósticos: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _getAll(
    GetAllDiagnosticosParams params,
  ) async {
    try {
      return await _repository.getAll(
        limit: params.limit,
        offset: params.offset,
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  Future<Either<Failure, DiagnosticoEntity?>> _getById(
    GetDiagnosticoByIdParams params,
  ) async {
    try {
      if (params.id.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do diagnóstico não pode ser vazio'),
        );
      }

      return await _repository.getById(params.id);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnóstico: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _getRecomendacoes(
    GetRecomendacoesParams params,
  ) async {
    try {
      if (params.idCultura.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }
      if (params.idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.getRecomendacoesPara(
        culturaId: params.idCultura,
        pragaId: params.idPraga,
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar recomendações: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _getByDefensivo(
    GetDiagnosticosByDefensivoParams params,
  ) async {
    try {
      if (params.idDefensivo.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do defensivo não pode ser vazio'),
        );
      }

      return await _repository.queryByDefensivo(params.idDefensivo);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar por defensivo: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _getByCultura(
    GetDiagnosticosByCulturaParams params,
  ) async {
    try {
      if (params.idCultura.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }

      return await _repository.queryByCultura(params.idCultura);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por cultura: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _getByPraga(
    GetDiagnosticosByPragaParams params,
  ) async {
    try {
      if (params.idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.queryByPraga(params.idPraga);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por praga: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _searchWithFilters(
    SearchDiagnosticosWithFiltersParams params,
  ) async {
    try {
      return await _repository.searchWithFilters(
        defensivo: params.filters.idDefensivo,
        cultura: params.filters.idCultura,
        praga: params.filters.idPraga,
        tipoAplicacao: params.filters.tipoAplicacao?.toString(),
      );
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }

  Future<Either<Failure, DiagnosticosStats>> _getStats(
    GetDiagnosticoStatsParams params,
  ) async {
    try {
      final result = await _repository.getStatistics();
      return result.fold(
        (failure) => Left(failure),
        (stats) => Right(
          DiagnosticosStats(
            total: stats['total'] as int,
            completos: 0,
            parciais: 0,
            incompletos: 0,
            porDefensivo: <String, int>{},
            porCultura: <String, int>{},
            porPraga: <String, int>{},
            topDiagnosticos: <DiagnosticoPopular>[],
          ),
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }

  Future<Either<Failure, bool>> _validateCompatibilidade(
    ValidateCompatibilidadeParams params,
  ) async {
    try {
      if (params.idDefensivo.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do defensivo não pode ser vazio'),
        );
      }
      if (params.idCultura.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }
      if (params.idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.validarCompatibilidade(
        idDefensivo: params.idDefensivo,
        idCultura: params.idCultura,
        idPraga: params.idPraga,
      );
    } catch (e) {
      return Left(ValidationFailure('Erro na validação: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<DiagnosticoEntity>>> _searchByPattern(
    SearchDiagnosticosByPatternParams params,
  ) async {
    try {
      if (params.pattern.trim().isEmpty) {
        return const Right(<DiagnosticoEntity>[]);
      }

      if (params.pattern.trim().length < 2) {
        return const Left(
          ValidationFailure('Padrão de busca deve ter pelo menos 2 caracteres'),
        );
      }

      return await _repository.searchByPattern(params.pattern.trim());
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }

  Future<Either<Failure, DiagnosticoFiltersData>> _getFiltersData(
    GetDiagnosticoFiltersDataParams params,
  ) async {
    try {
      final futures = await Future.wait([
        _repository.getAllDefensivos(),
        _repository.getAllCulturas(),
        _repository.getAllPragas(),
        _repository.getUnidadesMedida(),
      ]);

      final defensivosResult = futures[0];
      final culturasResult = futures[1];
      final pragasResult = futures[2];
      final unidadesResult = futures[3];

      if (defensivosResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar defensivos'));
      }
      if (culturasResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar culturas'));
      }
      if (pragasResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar pragas'));
      }
      if (unidadesResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar unidades'));
      }

      final filtersData = DiagnosticoFiltersData(
        defensivos: defensivosResult.fold(
          (l) => <String>[],
          (r) => (r as List<Map<String, dynamic>>)
              .map((m) => m['id'] as String)
              .toList(),
        ),
        culturas: culturasResult.fold(
          (l) => <String>[],
          (r) => (r as List<Map<String, dynamic>>)
              .map((m) => m['id'] as String)
              .toList(),
        ),
        pragas: pragasResult.fold(
          (l) => <String>[],
          (r) => (r as List<Map<String, dynamic>>)
              .map((m) => m['id'] as String)
              .toList(),
        ),
        unidadesMedida: unidadesResult.fold(
          (l) => <String>[],
          (r) => r as List<String>,
        ),
        tiposAplicacao: TipoAplicacao.values,
      );

      return Right(filtersData);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter dados de filtros: ${e.toString()}'),
      );
    }
  }
}

/// Use Case para buscar diagnóstico por ID

class GetDiagnosticoByIdUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticoByIdUseCase(this._repository);

  Future<Either<Failure, DiagnosticoEntity?>> call(String id) async {
    try {
      if (id.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do diagnóstico não pode ser vazio'),
        );
      }

      return await _repository.getById(id);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnóstico: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar recomendações por cultura e praga

class GetRecomendacoesUseCase {
  final IDiagnosticosRepository _repository;

  const GetRecomendacoesUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    try {
      if (idCultura.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }
      if (idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.getRecomendacoesPara(
        culturaId: idCultura,
        pragaId: idPraga,
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar recomendações: ${e.toString()}'),
      );
    }
  }
}

/// Use Case para buscar por defensivo

class GetDiagnosticosByDefensivoUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosByDefensivoUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(
    String idDefensivo,
  ) async {
    try {
      if (idDefensivo.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do defensivo não pode ser vazio'),
        );
      }

      return await _repository.queryByDefensivo(idDefensivo);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar por defensivo: ${e.toString()}'),
      );
    }
  }
}

/// Use Case para buscar por cultura

class GetDiagnosticosByCulturaUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosByCulturaUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(
    String idCultura,
  ) async {
    try {
      if (idCultura.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }

      return await _repository.queryByCultura(idCultura);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por cultura: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar por praga

class GetDiagnosticosByPragaUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosByPragaUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(String idPraga) async {
    try {
      if (idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.queryByPraga(idPraga);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por praga: ${e.toString()}'));
    }
  }
}

/// Use Case para busca com filtros

class SearchDiagnosticosWithFiltersUseCase {
  final IDiagnosticosRepository _repository;

  const SearchDiagnosticosWithFiltersUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(
    DiagnosticoSearchFilters filters,
  ) async {
    try {
      return await _repository.searchWithFilters(
        defensivo: filters.idDefensivo,
        cultura: filters.idCultura,
        praga: filters.idPraga,
        tipoAplicacao: filters.tipoAplicacao?.toString(),
      );
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }
}

/// Use Case para obter estatísticas

class GetDiagnosticoStatsUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticoStatsUseCase(this._repository);

  Future<Either<Failure, DiagnosticosStats>> call() async {
    try {
      final result = await _repository.getStatistics();
      return result.fold(
        (failure) => Left(failure),
        (stats) => Right(
          DiagnosticosStats(
            total: stats['total'] as int,
            completos: 0,
            parciais: 0,
            incompletos: 0,
            porDefensivo: {},
            porCultura: {},
            porPraga: {},
            topDiagnosticos: [],
          ),
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }
}

/// Use Case para validar compatibilidade

class ValidateCompatibilidadeUseCase {
  final IDiagnosticosRepository _repository;

  const ValidateCompatibilidadeUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    try {
      if (idDefensivo.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do defensivo não pode ser vazio'),
        );
      }
      if (idCultura.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID da cultura não pode ser vazio'),
        );
      }
      if (idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.validarCompatibilidade(
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
    } catch (e) {
      return Left(ValidationFailure('Erro na validação: ${e.toString()}'));
    }
  }
}

/// Use Case para busca por padrão

class SearchDiagnosticosByPatternUseCase {
  final IDiagnosticosRepository _repository;

  const SearchDiagnosticosByPatternUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(String pattern) async {
    try {
      if (pattern.trim().isEmpty) {
        return const Right(<DiagnosticoEntity>[]);
      }

      if (pattern.trim().length < 2) {
        return const Left(
          ValidationFailure('Padrão de busca deve ter pelo menos 2 caracteres'),
        );
      }

      return await _repository.searchByPattern(pattern.trim());
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }
}

/// Use Case para obter dados de filtros

class GetDiagnosticoFiltersDataUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticoFiltersDataUseCase(this._repository);

  Future<Either<Failure, DiagnosticoFiltersData>> call() async {
    try {
      final futures = await Future.wait([
        _repository.getAllDefensivos(),
        _repository.getAllCulturas(),
        _repository.getAllPragas(),
        _repository.getUnidadesMedida(),
      ]);

      final defensivosResult = futures[0];
      final culturasResult = futures[1];
      final pragasResult = futures[2];
      final unidadesResult = futures[3];

      if (defensivosResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar defensivos'));
      }
      if (culturasResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar culturas'));
      }
      if (pragasResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar pragas'));
      }
      if (unidadesResult.isLeft()) {
        return const Left(CacheFailure('Erro ao carregar unidades'));
      }

      final filtersData = DiagnosticoFiltersData(
        defensivos: defensivosResult.fold(
          (l) => <String>[],
          (r) => (r as List<Map<String, dynamic>>)
              .map((m) => m['id'] as String)
              .toList(),
        ),
        culturas: culturasResult.fold(
          (l) => <String>[],
          (r) => (r as List<Map<String, dynamic>>)
              .map((m) => m['id'] as String)
              .toList(),
        ),
        pragas: pragasResult.fold(
          (l) => <String>[],
          (r) => (r as List<Map<String, dynamic>>)
              .map((m) => m['id'] as String)
              .toList(),
        ),
        unidadesMedida: unidadesResult.fold(
          (l) => <String>[],
          (r) => r as List<String>,
        ),
        tiposAplicacao: TipoAplicacao.values, // Todos os tipos disponíveis
      );

      return Right(filtersData);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao obter dados de filtros: ${e.toString()}'),
      );
    }
  }
}
