import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/cultura_entity.dart';
import '../repositories/i_culturas_repository.dart';

/// Use Case para buscar todas as culturas
/// Implementa Template Method Pattern e Single Responsibility Principle
class GetCulturasUseCase {
  final ICulturasRepository _repository;

  const GetCulturasUseCase(this._repository);

  /// Busca todas as culturas com paginação opcional
  Future<Either<Failure, List<CulturaEntity>>> call({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _repository.getAll(limit: limit, offset: offset);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar cultura por ID
class GetCulturaByIdUseCase {
  final ICulturasRepository _repository;

  const GetCulturaByIdUseCase(this._repository);

  /// Busca cultura por ID específico
  Future<Either<Failure, CulturaEntity?>> call(String id) async {
    try {
      if (id.trim().isEmpty) {
        return Left(ValidationFailure('ID da cultura não pode ser vazio'));
      }

      return await _repository.getById(id);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cultura por ID: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar culturas ativas
class GetActiveCulturasUseCase {
  final ICulturasRepository _repository;

  const GetActiveCulturasUseCase(this._repository);

  /// Busca apenas culturas ativas
  Future<Either<Failure, List<CulturaEntity>>> call() async {
    try {
      return await _repository.getActiveCulturas();
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas ativas: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar cultura por nome
class GetCulturaByNomeUseCase {
  final ICulturasRepository _repository;

  const GetCulturaByNomeUseCase(this._repository);

  /// Busca cultura por nome exato
  Future<Either<Failure, CulturaEntity?>> call(String nome) async {
    try {
      if (nome.trim().isEmpty) {
        return Left(ValidationFailure('Nome da cultura não pode ser vazio'));
      }

      return await _repository.getByNome(nome.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cultura por nome: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar culturas por nome (busca parcial)
class SearchCulturasByNomeUseCase {
  final ICulturasRepository _repository;

  const SearchCulturasByNomeUseCase(this._repository);

  /// Busca culturas por termo de pesquisa no nome
  Future<Either<Failure, List<CulturaEntity>>> call(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return const Right(<CulturaEntity>[]);
      }

      if (searchTerm.trim().length < 2) {
        return Left(ValidationFailure('Termo de busca deve ter pelo menos 2 caracteres'));
      }

      return await _repository.searchByNome(searchTerm.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas por nome: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar culturas por família
class SearchCulturasByFamiliaUseCase {
  final ICulturasRepository _repository;

  const SearchCulturasByFamiliaUseCase(this._repository);

  /// Busca culturas por família
  Future<Either<Failure, List<CulturaEntity>>> call(String familia) async {
    try {
      if (familia.trim().isEmpty) {
        return Left(ValidationFailure('Família não pode ser vazia'));
      }

      return await _repository.searchByFamilia(familia.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas por família: ${e.toString()}'));
    }
  }
}

/// Use Case para buscar culturas por tipo
class SearchCulturasByTipoUseCase {
  final ICulturasRepository _repository;

  const SearchCulturasByTipoUseCase(this._repository);

  /// Busca culturas por tipo específico
  Future<Either<Failure, List<CulturaEntity>>> call(CulturaTipo tipo) async {
    try {
      return await _repository.searchByTipo(tipo);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas por tipo: ${e.toString()}'));
    }
  }
}

/// Use Case para busca avançada com múltiplos critérios
class SearchCulturasWithFiltersUseCase {
  final ICulturasRepository _repository;

  const SearchCulturasWithFiltersUseCase(this._repository);

  /// Busca culturas usando filtros estruturados
  Future<Either<Failure, List<CulturaEntity>>> call(CulturaSearchFilters filters) async {
    try {
      // Validação básica dos filtros
      if (!filters.hasFilters) {
        // Se não há filtros, retorna culturas ativas
        return await _repository.getActiveCulturas();
      }

      // Validação de nome mínimo se presente
      if (filters.nome != null && filters.nome!.trim().length < 2) {
        return Left(ValidationFailure('Nome deve ter pelo menos 2 caracteres'));
      }

      return await _repository.searchWithFilters(filters);
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }
}

/// Use Case para obter estatísticas das culturas
class GetCulturaStatsUseCase {
  final ICulturasRepository _repository;

  const GetCulturaStatsUseCase(this._repository);

  /// Obtém estatísticas gerais das culturas
  Future<Either<Failure, CulturasStats>> call() async {
    try {
      return await _repository.getStatistics();
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }
}

/// Use Case para obter culturas populares
class GetPopularCulturasUseCase {
  final ICulturasRepository _repository;

  const GetPopularCulturasUseCase(this._repository);

  /// Obtém lista de culturas mais populares
  Future<Either<Failure, List<CulturaPopular>>> call({int limit = 10}) async {
    try {
      if (limit <= 0) {
        return Left(ValidationFailure('Limite deve ser maior que zero'));
      }

      return await _repository.getPopularCulturas(limit: limit);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas populares: ${e.toString()}'));
    }
  }
}

/// Use Case para obter culturas relacionadas
class GetRelatedCulturasUseCase {
  final ICulturasRepository _repository;

  const GetRelatedCulturasUseCase(this._repository);

  /// Obtém culturas relacionadas a uma cultura específica
  Future<Either<Failure, List<CulturaEntity>>> call(
    String culturaId, {
    int limit = 5,
  }) async {
    try {
      if (culturaId.trim().isEmpty) {
        return Left(ValidationFailure('ID da cultura não pode ser vazio'));
      }

      if (limit <= 0) {
        return Left(ValidationFailure('Limite deve ser maior que zero'));
      }

      return await _repository.getRelatedCulturas(culturaId, limit: limit);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas relacionadas: ${e.toString()}'));
    }
  }
}

/// Use Case para verificar existência de cultura
class CheckCulturaExistsUseCase {
  final ICulturasRepository _repository;

  const CheckCulturaExistsUseCase(this._repository);

  /// Verifica se cultura existe por ID
  Future<Either<Failure, bool>> call(String id) async {
    try {
      if (id.trim().isEmpty) {
        return Left(ValidationFailure('ID da cultura não pode ser vazio'));
      }

      return await _repository.exists(id);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: ${e.toString()}'));
    }
  }
}

/// Use Case para verificar existência de cultura por nome
class CheckCulturaExistsByNomeUseCase {
  final ICulturasRepository _repository;

  const CheckCulturaExistsByNomeUseCase(this._repository);

  /// Verifica se cultura existe por nome
  Future<Either<Failure, bool>> call(String nome) async {
    try {
      if (nome.trim().isEmpty) {
        return Left(ValidationFailure('Nome da cultura não pode ser vazio'));
      }

      return await _repository.existsByNome(nome.trim());
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência por nome: ${e.toString()}'));
    }
  }
}

/// Use Case para obter dados para filtros
class GetCulturaFiltersDataUseCase {
  final ICulturasRepository _repository;

  const GetCulturaFiltersDataUseCase(this._repository);

  /// Obtém dados necessários para montar filtros de busca
  Future<Either<Failure, CulturaFiltersData>> call() async {
    try {
      // Busca todos os dados em paralelo
      final futures = await Future.wait([
        _repository.getAllFamilias(),
        _repository.getAllCategorias(),
        _repository.getAllTipos(),
      ]);

      final familiasResult = futures[0];
      final categoriasResult = futures[1];
      final tiposResult = futures[2];

      // Verifica se algum resultado é erro
      if (familiasResult.isLeft()) {
        return Left(CacheFailure('Erro ao carregar famílias'));
      }
      if (categoriasResult.isLeft()) {
        return Left(CacheFailure('Erro ao carregar categorias'));
      }
      if (tiposResult.isLeft()) {
        return Left(CacheFailure('Erro ao carregar tipos'));
      }

      final filtersData = CulturaFiltersData(
        familias: familiasResult.fold((l) => <String>[], (r) => r as List<String>),
        categorias: categoriasResult.fold((l) => <String>[], (r) => r as List<String>),
        tipos: tiposResult.fold((l) => <CulturaTipo>[], (r) => r as List<CulturaTipo>),
      );

      return Right(filtersData);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados de filtros: ${e.toString()}'));
    }
  }
}

/// Use Case para validar dados de cultura
class ValidateCulturaDataUseCase {
  final ICulturasRepository _repository;

  const ValidateCulturaDataUseCase(this._repository);

  /// Valida os dados de uma cultura
  Future<Either<Failure, bool>> call(CulturaEntity cultura) async {
    try {
      // Validações básicas
      if (!cultura.isValid) {
        return Left(ValidationFailure('Dados da cultura são inválidos'));
      }

      // Validação via repository (pode verificar duplicatas, etc.)
      return await _repository.validateCulturaData(cultura);
    } catch (e) {
      return Left(ValidationFailure('Erro na validação: ${e.toString()}'));
    }
  }
}

/// Use Case para busca por padrão geral
class SearchCulturasByPatternUseCase {
  final ICulturasRepository _repository;

  const SearchCulturasByPatternUseCase(this._repository);

  /// Busca culturas por padrão no nome ou descrição
  Future<Either<Failure, List<CulturaEntity>>> call(String pattern) async {
    try {
      if (pattern.trim().isEmpty) {
        return const Right(<CulturaEntity>[]);
      }

      if (pattern.trim().length < 2) {
        return Left(ValidationFailure('Padrão de busca deve ter pelo menos 2 caracteres'));
      }

      return await _repository.searchByPattern(pattern.trim());
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }
}