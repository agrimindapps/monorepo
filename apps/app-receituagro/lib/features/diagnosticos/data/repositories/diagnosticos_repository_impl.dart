import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../../../core/data/repositories/diagnostico_legacy_repository.dart';
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
  final DiagnosticoLegacyRepository _hiveRepository;

  const DiagnosticosRepositoryImpl(this._hiveRepository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar diagnósticos: ${result.error?.message}'),
        );
      }

      var diagnosticosHive = result.data!;
      if (offset != null && offset > 0) {
        diagnosticosHive = diagnosticosHive.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        diagnosticosHive = diagnosticosHive.take(limit).toList();
      }

      final entities = diagnosticosHive
          .map((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id) async {
    try {
      final diagnosticoHive = await _hiveRepository.getByIdOrObjectId(id);

      if (diagnosticoHive == null) {
        return const Right(null);
      }

      final entity = DiagnosticoMapper.fromHive(diagnosticoHive);
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

      final diagnosticosHive = await _hiveRepository.findByDefensivo(
        idDefensivo,
      );

      developer.log(
        '✅ queryByDefensivo (Repository) - ${diagnosticosHive.length} registros Hive encontrados',
        name: 'DiagnosticosRepository',
      );

      final entities = diagnosticosHive
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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
      final diagnosticosHive = await _hiveRepository.findByCultura(idCultura);
      final entities = diagnosticosHive
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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
      final diagnosticosHive = await _hiveRepository.findByPraga(idPraga);
      final entities = diagnosticosHive
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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
      final diagnosticosHive = await _hiveRepository.findByMultipleCriteria(
        defensivoId: idDefensivo,
        culturaId: idCultura,
        pragaId: idPraga,
      );
      final entities = diagnosticosHive
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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

      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro na busca por padrão: ${result.error?.message}'),
        );
      }

      final allDiagnosticos = result.data!;
      final matchingDiagnosticos = allDiagnosticos
          .where(
            (d) =>
                d.fkIdDefensivo.contains(pattern) ||
                d.fkIdCultura.contains(pattern) ||
                d.fkIdPraga.contains(pattern),
          )
          .toList();

      final entities = matchingDiagnosticos
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }

  // ========== Metadata Operations ==========

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllDefensivos() async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar defensivos: ${result.error?.message}'),
        );
      }

      final diagnosticos = result.data!;
      final defensivosMap = <String, Map<String, dynamic>>{};

      for (final d in diagnosticos) {
        if (!defensivosMap.containsKey(d.fkIdDefensivo)) {
          defensivosMap[d.fkIdDefensivo] = {
            'id': d.fkIdDefensivo,
            'nome': d.fkIdDefensivo, // Nome seria ideal vir de outra tabela
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
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar culturas: ${result.error?.message}'),
        );
      }

      final diagnosticos = result.data!;
      final culturasMap = <String, Map<String, dynamic>>{};

      for (final d in diagnosticos) {
        if (!culturasMap.containsKey(d.fkIdCultura)) {
          culturasMap[d.fkIdCultura] = {
            'id': d.fkIdCultura,
            'nome': d.fkIdCultura,
          };
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
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar pragas: ${result.error?.message}'),
        );
      }

      final diagnosticos = result.data!;
      final pragasMap = <String, Map<String, dynamic>>{};

      for (final d in diagnosticos) {
        if (!pragasMap.containsKey(d.fkIdPraga)) {
          pragasMap[d.fkIdPraga] = {'id': d.fkIdPraga, 'nome': d.fkIdPraga};
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
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar unidades: ${result.error?.message}'),
        );
      }

      final diagnosticos = result.data!;
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
      final diagnosticosHive = await _hiveRepository.findByMultipleCriteria(
        culturaId: culturaId,
        pragaId: pragaId,
      );

      final entities = diagnosticosHive
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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
      final diagnosticosHive = await _hiveRepository.findByMultipleCriteria(
        defensivoId: defensivo,
        culturaId: cultura,
        pragaId: praga,
      );

      var entities = diagnosticosHive
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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

      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar similares: ${result.error?.message}'),
        );
      }

      final allDiagnosticos = result.data!;
      final similar = allDiagnosticos
          .where(
            (d) =>
                d.objectId != diagnostico.id &&
                (d.fkIdCultura == diagnostico.idCultura ||
                    d.fkIdPraga == diagnostico.idPraga),
          )
          .take(10)
          .toList();

      final entities = similar
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar estatísticas: ${result.error?.message}'),
        );
      }

      final diagnosticos = result.data!;
      final stats = {
        'total': diagnosticos.length,
        'totalDefensivos': diagnosticos
            .map((e) => e.fkIdDefensivo)
            .toSet()
            .length,
        'totalCulturas': diagnosticos.map((e) => e.fkIdCultura).toSet().length,
        'totalPragas': diagnosticos.map((e) => e.fkIdPraga).toSet().length,
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
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(
          CacheFailure('Erro ao buscar populares: ${result.error?.message}'),
        );
      }

      final diagnosticos = result.data!.take(limit).toList();
      final entities = diagnosticos
          .map<DiagnosticoEntity>((hive) => DiagnosticoMapper.fromHive(hive))
          .toList();

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
      final diagnosticosHive = await _hiveRepository.findByMultipleCriteria(
        defensivoId: defensivo,
        culturaId: cultura,
        pragaId: praga,
      );

      return Right(diagnosticosHive.length);
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
      final diagnosticosHive = await _hiveRepository.findByMultipleCriteria(
        defensivoId: idDefensivo,
        culturaId: idCultura,
        pragaId: idPraga,
      );

      return Right(diagnosticosHive.isNotEmpty);
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
