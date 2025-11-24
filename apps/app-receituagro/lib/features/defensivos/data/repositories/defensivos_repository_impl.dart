import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../database/repositories/fitossanitarios_info_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
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

class DefensivosRepositoryImpl implements IDefensivosRepository {
  final FitossanitariosRepository _repository;
  final FitossanitariosInfoRepository _infoRepository;
  final IDefensivosQueryService _queryService;
  final IDefensivosSearchService _searchService;
  final IDefensivosStatsService _statsService;
  final IDefensivosFilterService _filterService;

  DefensivosRepositoryImpl(
    this._repository,
    this._infoRepository,
    this._queryService,
    this._searchService,
    this._statsService,
    this._filterService,
  );

  Future<Map<int, String?>> _fetchInfoMap() async {
    final infos = await _infoRepository.findAll();
    return {for (var i in infos) i.defensivoId: i.modoAcao};
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getAllDefensivos() async {
    try {
      final allDrift = await _repository.findAll();
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDrift,
        infoMap: infoMap,
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
      final allDrift = await _repository.findAll();
      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();

      // Convert to entities and use search service
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );
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
      final defensivo = await _repository.findByIdDefensivo(id);

      if (defensivo == null) {
        return const Right(null);
      }

      final info = await _infoRepository.findByDefensivoId(defensivo.id);
      final defensivoEntity = DefensivoMapper.fromDriftToEntity(
        defensivo,
        modoAcao: info?.modoAcao,
      );
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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

      // Note: Should have a dedicated filter for modoAcao in future
      // For now use custom search
      final defensivosFiltrados = _searchService.searchCustom(
        defensivosEntities,
        (d) =>
            d.modoAcao?.toLowerCase().contains(modoAcao.toLowerCase()) == true,
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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

      // Delegate to query service
      final modosAcao = _queryService.getModosAcao(defensivosEntities);
      return Right(modosAcao);
    } catch (e) {
      return const Left(
        CacheFailure('Erro ao buscar modos de ação: {{e.toString()}}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosRecentes({
    int limit = 10,
  }) async {
    try {
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

      // Delegate to query service
      final defensivosRecentes = _queryService.getRecentes(
        defensivosEntities,
        limit: limit,
      );

      return Right(defensivosRecentes);
    } catch (e) {
      return const Left(
        CacheFailure('Erro ao buscar defensivos recentes: {{e.toString()}}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDefensivosStats() async {
    try {
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

      // Delegate to stats service
      final stats = _statsService.calculateStats(defensivosEntities);

      return Right(stats);
    } catch (e) {
      return const Left(
        CacheFailure(
          'Erro ao buscar estatísticas dos defensivos: {{e.toString()}}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isDefensivoActive(String defensivoId) async {
    try {
      final defensivo = await _repository.findByIdDefensivo(defensivoId);

      if (defensivo == null) {
        return const Right(false);
      }

      final info = await _infoRepository.findByDefensivoId(defensivo.id);
      final defensivoEntity = DefensivoMapper.fromDriftToEntity(
        defensivo,
        modoAcao: info?.modoAcao,
      );
      // Delegate to query service
      final isActive = _queryService.isDefensivoActive([
        defensivoEntity,
      ], defensivoId);

      return Right(isActive);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao verificar status do defensivo: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>> getDefensivosAgrupados({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    try {
      debugPrint(
        '🔍 [REPO AGRUPADOS] Buscando todos os defensivos do banco de dados...',
      );
      final allDefensivos = await _repository.findAll();

      debugPrint(
        '✅ [REPO AGRUPADOS] Defensivos retornados: ${allDefensivos.length} itens',
      );

      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

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
        CacheFailure('Erro ao buscar defensivos agrupados: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DefensivoEntity>>>
  getDefensivosCompletos() async {
    try {
      final allDrift = await _repository.findAll();
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = allDrift.map((drift) {
        final modoAcao = infoMap[drift.id];
        return DefensivoMapper.fromDriftToEntity(
          drift,
          modoAcao: modoAcao,
        ).copyWith(
          quantidadeDiagnosticos: 0,
          nivelPrioridade: 1,
          isComercializado: drift.status,
          isElegivel: drift.elegivel,
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
      final allDrift = await _repository.findAll();

      final allDefensivos = allDrift;
      final infoMap = await _fetchInfoMap();
      final defensivosEntities = DefensivoMapper.fromDriftToEntityList(
        allDefensivos,
        infoMap: infoMap,
      );

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
      return const Left(
        CacheFailure('Erro ao buscar defensivos com filtros: {{e.toString()}}'),
      );
    }
  }
}
