import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/models/fitossanitario_hive.dart';
import '../../../../core/repositories/fitossanitario_core_repository.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../mappers/defensivo_mapper.dart';

/// Implementação do repositório de defensivos (Data Layer)
/// Conecta o domínio com o Core Package
class DefensivosRepositoryImpl implements IDefensivosRepository {
  final FitossanitarioCoreRepository _coreRepository;

  const DefensivosRepositoryImpl(this._coreRepository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final defensivosHive = await _coreRepository.getAllAsync();
      
      // Aplicar paginação se necessário
      List<dynamic> defensivosPaginated = defensivosHive;
      if (offset != null && offset > 0) {
        defensivosPaginated = defensivosHive.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        defensivosPaginated = defensivosPaginated.take(limit).toList();
      }
      
      final entities = defensivosPaginated
          .whereType<FitossanitarioHive>()
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivoEntity?>> getById(String id) async {
    try {
      final defensivoHive = await _coreRepository.getByIdAsync(id);
      if (defensivoHive == null) {
        return const Right(null);
      }
      
      final entity = DefensivoMapper.fromHive(defensivoHive);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivo por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getActiveDefensivos() async {
    try {
      final defensivosHive = await _coreRepository.getActiveDefensivosAsync();
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos ativos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getElegibleDefensivos() async {
    try {
      final defensivosHive = await _coreRepository.getElegibleDefensivosAsync();
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos elegíveis: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByNomeComum(
    String searchTerm,
  ) async {
    try {
      final defensivosHive = await _coreRepository.searchByNomeComumAsync(searchTerm);
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por nome comum: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByIngredienteAtivo(
    String searchTerm,
  ) async {
    try {
      final defensivosHive = await _coreRepository.searchByIngredienteAtivoAsync(searchTerm);
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por ingrediente ativo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByFabricante(
    String fabricante,
  ) async {
    try {
      final defensivosHive = await _coreRepository.searchByMultipleCriteriaAsync(
        fabricante: fabricante,
      );
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por fabricante: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByClasseAgronomica(
    String classe,
  ) async {
    try {
      final defensivosHive = await _coreRepository.searchByMultipleCriteriaAsync(
        classeAgronomica: classe,
      );
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por classe agronômica: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchByMultipleCriteria({
    String? nomeComum,
    String? ingredienteAtivo,
    String? fabricante,
    String? classeAgronomica,
    bool? status,
    int? comercializado,
    bool? elegivel,
  }) async {
    try {
      final defensivosHive = await _coreRepository.searchByMultipleCriteriaAsync(
        nomeComum: nomeComum,
        ingredienteAtivo: ingredienteAtivo,
        fabricante: fabricante,
        classeAgronomica: classeAgronomica,
        status: status,
        comercializado: comercializado,
        elegivel: elegivel,
      );
      
      final entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca múltipla: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchWithFilters(
    DefensivoSearchFilters filters,
  ) async {
    try {
      final defensivosHive = await _coreRepository.searchByMultipleCriteriaAsync(
        nomeComum: filters.nomeComum,
        ingredienteAtivo: filters.ingredienteAtivo,
        fabricante: filters.fabricante,
        classeAgronomica: filters.classeAgronomica,
        status: filters.status,
        comercializado: filters.comercializado,
        elegivel: filters.elegivel,
      );
      
      var entities = defensivosHive
          .map((hive) => DefensivoMapper.fromHive(hive))
          .toList();
      
      // Aplicar filtro de segurança se especificado
      if (filters.safetyLevel != null) {
        entities = entities
            .where((entity) => entity.safetyLevel == filters.safetyLevel)
            .toList();
      }
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllClassesAgronomicas() async {
    try {
      final classes = await _coreRepository.getAllClassesAgronomicasAsync();
      return Right(classes);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter classes agronômicas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllFabricantes() async {
    try {
      final fabricantes = await _coreRepository.getAllFabricantesAsync();
      return Right(fabricantes);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter fabricantes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllIngredientesAtivos() async {
    try {
      final ingredientes = await _coreRepository.getAllIngredientesAtivosAsync();
      return Right(ingredientes);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter ingredientes ativos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DefensivosStats>> getStatistics() async {
    try {
      final stats = await _coreRepository.getDefensivosStatsAsync();
      final statsEntity = DefensivoMapper.statsFromHiveStats(stats);
      return Right(statsEntity);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> countByFilters(
    DefensivoSearchFilters filters,
  ) async {
    try {
      final result = await searchWithFilters(filters);
      return result.fold(
        (failure) => Left(failure),
        (defensivos) => Right(defensivos.length),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao contar por filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    try {
      final result = await getById(id);
      return result.fold(
        (failure) => Left(failure),
        (defensivo) => Right(defensivo != null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getRelatedDefensivos(
    String defensivoId, {
    int limit = 5,
  }) async {
    try {
      // Busca o defensivo original
      final originalResult = await getById(defensivoId);
      if (originalResult.isLeft()) {
        return const Left(CacheFailure('Defensivo original não encontrado'));
      }

      final original = originalResult.fold(
        (failure) => null,
        (defensivo) => defensivo,
      );
      if (original == null) {
        return const Right(<DefensivoEntity>[]);
      }

      // Busca por defensivos com mesmo ingrediente ativo ou classe
      final relatedByIngrediente = original.hasIngredienteAtivo
          ? await searchByIngredienteAtivo(original.ingredienteAtivo!)
          : const Right(<DefensivoEntity>[]);

      final relatedByClasse = original.hasClasseAgronomica
          ? await searchByClasseAgronomica(original.classeAgronomica!)
          : const Right(<DefensivoEntity>[]);

      final related = <DefensivoEntity>[];
      
      // Adiciona defensivos por ingrediente ativo
      switch (relatedByIngrediente) {
        case Right(:final value):
          related.addAll(value as List<DefensivoEntity>);
        case Left():
          break;
      }
      
      // Adiciona defensivos por classe agronômica  
      switch (relatedByClasse) {
        case Right(:final value):
          related.addAll(value as List<DefensivoEntity>);
        case Left():
          break;
      }

      // Remove duplicatas e o defensivo original
      final uniqueRelated = related
          .where((d) => d.id != defensivoId)
          .toSet()
          .take(limit)
          .toList();

      return Right(uniqueRelated);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar relacionados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getPopularDefensivos({
    int limit = 10,
  }) async {
    try {
      // Por enquanto, retorna defensivos ativos ordenados por nome
      // TODO: Implementar lógica de popularidade baseada em uso
      final result = await getActiveDefensivos();
      return result.fold(
        (failure) => Left(failure),
        (defensivos) {
          defensivos.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          return Right(defensivos.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar populares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getRecentDefensivos({
    int limit = 10,
  }) async {
    try {
      // Por enquanto, retorna defensivos elegíveis
      // TODO: Implementar lógica de recentes baseada em timestamp
      final result = await getElegibleDefensivos();
      return result.fold(
        (failure) => Left(failure),
        (defensivos) => Right(defensivos.take(limit).toList()),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar recentes: ${e.toString()}'));
    }
  }
}