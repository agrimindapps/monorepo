import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';

/// Use Case para buscar todos os defensivos
class GetDefensivosUseCase {
  final IDefensivosRepository _repository;

  const GetDefensivosUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _repository.getAll(limit: limit, offset: offset);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivos ativos
class GetActiveDefensivosUseCase {
  final IDefensivosRepository _repository;

  const GetActiveDefensivosUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call() async {
    try {
      return await _repository.getActiveDefensivos();
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos ativos: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivos elegíveis
class GetElegibleDefensivosUseCase {
  final IDefensivosRepository _repository;

  const GetElegibleDefensivosUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call() async {
    try {
      return await _repository.getElegibleDefensivos();
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos elegíveis: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivo por ID
class GetDefensivoByIdUseCase {
  final IDefensivosRepository _repository;
  final IDefensivosHistoryRepository? _historyRepository;

  const GetDefensivoByIdUseCase(
    this._repository, [
    this._historyRepository,
  ]);

  Future<Either<Failure, DefensivoEntity?>> call(String id) async {
    try {
      if (id.trim().isEmpty) {
        return const Left(ValidationFailure('ID não pode ser vazio'));
      }

      final result = await _repository.getById(id);
      
      return result.fold(
        (failure) => Left(failure),
        (defensivo) async {
          // Marcar como acessado se encontrado
          if (defensivo != null && _historyRepository != null) {
            await _historyRepository.markAsAccessed(id);
          }
          return Right(defensivo);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivo: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivos por nome comum
class SearchDefensivosByNomeUseCase {
  final IDefensivosRepository _repository;

  const SearchDefensivosByNomeUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return const Right([]);
      }

      return await _repository.searchByNomeComum(searchTerm.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por nome: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivos por ingrediente ativo
class SearchDefensivosByIngredienteUseCase {
  final IDefensivosRepository _repository;

  const SearchDefensivosByIngredienteUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return const Right([]);
      }

      return await _repository.searchByIngredienteAtivo(searchTerm.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por ingrediente: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivos por fabricante
class SearchDefensivosByFabricanteUseCase {
  final IDefensivosRepository _repository;

  const SearchDefensivosByFabricanteUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call(String fabricante) async {
    try {
      if (fabricante.trim().isEmpty) {
        return const Right([]);
      }

      return await _repository.searchByFabricante(fabricante.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por fabricante: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar defensivos por classe agronômica
class SearchDefensivosByClasseUseCase {
  final IDefensivosRepository _repository;

  const SearchDefensivosByClasseUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call(String classe) async {
    try {
      if (classe.trim().isEmpty) {
        return const Right([]);
      }

      return await _repository.searchByClasseAgronomica(classe.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por classe: ${e.toString()}'));
    }
  }
}

/// Use Case para busca avançada com filtros
class SearchDefensivosAdvancedUseCase {
  final IDefensivosRepository _repository;

  const SearchDefensivosAdvancedUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call(
    DefensivoSearchFilters filters,
  ) async {
    try {
      if (!filters.hasFilters) {
        return const Right([]);
      }

      return await _repository.searchWithFilters(filters);
    } catch (e) {
      return Left(CacheFailure('Erro na busca avançada: ${e.toString()}'));
    }
  }
}

/// Use Case para obter estatísticas
class GetDefensivosStatsUseCase {
  final IDefensivosRepository _repository;

  const GetDefensivosStatsUseCase(this._repository);

  Future<Either<Failure, DefensivosStats>> call() async {
    try {
      return await _repository.getStatistics();
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }
}

/// Use Case para obter listas de filtros
class GetDefensivosFiltersUseCase {
  final IDefensivosRepository _repository;

  const GetDefensivosFiltersUseCase(this._repository);

  Future<Either<Failure, DefensivosFiltersData>> call() async {
    try {
      final futures = await Future.wait([
        _repository.getAllClassesAgronomicas(),
        _repository.getAllFabricantes(),
        _repository.getAllIngredientesAtivos(),
      ]);

      final classesResult = futures[0];
      final fabricantesResult = futures[1];
      final ingredientesResult = futures[2];

      // Verifica se algum resultado é erro
      if (classesResult.isLeft()) {
        return Left(CacheFailure('Erro ao carregar classes agronômicas'));
      }
      if (fabricantesResult.isLeft()) {
        return Left(CacheFailure('Erro ao carregar fabricantes'));
      }
      if (ingredientesResult.isLeft()) {
        return Left(CacheFailure('Erro ao carregar ingredientes ativos'));
      }

      final filtersData = DefensivosFiltersData(
        classesAgronomicas: classesResult.getOrElse(() => []),
        fabricantes: fabricantesResult.getOrElse(() => []),
        ingredientesAtivos: ingredientesResult.getOrElse(() => []),
      );

      return Right(filtersData);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter filtros: ${e.toString()}'));
    }
  }
}

/// Use Case para defensivos relacionados
class GetRelatedDefensivosUseCase {
  final IDefensivosRepository _repository;

  const GetRelatedDefensivosUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call(
    String defensivoId, {
    int limit = 5,
  }) async {
    try {
      if (defensivoId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do defensivo não pode ser vazio'));
      }

      return await _repository.getRelatedDefensivos(defensivoId, limit: limit);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar relacionados: ${e.toString()}'));
    }
  }
}

/// Use Case para defensivos populares
class GetPopularDefensivosUseCase {
  final IDefensivosRepository _repository;

  const GetPopularDefensivosUseCase(this._repository);

  Future<Either<Failure, List<DefensivoEntity>>> call({int limit = 10}) async {
    try {
      return await _repository.getPopularDefensivos(limit: limit);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar populares: ${e.toString()}'));
    }
  }
}

/// Use Case para defensivos recentes
class GetRecentDefensivosUseCase {
  final IDefensivosHistoryRepository _historyRepository;

  const GetRecentDefensivosUseCase(this._historyRepository);

  Future<Either<Failure, List<DefensivoEntity>>> call({int limit = 10}) async {
    try {
      final defensivos = await _historyRepository.getRecentlyAccessed(limit: limit);
      return Right(defensivos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar recentes: ${e.toString()}'));
    }
  }
}

/// Value Object para dados de filtros
class DefensivosFiltersData {
  final List<String> classesAgronomicas;
  final List<String> fabricantes;
  final List<String> ingredientesAtivos;

  const DefensivosFiltersData({
    required this.classesAgronomicas,
    required this.fabricantes,
    required this.ingredientesAtivos,
  });
}