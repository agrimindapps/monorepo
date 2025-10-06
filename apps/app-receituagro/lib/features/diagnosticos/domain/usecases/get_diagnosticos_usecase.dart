import 'package:core/core.dart';

import '../entities/diagnostico_entity.dart';
import '../repositories/i_diagnosticos_repository.dart';

/// Use Case para buscar todos os diagnósticos
class GetDiagnosticosUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _repository.getAll(limit: limit, offset: offset);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
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
        return const Left(ValidationFailure('ID do diagnóstico não pode ser vazio'));
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
        return const Left(ValidationFailure('ID da cultura não pode ser vazio'));
      }
      if (idPraga.trim().isEmpty) {
        return const Left(ValidationFailure('ID da praga não pode ser vazio'));
      }

      return await _repository.getRecomendacoesPara(
        idCultura: idCultura,
        idPraga: idPraga,
        limit: limit,
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar recomendações: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar por defensivo
class GetDiagnosticosByDefensivoUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosByDefensivoUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(String idDefensivo) async {
    try {
      if (idDefensivo.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo não pode ser vazio'));
      }

      return await _repository.getByDefensivo(idDefensivo);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por defensivo: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar por cultura
class GetDiagnosticosByCulturaUseCase {
  final IDiagnosticosRepository _repository;

  const GetDiagnosticosByCulturaUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(String idCultura) async {
    try {
      if (idCultura.trim().isEmpty) {
        return const Left(ValidationFailure('ID da cultura não pode ser vazio'));
      }

      return await _repository.getByCultura(idCultura);
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

      return await _repository.getByPraga(idPraga);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por praga: ${e.toString()}'));
    }
  }
}

/// Use Case para busca com filtros
class SearchDiagnosticosWithFiltersUseCase {
  final IDiagnosticosRepository _repository;

  const SearchDiagnosticosWithFiltersUseCase(this._repository);

  Future<Either<Failure, List<DiagnosticoEntity>>> call(DiagnosticoSearchFilters filters) async {
    try {
      return await _repository.searchWithFilters(filters);
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
      return await _repository.getStatistics();
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
        return const Left(ValidationFailure('ID do defensivo não pode ser vazio'));
      }
      if (idCultura.trim().isEmpty) {
        return const Left(ValidationFailure('ID da cultura não pode ser vazio'));
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
        return const Left(ValidationFailure('Padrão de busca deve ter pelo menos 2 caracteres'));
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
        defensivos: defensivosResult.fold((l) => <String>[], (r) => r),
        culturas: culturasResult.fold((l) => <String>[], (r) => r),
        pragas: pragasResult.fold((l) => <String>[], (r) => r),
        unidadesMedida: unidadesResult.fold((l) => <String>[], (r) => r),
        tiposAplicacao: TipoAplicacao.values, // Todos os tipos disponíveis
      );

      return Right(filtersData);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados de filtros: ${e.toString()}'));
    }
  }
}
