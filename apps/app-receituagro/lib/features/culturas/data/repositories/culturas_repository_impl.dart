import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/repositories/cultura_core_repository.dart';
import '../../domain/entities/cultura_entity.dart';
import '../../domain/repositories/i_culturas_repository.dart';
import '../mappers/cultura_mapper.dart';

/// Implementação do repositório de culturas
/// Segue padrões Clean Architecture + Either pattern para error handling
class CulturasRepositoryImpl implements ICulturasRepository {
  final CulturaCoreRepository _coreRepository;

  CulturasRepositoryImpl(this._coreRepository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> getAllCulturas() async {
    try {
      final culturasHive = await _coreRepository.getAllAsync();
      final culturasEntities = CulturaMapper.fromHiveToEntityList(culturasHive);
      
      return Right(culturasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CulturaEntity>>> getCulturasByGrupo(String grupo) async {
    try {
      // CulturaHive não tem grupo, retornar lista vazia ou todas as culturas
      final allCulturas = await _coreRepository.getAllAsync();
      final culturasEntities = CulturaMapper.fromHiveToEntityList(allCulturas);
      
      // Filtrar por grupo na camada de entidade se necessário
      final culturasFiltradas = culturasEntities
          .where((cultura) => cultura.grupo?.toLowerCase().contains(grupo.toLowerCase()) ?? false)
          .toList();
      
      return Right(culturasFiltradas);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas por grupo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CulturaEntity?>> getCulturaById(String id) async {
    try {
      final cultura = await _coreRepository.getById(id);
      
      if (cultura == null) {
        return const Right(null);
      }
      
      final culturaEntity = CulturaMapper.fromHiveToEntity(cultura);
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
        // CulturaHive não tem grupo, apenas buscar por nome
        return nomeMatch;
      }).toList();
      
      final culturasEntities = CulturaMapper.fromHiveToEntityList(culturasFiltradas);
      return Right(culturasEntities);
    } catch (e) {
      return Left(CacheFailure('Erro ao pesquisar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getGruposCulturas() async {
    try {
      // CulturaHive não tem grupos, retornar lista vazia
      final grupos = <String>[];
      
      grupos.sort();
      return Right(grupos);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar grupos de culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCulturaActive(String culturaId) async {
    try {
      final cultura = await _coreRepository.getById(culturaId);
      return Right(cultura != null);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar status da cultura: ${e.toString()}'));
    }
  }
}