import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/defensivo_entity.dart';

/// Interface do repositório de defensivos (Domain Layer)
/// Princípio: Dependency Inversion + Repository Pattern
abstract class IDefensivosRepository {
  /// Buscar todos os defensivos
  Future<Either<Failure, List<DefensivoEntity>>> getAll({
    int? limit,
    int? offset,
  });

  /// Buscar defensivo por ID
  Future<Either<Failure, DefensivoEntity?>> getById(String id);

  /// Buscar apenas defensivos ativos
  Future<Either<Failure, List<DefensivoEntity>>> getActiveDefensivos();

  /// Buscar apenas defensivos elegíveis
  Future<Either<Failure, List<DefensivoEntity>>> getElegibleDefensivos();

  /// Buscar por nome comum
  Future<Either<Failure, List<DefensivoEntity>>> searchByNomeComum(String searchTerm);

  /// Buscar por ingrediente ativo
  Future<Either<Failure, List<DefensivoEntity>>> searchByIngredienteAtivo(String searchTerm);

  /// Buscar por fabricante
  Future<Either<Failure, List<DefensivoEntity>>> searchByFabricante(String fabricante);

  /// Buscar por classe agronômica
  Future<Either<Failure, List<DefensivoEntity>>> searchByClasseAgronomica(String classe);

  /// Buscar com múltiplos critérios
  Future<Either<Failure, List<DefensivoEntity>>> searchByMultipleCriteria({
    String? nomeComum,
    String? ingredienteAtivo,
    String? fabricante,
    String? classeAgronomica,
    bool? status,
    int? comercializado,
    bool? elegivel,
  });

  /// Buscar com filtros avançados
  Future<Either<Failure, List<DefensivoEntity>>> searchWithFilters(
    DefensivoSearchFilters filters,
  );

  /// Obter todas as classes agronômicas únicas
  Future<Either<Failure, List<String>>> getAllClassesAgronomicas();

  /// Obter todos os fabricantes únicos
  Future<Either<Failure, List<String>>> getAllFabricantes();

  /// Obter todos os ingredientes ativos únicos
  Future<Either<Failure, List<String>>> getAllIngredientesAtivos();

  /// Obter estatísticas dos defensivos
  Future<Either<Failure, DefensivosStats>> getStatistics();

  /// Contar defensivos por filtros
  Future<Either<Failure, int>> countByFilters(DefensivoSearchFilters filters);

  /// Verificar se existe defensivo por ID
  Future<Either<Failure, bool>> exists(String id);

  /// Buscar defensivos relacionados (por ingrediente ativo ou classe)
  Future<Either<Failure, List<DefensivoEntity>>> getRelatedDefensivos(
    String defensivoId, {
    int limit = 5,
  });

  /// Buscar defensivos populares/mais acessados
  Future<Either<Failure, List<DefensivoEntity>>> getPopularDefensivos({
    int limit = 10,
  });

  /// Buscar defensivos recentes
  Future<Either<Failure, List<DefensivoEntity>>> getRecentDefensivos({
    int limit = 10,
  });
}

/// Interface para histórico e cache de defensivos
abstract class IDefensivosHistoryRepository {
  /// Marcar defensivo como acessado
  Future<void> markAsAccessed(String defensivoId);

  /// Obter defensivos recentemente acessados
  Future<List<DefensivoEntity>> getRecentlyAccessed({int limit = 10});

  /// Obter defensivos sugeridos baseados no histórico
  Future<List<DefensivoEntity>> getSuggested({int limit = 5});

  /// Limpar histórico
  Future<void> clearHistory();

  /// Obter estatísticas de uso
  Future<Map<String, int>> getUsageStats();
}

/// Interface para cache de defensivos
abstract class IDefensivosCacheRepository {
  /// Obter do cache
  Future<List<DefensivoEntity>?> getCached(String key);

  /// Salvar no cache
  Future<void> saveToCache(String key, List<DefensivoEntity> defensivos);

  /// Invalidar cache
  Future<void> invalidateCache([String? key]);

  /// Verificar se tem cache válido
  Future<bool> hasCachedData(String key);
}