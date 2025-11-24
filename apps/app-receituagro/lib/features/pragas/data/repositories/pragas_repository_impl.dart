import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/pragas_repository.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/repositories/i_pragas_repository.dart';
import '../../domain/services/i_pragas_error_message_service.dart';
import '../../domain/services/i_pragas_query_service.dart';
import '../../domain/services/i_pragas_search_service.dart';
import '../../domain/services/i_pragas_stats_service.dart';
import '../mappers/praga_mapper.dart';

/// Implementação do repositório de pragas usando Drift (Data Layer)
///
/// SOLID Refactoring:
/// - Separated query logic to PragasQueryService (SRP)
/// - Separated search logic to PragasSearchService (SRP)
/// - Separated stats logic to PragasStatsService (SRP)
/// - Repository now focuses only on CRUD operations
/// - All dependencies injected to improve testability (DIP)
///
/// This follows the pattern established in diagnosticos, defensivos, and comentarios features.
///
/// Princípios: Single Responsibility + Dependency Inversion
/// Segue padrão Either for error handling consistente

class PragasRepositoryImpl implements IPragasRepository {
  final PragasRepository _repository;
  final IPragasQueryService _queryService;
  final IPragasSearchService _searchService;
  final IPragasStatsService _statsService;
  final IPragasErrorMessageService _errorService;

  PragasRepositoryImpl(
    this._repository,
    this._queryService,
    this._searchService,
    this._statsService,
    this._errorService,
  );

  @override
  Future<Either<Failure, List<PragaEntity>>> getAll() async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);

      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure(_errorService.getFetchAllError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, PragaEntity?>> getById(String id) async {
    try {
      if (id.isEmpty) {
        return Left(CacheFailure(_errorService.getEmptyIdError()));
      }

      final praga = await _repository.findByIdPraga(id);

      if (praga == null) {
        return const Right(null);
      }

      final pragaEntity = PragaMapper.fromDriftToEntity(praga);
      return Right(pragaEntity);
    } catch (e) {
      return Left(CacheFailure(_errorService.getFetchByIdError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByTipo(String tipo) async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final filteredPragas = _queryService.getByTipo(pragasEntities, tipo);

      return Right(filteredPragas);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchByTipoError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> searchByName(
    String searchTerm,
  ) async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final searchResults = _searchService.searchByName(
        pragasEntities,
        searchTerm,
      );

      return Right(searchResults);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchByNameError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByFamilia(
    String familia,
  ) async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final filteredPragas = _queryService.getByFamilia(
        pragasEntities,
        familia,
      );

      return Right(filteredPragas);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchByFamiliaError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByCultura(
    String culturaId,
  ) async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final filteredPragas = _queryService.getByCultura(
        pragasEntities,
        culturaId,
      );

      return Right(filteredPragas);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchByCulturaError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getCountByTipo(String tipo) async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final count = _statsService.getCountByTipo(pragasEntities, tipo);

      return Right(count);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getCountByTipoError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getTotalCount() async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final count = _statsService.getTotalCount(pragasEntities);

      return Right(count);
    } catch (e) {
      return Left(CacheFailure(_errorService.getCountTotalError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getPragasRecentes({
    int limit = 10,
  }) async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final recentPragas = _queryService.getRecentes(
        pragasEntities,
        limit: limit,
      );

      return Right(recentPragas);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchRecentError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getPragasStats() async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final stats = _statsService.calculateStats(pragasEntities);

      return Right(stats);
    } catch (e) {
      return Left(CacheFailure(_errorService.getFetchAllError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFamiliasPragas() async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final familias = _queryService.getFamiliasPragas(pragasEntities);

      return Right(familias);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchFamiliasError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTiposPragas() async {
    try {
      final pragasDrift = await _repository.findAll();
      final pragasEntities = PragaMapper.fromDriftToEntityList(pragasDrift);
      final tipos = _queryService.getTiposPragas(pragasEntities);

      return Right(tipos);
    } catch (e) {
      return Left(CacheFailure(_errorService.getFetchTiposError(e.toString())));
    }
  }
}

/// Implementação do repositório de histórico usando LocalStorage
/// Princípio: Single Responsibility - Apenas gerencia histórico

class PragasHistoryRepositoryImpl implements IPragasHistoryRepository {
  final PragasRepository _repository;
  final IPragasErrorMessageService _errorService;

  static const int _maxRecentItems = 7;
  static const int _maxSuggestedItems = 5;

  PragasHistoryRepositoryImpl(this._repository, this._errorService);

  @override
  Future<Either<Failure, List<PragaEntity>>> getRecentlyAccessed() async {
    try {
      final pragasDrift = await _repository.findAll();
      if (pragasDrift.isEmpty) return const Right([]);
      final recentPragas = pragasDrift.take(_maxRecentItems).toList();
      final pragasEntities = PragaMapper.fromDriftToEntityList(recentPragas);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure(_errorService.getLoadRecentError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> markAsAccessed(String pragaId) async {
    try {
      if (pragaId.isEmpty) {
        return Left(CacheFailure(_errorService.getEmptyIdError()));
      }
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getMarkAccessedError(e.toString())),
      );
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getSuggested(int limit) async {
    try {
      final pragasDrift = await _repository.findAll();
      if (pragasDrift.isEmpty) return const Right([]);
      final shuffledPragas = pragasDrift.toList()..shuffle();
      final suggestedPragas = shuffledPragas
          .take(limit.clamp(1, _maxSuggestedItems))
          .toList();
      final pragasEntities = PragaMapper.fromDriftToEntityList(suggestedPragas);
      return Right(pragasEntities);
    } catch (e) {
      return Left(
        CacheFailure(_errorService.getFetchSuggestedError(e.toString())),
      );
    }
  }
}

/// Implementação do formatador de pragas
/// Princípio: Single Responsibility - Apenas formatação

class PragasFormatterImpl implements IPragasFormatter {
  @override
  String formatImageName(String nomeCientifico) {
    if ([
      'Espalhante adesivo para calda de pulverização',
      'Não classificado',
    ].contains(nomeCientifico)) {
      return 'a';
    }
    return nomeCientifico
        .replaceAll('/', '-')
        .replaceAll('ç', 'c')
        .replaceAll('ã', 'a');
  }

  @override
  Map<String, dynamic> formatForDisplay(PragaEntity praga) {
    return {
      'idReg': praga.idReg,
      'nomeComum': praga.nomeFormatado,
      'nomeSecundario': praga.nomesSecundarios.join(', '),
      'nomeCientifico': praga.nomeCientifico,
      'nomeImagem': formatImageName(praga.nomeCientifico),
      'tipoPraga': praga.tipoPraga,
      'isInseto': praga.isInseto,
      'isDoenca': praga.isDoenca,
      'isPlanta': praga.isPlanta,
    };
  }

  @override
  String formatNomeComum(String nomeCompleto) {
    final nomeList = nomeCompleto.split(';');
    return nomeList[0].split('-')[0].trim();
  }
}
