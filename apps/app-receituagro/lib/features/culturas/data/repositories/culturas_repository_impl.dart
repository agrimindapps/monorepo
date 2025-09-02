import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/cultura_entity.dart';
import '../../domain/repositories/i_culturas_repository.dart';
import '../../../../core/repositories/cultura_core_repository.dart';
import '../mappers/cultura_mapper.dart';

/// Implementação do repositório de culturas
/// Segue padrões Clean Architecture + Either pattern para error handling
class CulturasRepositoryImpl implements ICulturasRepository {
  final CulturaCoreRepository _coreRepository;

  CulturasRepositoryImpl(this._coreRepository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> getAllCulturas() async {
    try {
      final culturasModels = await _coreRepository.getAllAsync();
      final culturasEntities = CulturaMapper.toEntityList(culturasModels);
      
      return Right(culturasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> getCulturasByGrupo(String grupo) async {
    try {
      final allCulturas = await _coreRepository.getAllAsync();
      final culturasFiltradas = allCulturas
          .where((cultura) => cultura.grupo.toLowerCase().contains(grupo.toLowerCase()))
          .toList();
      
      final culturasEntities = CulturaMapper.toEntityList(culturasFiltradas);
      return Right(culturasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas por grupo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CulturaEntity?>> getCulturaById(String id) async {
    try {
      final cultura = await _coreRepository.getItemById(id);
      
      if (cultura == null) {
        return const Right(null);
      }
      
      final culturaEntity = CulturaMapper.toEntity(cultura);
      return Right(culturaEntity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar cultura por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> searchCulturas(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllCulturas();
      }

      final allCulturas = await _coreRepository.getAllAsync();
      final culturasFiltradas = allCulturas.where((cultura) {
        final nomeMatch = cultura.cultura.toLowerCase().contains(query.toLowerCase());
        final grupoMatch = cultura.grupo.toLowerCase().contains(query.toLowerCase());
        return nomeMatch || grupoMatch;
      }).toList();
      
      final culturasEntities = CulturaMapper.toEntityList(culturasFiltradas);
      return Right(culturasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getGruposCulturas() async {
    try {
      final allCulturas = await _coreRepository.getAllAsync();
      final grupos = allCulturas
          .map((cultura) => cultura.grupo)
          .where((grupo) => grupo.isNotEmpty)
          .toSet()
          .toList();
      
      grupos.sort();
      return Right(grupos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar grupos de culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCulturaActive(String culturaId) async {
    try {
      final cultura = await _coreRepository.getItemById(culturaId);
      return Right(cultura != null);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar status da cultura: ${e.toString()}'));
    }
  }
}