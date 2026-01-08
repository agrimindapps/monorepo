import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/culturas_repository.dart';
import '../../domain/entities/cultura_entity.dart';
import '../../domain/repositories/i_culturas_repository.dart';
import '../mappers/cultura_mapper.dart';
import '../services/culturas_query_service.dart';
import '../services/culturas_search_service.dart';

/// Implementação do repositório de culturas
///
/// SOLID Refactoring:
/// - Separated query logic to CulturasQueryService (SRP)
/// - Separated search logic to CulturasSearchService (SRP)
/// - Repository now focuses only on CRUD operations
/// - All dependencies injected to improve testability (DIP)
/// - Implemented getGruposCulturas() properly (was returning empty list)
///
/// This follows the pattern established in diagnosticos, defensivos, pragas, and comentarios features.
///
/// Segue padrões Clean Architecture + Either pattern para error handling

class CulturasRepositoryImpl implements ICulturasRepository {
  final CulturasRepository _driftRepository;
  final ICulturasQueryService _queryService;
  final ICulturasSearchService _searchService;

  CulturasRepositoryImpl(
    this._driftRepository,
    this._queryService,
    this._searchService,
  );

  @override
  Future<Either<Failure, List<CulturaEntity>>> getAllCulturas() async {
    try {
      final culturasDrift = await _driftRepository.findAll();
      final culturasEntities = CulturaMapper.fromDriftToEntityList(
        culturasDrift,
      );

      return Right(culturasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> getCulturasByGrupo(
    String grupo,
  ) async {
    try {
      final allCulturas = await _driftRepository.findAll();
      final culturasEntities = CulturaMapper.fromDriftToEntityList(allCulturas);

      // Delegate to query service
      final culturasFiltradas = _queryService.getByGrupo(
        culturasEntities,
        grupo,
      );

      return Right(culturasFiltradas);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar culturas por grupo: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, CulturaEntity?>> getCulturaById(String id) async {
    try {
      // New schema uses string idCultura as PK
      final cultura = await _driftRepository.findByIdCultura(id);
      if (cultura == null) {
        return const Right(null);
      }

      final culturaEntity = CulturaMapper.fromDriftToEntity(cultura);
      return Right(culturaEntity);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar cultura por ID: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchCulturas(
    String query,
  ) async {
    try {
      final allCulturas = await _driftRepository.findAll();
      final culturasEntities = CulturaMapper.fromDriftToEntityList(allCulturas);

      // Delegate to search service
      final searchResults = _searchService.search(culturasEntities, query);

      return Right(searchResults);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getGruposCulturas() async {
    try {
      final allCulturas = await _driftRepository.findAll();
      final culturasEntities = CulturaMapper.fromDriftToEntityList(allCulturas);

      // Delegate to query service to extract distinct grupos
      final grupos = _queryService.getGrupos(culturasEntities);

      return Right(grupos);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar grupos de culturas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isCulturaActive(String culturaId) async {
    try {
      // New schema uses string idCultura as PK
      final cultura = await _driftRepository.findByIdCultura(culturaId);
      return Right(cultura != null && cultura.status);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao verificar status da cultura: ${e.toString()}'),
      );
    }
  }
}
