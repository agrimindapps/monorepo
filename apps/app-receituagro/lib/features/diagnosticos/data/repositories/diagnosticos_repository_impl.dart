import 'dart:developer' as developer;

import 'package:core/core.dart';

import '../../../../core/data/repositories/diagnostico_hive_repository.dart';
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
  final DiagnosticoHiveRepository _hiveRepository;

  const DiagnosticosRepositoryImpl(this._hiveRepository);

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await _hiveRepository.getAll();
      if (result.isError) {
        return Left(CacheFailure('Erro ao buscar diagnósticos: ${result.error?.message}'));
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

      final diagnosticosHive = await _hiveRepository.findByDefensivo(idDefensivo);

      developer.log(
        '✅ queryByDefensivo (Repository) - ${diagnosticosHive.length} registros Hive encontrados',
        name: 'DiagnosticosRepository',
      );

      final entities = diagnosticosHive
          .map<DiagnosticoEntity>(
            (hive) => DiagnosticoMapper.fromHive(hive),
          )
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
          .map<DiagnosticoEntity>(
            (hive) => DiagnosticoMapper.fromHive(hive),
          )
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
          .map<DiagnosticoEntity>(
            (hive) => DiagnosticoMapper.fromHive(hive),
          )
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
          .map<DiagnosticoEntity>(
            (hive) => DiagnosticoMapper.fromHive(hive),
          )
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
        return Left(CacheFailure('Erro na busca por padrão: ${result.error?.message}'));
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
          .map<DiagnosticoEntity>(
            (hive) => DiagnosticoMapper.fromHive(hive),
          )
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }
}
