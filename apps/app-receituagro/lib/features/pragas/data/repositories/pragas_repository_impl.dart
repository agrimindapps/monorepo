import 'package:core/core.dart';

import '../../../../core/data/repositories/pragas_hive_repository.dart';
import '../../domain/entities/praga_entity.dart';
import '../../domain/repositories/i_pragas_repository.dart';
import '../mappers/praga_mapper.dart';
import '../services/pragas_query_service.dart';
import '../services/pragas_search_service.dart';
import '../services/pragas_stats_service.dart';

/// Implementação do repositório de pragas usando Hive (Data Layer)
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
@LazySingleton(as: IPragasRepository)
class PragasRepositoryImpl implements IPragasRepository {
  final PragasHiveRepository _hiveRepository;
  final IPragasQueryService _queryService;
  final IPragasSearchService _searchService;
  final IPragasStatsService _statsService;

  PragasRepositoryImpl(
    this._hiveRepository,
    this._queryService,
    this._searchService,
    this._statsService,
  );

  @override
  Future<Either<Failure, List<PragaEntity>>> getAll() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final pragasHive = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(pragasHive);

      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PragaEntity?>> getById(String id) async {
    try {
      if (id.isEmpty) {
        return const Left(CacheFailure('ID não pode ser vazio'));
      }

      final result = await _hiveRepository.getByKey(id);
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar praga por ID: ${result.error?.message}'));
      }
      final praga = result.data;

      if (praga == null) {
        return const Right(null);
      }

      final pragaEntity = PragaMapper.fromHiveToEntity(praga);
      return Right(pragaEntity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar praga por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByTipo(String tipo) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final filteredPragas = _queryService.getByTipo(pragasEntities, tipo);

      return Right(filteredPragas);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por tipo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> searchByName(String searchTerm) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final searchResults = _searchService.searchByName(pragasEntities, searchTerm);

      return Right(searchResults);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por nome: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByFamilia(String familia) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final filteredPragas = _queryService.getByFamilia(pragasEntities, familia);

      return Right(filteredPragas);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por família: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getByCultura(String culturaId) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final filteredPragas = _queryService.getByCultura(pragasEntities, culturaId);

      return Right(filteredPragas);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCountByTipo(String tipo) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final count = _statsService.getCountByTipo(pragasEntities, tipo);

      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar pragas por tipo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalCount() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final count = _statsService.getTotalCount(pragasEntities);

      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar total de pragas: {{e.toString()}}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getPragasRecentes({int limit = 10}) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: {{result.error?.message}}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final recentPragas = _queryService.getRecentes(pragasEntities, limit: limit);

      return Right(recentPragas);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas recentes: {{e.toString()}}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getPragasStats() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: {{result.error?.message}}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final stats = _statsService.calculateStats(pragasEntities);

      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar estatísticas das pragas: {{e.toString()}}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getTiposPragas() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: {{result.error?.message}}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final tipos = _queryService.getTiposPragas(pragasEntities);

      return Right(tipos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar tipos de pragas: {{e.toString()}}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFamiliasPragas() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: {{result.error?.message}}'));
      }

      final allPragas = result.data ?? [];
      final pragasEntities = PragaMapper.fromHiveToEntityList(allPragas);
      final familias = _queryService.getFamiliasPragas(pragasEntities);

      return Right(familias);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar famílias de pragas: {{e.toString()}}'));
    }
  }
}

/// Implementação do repositório de histórico usando LocalStorage
/// Princípio: Single Responsibility - Apenas gerencia histórico
@LazySingleton(as: IPragasHistoryRepository)
class PragasHistoryRepositoryImpl implements IPragasHistoryRepository {
  final PragasHiveRepository _hiveRepository;

  static const int _maxRecentItems = 7;
  static const int _maxSuggestedItems = 5;

  PragasHistoryRepositoryImpl(this._hiveRepository);

  @override
  Future<Either<Failure, List<PragaEntity>>> getRecentlyAccessed() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      if (allPragas.isEmpty) return const Right([]);
      final recentHivePragas = allPragas.take(_maxRecentItems).toList();
      final pragasEntities = PragaMapper.fromHiveToEntityList(recentHivePragas);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar pragas recentes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsAccessed(String pragaId) async {
    try {
      if (pragaId.isEmpty) {
        return const Left(CacheFailure('ID da praga não pode ser vazio'));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar praga como acessada: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PragaEntity>>> getSuggested(int limit) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isFailure) {
        return Left(CacheFailure('Erro ao buscar pragas: ${result.error?.message}'));
      }
      final allPragas = result.data ?? [];
      if (allPragas.isEmpty) return const Right([]);
      final shuffledPragas = allPragas.toList()..shuffle();
      final suggestedHivePragas = shuffledPragas
          .take(limit.clamp(1, _maxSuggestedItems))
          .toList();
      final pragasEntities = PragaMapper.fromHiveToEntityList(suggestedHivePragas);
      return Right(pragasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas sugeridas: ${e.toString()}'));
    }
  }
}

/// Implementação do formatador de pragas
/// Princípio: Single Responsibility - Apenas formatação
@LazySingleton(as: IPragasFormatter)
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
