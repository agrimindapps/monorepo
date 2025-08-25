import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/cultura_entity.dart';

/// Interface do repositório de culturas (Domain Layer)
/// Define contratos para acesso aos dados seguindo Dependency Inversion Principle
abstract class ICulturasRepository {
  /// Busca todas as culturas com paginação opcional
  Future<Either<Failure, List<CulturaEntity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Busca cultura por ID
  Future<Either<Failure, CulturaEntity?>> getById(String id);

  /// Busca culturas ativas
  Future<Either<Failure, List<CulturaEntity>>> getActiveCulturas();

  /// Busca cultura por nome exato
  Future<Either<Failure, CulturaEntity?>> getByNome(String nome);

  /// Busca culturas por nome (busca parcial)
  Future<Either<Failure, List<CulturaEntity>>> searchByNome(String searchTerm);

  /// Busca culturas por família
  Future<Either<Failure, List<CulturaEntity>>> searchByFamilia(String familia);

  /// Busca culturas por tipo
  Future<Either<Failure, List<CulturaEntity>>> searchByTipo(CulturaTipo tipo);

  /// Busca culturas por múltiplos critérios
  Future<Either<Failure, List<CulturaEntity>>> searchByMultipleCriteria({
    String? nome,
    String? familia,
    String? categoria,
    CulturaTipo? tipo,
    bool? isAtiva,
  });

  /// Busca com filtros estruturados
  Future<Either<Failure, List<CulturaEntity>>> searchWithFilters(
    CulturaSearchFilters filters,
  );

  /// Obter estatísticas das culturas
  Future<Either<Failure, CulturasStats>> getStatistics();

  /// Obter culturas populares/mais usadas
  Future<Either<Failure, List<CulturaPopular>>> getPopularCulturas({
    int limit = 10,
  });

  /// Obter culturas relacionadas (mesmo tipo/família)
  Future<Either<Failure, List<CulturaEntity>>> getRelatedCulturas(
    String culturaId, {
    int limit = 5,
  });

  /// Verificar se cultura existe
  Future<Either<Failure, bool>> exists(String id);

  /// Verificar se cultura existe por nome
  Future<Either<Failure, bool>> existsByNome(String nome);

  /// Contar culturas por filtros
  Future<Either<Failure, int>> countByFilters(CulturaSearchFilters filters);

  /// Obter todos os tipos de cultura disponíveis
  Future<Either<Failure, List<CulturaTipo>>> getAllTipos();

  /// Obter todas as famílias de cultura disponíveis
  Future<Either<Failure, List<String>>> getAllFamilias();

  /// Obter todas as categorias de cultura disponíveis
  Future<Either<Failure, List<String>>> getAllCategorias();

  /// Buscar culturas recentes (baseado em data de criação/atualização)
  Future<Either<Failure, List<CulturaEntity>>> getRecentCulturas({
    int limit = 10,
  });

  /// Validar dados da cultura
  Future<Either<Failure, bool>> validateCulturaData(CulturaEntity cultura);

  /// Buscar culturas por padrão no nome ou descrição
  Future<Either<Failure, List<CulturaEntity>>> searchByPattern(String pattern);
}

/// Interface para dados de filtros de culturas
/// Usado para popular dropdowns e widgets de filtro
abstract class ICulturaFiltersDataRepository {
  /// Obter dados para montagem de filtros (famílias, tipos, etc.)
  Future<Either<Failure, CulturaFiltersData>> getFiltersData();
}