import 'package:core/core.dart';

import '../../domain/entities/busca_entity.dart';
import '../../domain/repositories/i_busca_repository.dart';
import '../../domain/services/i_busca_filter_service.dart';
import '../../domain/services/i_busca_metadata_service.dart';
import '../../domain/services/i_busca_validation_service.dart';
import '../datasources/i_busca_datasource.dart';

/// Implementação do repositório de busca com datasource

class BuscaRepositoryImpl implements IBuscaRepository {
  final IBuscaDatasource _datasource;
  final IBuscaFilterService _filterService;
  final IBuscaValidationService _validationService;
  final IBuscaMetadataService _metadataService;

  BuscaRepositoryImpl(
    this._datasource,
    this._filterService,
    this._validationService,
    this._metadataService,
  );

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarComFiltros(
    BuscaFiltersEntity filters,
  ) async {
    try {
      final validationError = _validationService.validateSearchParams(filters);
      if (validationError != null) {
        return Left(validationError);
      }

      final rawResults = await _datasource.searchDiagnosticos(
        culturaId: filters.culturaId,
        pragaId: filters.pragaId,
        defensivoId: filters.defensivoId,
      );

      final results = rawResults.map(_mapToEntity).toList();

      final filtered = _filterService.applyFilters(results, filters);

      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar com filtros: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPorTexto(
    String query, {
    List<String>? tipos,
    int? limit,
  }) async {
    try {
      final validationError = _validationService.validateTextQuery(query);
      if (validationError != null) {
        return Left(validationError);
      }

      final rawResults = await _datasource.searchByText(
        query,
        tipos: tipos,
        limit: limit,
      );

      final results = rawResults.map(_mapToEntity).toList();

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por texto: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDiagnosticos({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  }) async {
    try {
      final rawResults = await _datasource.searchDiagnosticos(
        culturaId: culturaId,
        pragaId: pragaId,
        defensivoId: defensivoId,
      );

      final results = rawResults.map(_mapToEntity).toList();

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPragasPorCultura(
    String culturaId,
  ) async {
    try {
      if (!_validationService.isValidId(culturaId)) {
        return const Left(ValidationFailure('ID de cultura inválido'));
      }

      final rawResults = await _datasource.searchPragasByCultura(culturaId);

      final results = rawResults.map(_mapToEntity).toList();

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por cultura: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDefensivosPorPraga(
    String pragaId,
  ) async {
    try {
      if (!_validationService.isValidId(pragaId)) {
        return const Left(ValidationFailure('ID de praga inválido'));
      }

      final rawResults = await _datasource.searchDefensivosByPraga(pragaId);

      final results = rawResults.map(_mapToEntity).toList();

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por praga: $e'));
    }
  }

  @override
  Future<Either<Failure, BuscaMetadataEntity>> getMetadados() async {
    return _metadataService.loadMetadata();
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> getSugestoes({
    int limit = 10,
  }) async {
    try {
      final rawResults = await _datasource.getSuggestions(limit: limit);

      final results = rawResults.map(_mapToEntity).toList();

      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter sugestões: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> salvarHistoricoBusca(
    BuscaFiltersEntity filters,
    List<BuscaResultEntity> resultados,
  ) async {
    try {
      final searchData = {
        'filters': {
          'culturaId': filters.culturaId,
          'pragaId': filters.pragaId,
          'defensivoId': filters.defensivoId,
          'query': filters.query,
          'tipos': filters.tipos,
        },
        'resultCount': resultados.length,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _datasource.saveSearchHistory(searchData);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaFiltersEntity>>> getHistoricoBusca({
    int limit = 20,
  }) async {
    try {
      final rawHistory = await _datasource.getSearchHistory(limit: limit);

      final history = rawHistory
          .map((h) {
            final filters = (h['filters'] as Map<String, dynamic>?);
            final tiposList = (filters?['tipos'] as List<dynamic>? ?? []);
            return BuscaFiltersEntity(
              culturaId: (filters?['culturaId'] as String?),
              pragaId: (filters?['pragaId'] as String?),
              defensivoId: (filters?['defensivoId'] as String?),
              query: (filters?['query'] as String?),
              tipos: tiposList.map((e) => e.toString()).toList(),
            );
          })
          .toList();

      return Right(history);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter histórico: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> limparCache() async {
    try {
      await _datasource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: $e'));
    }
  }

  BuscaResultEntity _mapToEntity(Map<String, dynamic> data) {
    final metadataRaw = (data['metadata'] as Map<dynamic, dynamic>? ?? {});
    final metadata = Map<String, dynamic>.from(
      metadataRaw.map((key, value) => MapEntry(key.toString(), value)),
    );

    return BuscaResultEntity(
      id: data['id'] as String,
      tipo: data['tipo'] as String,
      titulo: data['titulo'] as String,
      subtitulo: data['subtitulo'] as String?,
      descricao: data['descricao'] as String?,
      imageUrl: data['imageUrl'] as String?,
      metadata: metadata,
      relevancia: (data['relevancia'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
