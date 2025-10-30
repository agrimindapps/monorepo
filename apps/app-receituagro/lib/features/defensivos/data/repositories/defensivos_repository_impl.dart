import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/repositories/fitossanitario_hive_repository.dart';
import '../../domain/entities/defensivo_entity.dart';
import '../../domain/repositories/i_defensivos_repository.dart';
import '../mappers/defensivo_mapper.dart';
import '../services/defensivos_filter_service.dart';
import '../services/defensivos_query_service.dart';
import '../services/defensivos_search_service.dart';
import '../services/defensivos_stats_service.dart';

/// Implementação do repositório de defensivos
/// Segue padrões Clean Architecture + Either pattern para error handling
///
/// SOLID Refactoring:
/// - Separated query logic to DefensivosQueryService (SRP)
/// - Separated search logic to DefensivosSearchService (SRP)
/// - Separated stats logic to DefensivosStatsService (SRP)
/// - Separated filter/sort logic to DefensivosFilterService (SRP)
/// - Repository now focuses only on CRUD operations
/// - All dependencies injected to improve testability (DIP)
///
/// This follows the pattern established in diagnosticos and comentarios features.
@LazySingleton(as: IDefensivosRepository)
class DefensivosRepositoryImpl implements IDefensivosRepository {
  final FitossanitarioHiveRepository _repository;
  final IDefensivosQueryService _queryService;
  final IDefensivosSearchService _searchService;
  final IDefensivosStatsService _statsService;
  final IDefensivosFilterService _filterService;

  DefensivosRepositoryImpl(
    this._repository,
    this._queryService,
    this._searchService,
    this._statsService,
    this._filterService,
  );

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getAllDefensivos() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }
      final defensivosHive = result.data ?? [];
      final defensivosEntities = DefensivoMapper.fromHiveToEntityList(
        defensivosHive,
      );

      return Right(defensivosEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByClasse(
    String classe,
  ) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }
      final allDefensivos = result.data ?? [];

      // Convert to entities and use search service
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);
      final defensivosFiltrados = _searchService.searchAdvanced(
        defensivosEntities,
        classeQuery: classe,
      );

      return Right(defensivosFiltrados);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar defensivos por classe: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, DefensivoEntity?>> getDefensivoById(String id) async {
    try {
      final result = await _repository.getByKey(id);
      if (result.isFailure) {
        return Left(
          CacheFailure(
            'Erro ao buscar defensivo por ID: ${result.error?.message}',
          ),
        );
      }
      final defensivo = result.data;

      if (defensivo == null) {
        return const Right(null);
      }

      final defensivoEntity = DefensivoMapper.fromHiveToEntity(defensivo);
      return Right(defensivoEntity);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar defensivo por ID: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> searchDefensivos(
    String query,
  ) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate search to service
      final defensivosFiltrados = _searchService.search(
        defensivosEntities,
        query,
      );

      return Right(defensivosFiltrados);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao pesquisar defensivos: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByFabricante(
    String fabricante,
  ) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate search to service
      final defensivosFiltrados = _searchService.searchAdvanced(
        defensivosEntities,
        nomeQuery: fabricante,
      );

      return Right(defensivosFiltrados);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar defensivos por fabricante: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosByModoAcao(
    String modoAcao,
  ) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Note: Should have a dedicated filter for modoAcao in future
      // For now use custom search
      final defensivosFiltrados = _searchService.searchCustom(
        defensivosEntities,
        (d) => d.modoAcao?.toLowerCase().contains(modoAcao.toLowerCase()) == true,
      );

      return Right(defensivosFiltrados);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar defensivos por modo de ação: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getClassesAgronomicas() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate to query service
      final classes = _queryService.getClassesAgronomicas(defensivosEntities);
      return Right(classes);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar classes agronômicas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFabricantes() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate to query service
      final fabricantes = _queryService.getFabricantes(defensivosEntities);
      return Right(fabricantes);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar fabricantes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getModosAcao() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate to query service
      final modosAcao = _queryService.getModosAcao(defensivosEntities);
      return Right(modosAcao);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar modos de ação: {{e.toString()}}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosRecentes({
    int limit = 10,
  }) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate to query service
      final defensivosRecentes =
          _queryService.getRecentes(defensivosEntities, limit: limit);

      return Right(defensivosRecentes);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar defensivos recentes: {{e.toString()}}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDefensivosStats() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate to stats service
      final stats = _statsService.calculateStats(defensivosEntities);

      return Right(stats);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar estatísticas dos defensivos: {{e.toString()}}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isDefensivoActive(String defensivoId) async {
    try {
      final result = await _repository.getByKey(defensivoId);
      if (result.isFailure) {
        return Left(
          CacheFailure(
            'Erro ao verificar status do defensivo: ${result.error?.message}',
          ),
        );
      }

      final defensivo = result.data;
      if (defensivo == null) {
        return const Right(false);
      }

      final defensivoEntity = DefensivoMapper.fromHiveToEntity(defensivo);
      // Delegate to query service
      final isActive = _queryService.isDefensivoActive(
        [defensivoEntity],
        defensivoId,
      );

      return Right(isActive);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao verificar status do defensivo: {{e.toString()}}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    try {
      debugPrint('🔍 [REPO AGRUPADOS] Buscando todos os defensivos do Hive...');
      final result = await _repository.getAll();
      if (result.isFailure) {
        debugPrint(
          '❌ [REPO AGRUPADOS] Erro ao buscar defensivos: ${result.error?.message}',
        );
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final allDefensivos = result.data ?? [];
      debugPrint(
        '✅ [REPO AGRUPADOS] Defensivos retornados do Hive: ${allDefensivos.length} itens',
      );

      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Apply text filter if provided
      var defensivosFiltrados = defensivosEntities;
      if (filtroTexto != null && filtroTexto.isNotEmpty) {
        defensivosFiltrados = _searchService.searchAdvanced(
          defensivosEntities,
          nomeQuery: filtroTexto,
          ingredienteQuery: filtroTexto,
          classeQuery: filtroTexto,
        );
        debugPrint(
          '📊 [REPO AGRUPADOS] Após filtro de texto: ${defensivosFiltrados.length} itens',
        );
      }

      debugPrint(
        '✅ [REPO AGRUPADOS] Entidades criadas: ${defensivosFiltrados.length} itens',
      );

      return Right(defensivosFiltrados);
    } catch (e) {
      debugPrint('❌ [REPO AGRUPADOS] Erro: $e');
      return Left(
        CacheFailure('Erro ao buscar defensivos agrupados: {{e.toString()}}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>>
  getDefensivosCompletos() async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }
      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          allDefensivos.map((hive) {
            return DefensivoMapper.fromHiveToEntity(hive).copyWith(
              quantidadeDiagnosticos: 0,
              nivelPrioridade: 1,
              isComercializado: hive.status,
              isElegivel: hive.status,
            );
          }).toList();

      return Right(defensivosEntities);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar defensivos completos: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosComFiltros({
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool apenasComercializados = false,
    bool apenasElegiveis = false,
  }) async {
    try {
      final result = await _repository.getAll();
      if (result.isFailure) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: {{result.error?.message}}'),
        );
      }

      final allDefensivos = result.data ?? [];
      final defensivosEntities =
          DefensivoMapper.fromHiveToEntityList(allDefensivos);

      // Delegate all filtering and sorting to service
      final defensivosFiltrados = _filterService.filterAndSort(
        defensivos: defensivosEntities,
        ordenacao: ordenacao,
        filtroToxicidade: filtroToxicidade,
        filtroTipo: filtroTipo,
        apenasComercializados: apenasComercializados,
        apenasElegiveis: apenasElegiveis,
      );

      return Right(defensivosFiltrados);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar defensivos com filtros: {{e.toString()}}',
        ),
      );
    }
  }
}
