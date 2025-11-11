import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../../../database/repositories/diagnostico_repository.dart';
import '../../../../database/repositories/diagnosticos_repository.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../mappers/diagnostico_mapper.dart';

/// Implementation of diagnosticos repository (Data Layer)
///
/// REFACTORED: Simplified to CRUD + Basic Queries only (Phase 4 - God Object Refactoring)
/// - Removed 16 specialized methods now handled by services
/// - Kept only 7 essential methods (2 CRUD + 5 basic queries)
/// - Follows Single Responsibility Principle (SOLID)
///
/// This repository is now focused solely on data access,
/// leaving business logic to specialized services.
@LazySingleton(as: IDiagnosticosRepository)
class DiagnosticosRepositoryImpl implements IDiagnosticosRepository {
  final DiagnosticosRepository _repository;

  const DiagnosticosRepositoryImpl(this._repository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      var diagnosticosDrift = await _repository.findAll();

      if (offset != null && offset > 0) {
        diagnosticosDrift = diagnosticosDrift.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        diagnosticosDrift = diagnosticosDrift.take(limit).toList();
      }

      final entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id) async {
    try {
      final diagnosticoDrift = await _repository.findByIdOrObjectId(id);

      if (diagnosticoDrift == null) {
        return const Right(null);
      }

      final entity = DiagnosticoMapper.fromDrift(diagnosticoDrift);
      return Right(entity);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar diagnóstico por ID: ${e.toString()}'),
      );
    }
  }

  // ========== Basic Query Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByDefensivo(
    String idDefensivo,
  ) async {
    try {
      developer.log(
        '🔍 queryByDefensivo (Repository) - ID do defensivo: $idDefensivo',
        name: 'DiagnosticosRepository',
      );

      final diagnosticosDrift = await _repository.findByDefensivo(
        'current-user', // TODO: Get from auth
        idDefensivo,
      );

      developer.log(
        '✅ queryByDefensivo (Repository) - ${diagnosticosDrift.length} registros Drift encontrados',
        name: 'DiagnosticosRepository',
      );

      final entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      developer.log(
        '✅ queryByDefensivo (Repository) - ${entities.length} entities mapeadas, retornando Right()',
        name: 'DiagnosticosRepository',
      );

      return Right(entities);
    } catch (e, stack) {
      developer.log(
        '❌ queryByDefensivo (Repository) - Erro: $e',
        name: 'DiagnosticosRepository',
        error: e,
        stackTrace: stack,
      );
      return Left(
        CacheFailure('Erro ao buscar por defensivo: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByCultura(
    String idCultura,
  ) async {
    try {
      final diagnosticosDrift = await _repository.findByCultura(
        'current-user', // TODO: Get from auth
        idCultura,
      );
      final entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByPraga(
    String idPraga,
  ) async {
    try {
      final diagnosticosDrift = await _repository.findByPraga(
        'current-user', // TODO: Get from auth
        idPraga,
      );
      final entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  }) async {
    try {
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        userId: 'current-user', // TODO: Get from auth
        defenisivoId: idDefensivo,
        culturaId: idCultura,
        pragaId: idPraga,
      );
      final entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      return Right(entities);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar por combinação: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> queryByPattern(
    String pattern,
  ) async {
    try {
      if (pattern.trim().isEmpty) {
        return const Right(<DiagnosticoEntity>[]);
      }

      final allDiagnosticos = await _repository.findAll();

      final matchingDiagnosticos = allDiagnosticos
          .where(
            (d) =>
                d.defenisivoId.toString().contains(pattern) ||
                d.culturaId.toString().contains(pattern) ||
                d.pragaId.toString().contains(pattern),
          )
          .toList();

      final entities = DiagnosticoMapper.fromDriftList(matchingDiagnosticos);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }

  // ========== Metadata Operations ==========

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllDefensivos() async {
    try {
      final diagnosticos = await _repository.findAll();
      final defensivosMap = <String, Map<String, dynamic>>{};

      for (final d in diagnosticos) {
        final idStr = d.defenisivoId.toString();
        if (!defensivosMap.containsKey(idStr)) {
          defensivosMap[idStr] = {
            'id': idStr,
            'nome': idStr, // Nome seria ideal vir de outra tabela
          };
        }
      }

      return Right(defensivosMap.values.toList());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCulturas() async {
    try {
      final diagnosticos = await _repository.findAll();
      final culturasMap = <String, Map<String, dynamic>>{};

      for (final d in diagnosticos) {
        final idStr = d.culturaId.toString();
        if (!culturasMap.containsKey(idStr)) {
          culturasMap[idStr] = {'id': idStr, 'nome': idStr};
        }
      }

      return Right(culturasMap.values.toList());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllPragas() async {
    try {
      final diagnosticos = await _repository.findAll();
      final pragasMap = <String, Map<String, dynamic>>{};

      for (final d in diagnosticos) {
        final idStr = d.pragaId.toString();
        if (!pragasMap.containsKey(idStr)) {
          pragasMap[idStr] = {'id': idStr, 'nome': idStr};
        }
      }

      return Right(pragasMap.values.toList());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUnidadesMedida() async {
    try {
      final diagnosticos = await _repository.findAll();
      final unidades = <String>{};

      for (final d in diagnosticos) {
        if (d.um.isNotEmpty) {
          unidades.add(d.um);
        }
      }

      return Right(unidades.toList()..sort());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar unidades: ${e.toString()}'));
    }
  }

  // ========== Recommendation Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String culturaId,
    required String pragaId,
  }) async {
    try {
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        userId: 'current-user', // TODO: Get from auth
        culturaId: culturaId,
        pragaId: pragaId,
      );

      final entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      return Right(entities);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar recomendações: ${e.toString()}'),
      );
    }
  }

  // ========== Search Operations ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters({
    String? defensivo,
    String? cultura,
    String? praga,
    String? tipoAplicacao,
  }) async {
    try {
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        userId: 'current-user', // TODO: Get from auth
        defenisivoId: defensivo,
        culturaId: cultura,
        pragaId: praga,
      );

      var entities = DiagnosticoMapper.fromDriftList(diagnosticosDrift);

      // Filter by tipo de aplicacao (terrestre/aerea)
      if (tipoAplicacao != null && tipoAplicacao.isNotEmpty) {
        entities = entities.where((e) {
          if (tipoAplicacao.toLowerCase().contains('terrestre')) {
            return e.aplicacao.terrestre != null;
          } else if (tipoAplicacao.toLowerCase().contains('aerea')) {
            return e.aplicacao.aerea != null;
          }
          return true;
        }).toList();
      }

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String idDiagnostico,
  ) async {
    try {
      final diagnosticoResult = await getById(idDiagnostico);
      if (diagnosticoResult.isLeft()) {
        return const Left(CacheFailure('Diagnóstico não encontrado'));
      }

      final diagnostico = diagnosticoResult.getOrElse(() => null);
      if (diagnostico == null) {
        return const Right(<DiagnosticoEntity>[]);
      }

      final allDiagnosticos = await _repository.findAll();

      final similar = allDiagnosticos
          .where(
            (DiagnosticoData d) =>
                d.firebaseId != diagnostico.id &&
                d.id.toString() != diagnostico.id &&
                (d.culturaId.toString() == diagnostico.idCultura ||
                    d.pragaId.toString() == diagnostico.idPraga),
          )
          .take(10)
          .toList();

      final entities = DiagnosticoMapper.fromDriftList(similar);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar similares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(
    String pattern,
  ) async {
    return queryByPattern(pattern);
  }

  // ========== Statistics Operations ==========

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    try {
      final diagnosticos = await _repository.findAll();

      final stats = {
        'total': diagnosticos.length,
        'totalDefensivos': diagnosticos
            .map((e) => e.defenisivoId)
            .toSet()
            .length,
        'totalCulturas': diagnosticos.map((e) => e.culturaId).toSet().length,
        'totalPragas': diagnosticos.map((e) => e.pragaId).toSet().length,
      };

      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar estatísticas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getPopularDiagnosticos({
    int limit = 10,
  }) async {
    try {
      final diagnosticos = (await _repository.findAll()).take(limit).toList();
      final entities = DiagnosticoMapper.fromDriftList(diagnosticos);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar populares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> countByFilters({
    String? defensivo,
    String? cultura,
    String? praga,
  }) async {
    try {
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        userId: 'current-user', // TODO: Get from auth
        defenisivoId: defensivo,
        culturaId: cultura,
        pragaId: praga,
      );

      return Right(diagnosticosDrift.length);
    } catch (e) {
      return Left(CacheFailure('Erro ao contar filtros: ${e.toString()}'));
    }
  }

  // ========== Validation Operations ==========

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    try {
      final result = await getById(id);
      if (result.isLeft()) {
        return const Right(false);
      }

      final diagnostico = result.getOrElse(() => null);
      return Right(diagnostico != null);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao verificar existência: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    try {
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        userId: 'current-user', // TODO: Get from auth
        defenisivoId: idDefensivo,
        culturaId: idCultura,
        pragaId: idPraga,
      );

      return Right(diagnosticosDrift.isNotEmpty);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao validar compatibilidade: ${e.toString()}'),
      );
    }
  }

  // ========== Legacy Methods ==========

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByDefensivo(
    String defensivoId,
  ) async {
    return queryByDefensivo(defensivoId);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCultura(
    String culturaId,
  ) async {
    return queryByCultura(culturaId);
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByPraga(
    String pragaId,
  ) async {
    return queryByPraga(pragaId);
  }
}
