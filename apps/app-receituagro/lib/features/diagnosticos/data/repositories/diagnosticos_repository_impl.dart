import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column;

import '../../../../database/receituagro_database.dart';
import '../../../../database/repositories/culturas_repository.dart';
import '../../../../database/repositories/diagnosticos_repository.dart';
import '../../../../database/repositories/fitossanitarios_repository.dart';
import '../../../../database/repositories/pragas_repository.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../mappers/diagnostico_mapper.dart';

/// Implementation of diagnosticos repository (Data Layer)
///
/// Updated for new string-based FK schema:
/// - Diagnostico.fkIdCultura, fkIdPraga, fkIdDefensivo are strings
/// - No need to resolve int IDs - direct string FK matching
class DiagnosticosRepositoryImpl implements IDiagnosticosRepository {
  final DiagnosticosRepository _repository;
  final FitossanitariosRepository _fitossanitariosRepository;
  final CulturasRepository _culturasRepository;
  final PragasRepository _pragasRepository;

  // Caches para evitar queries repetidas (keyed by string ID)
  Map<String, Fitossanitario>? _fitossanitariosCache;
  Map<String, Cultura>? _culturasCache;
  Map<String, Praga>? _pragasCache;

  DiagnosticosRepositoryImpl(
    this._repository,
    this._fitossanitariosRepository,
    this._culturasRepository,
    this._pragasRepository,
  );

  /// Carrega caches de lookup tables (keyed by string ID)
  Future<void> _ensureCachesLoaded() async {
    if (_fitossanitariosCache == null) {
      final fitossanitarios = await _fitossanitariosRepository.findAll();
      _fitossanitariosCache = {for (var f in fitossanitarios) f.idDefensivo: f};
    }
    if (_culturasCache == null) {
      final culturas = await _culturasRepository.findAll();
      _culturasCache = {for (var c in culturas) c.idCultura: c};
    }
    if (_pragasCache == null) {
      final pragas = await _pragasRepository.findAll();
      _pragasCache = {for (var p in pragas) p.idPraga: p};
    }
  }

  /// Enriquece uma entidade com nomes resolvidos (using string FK)
  DiagnosticoEntity _enrichEntity(DiagnosticoEntity entity, Diagnostico drift) {
    final defensivo = _fitossanitariosCache?[drift.fkIdDefensivo];
    final cultura = _culturasCache?[drift.fkIdCultura];
    final praga = _pragasCache?[drift.fkIdPraga];

    return entity.copyWith(
      nomeDefensivo: defensivo?.nome ?? 'Defensivo não encontrado',
      nomeCultura: cultura?.nome ?? 'Cultura não encontrada',
      nomePraga: praga?.nome ?? 'Praga não encontrada',
    );
  }

  /// Converte e enriquece uma lista de diagnósticos
  Future<List<DiagnosticoEntity>> _mapAndEnrichList(
    List<Diagnostico> driftList,
  ) async {
    await _ensureCachesLoaded();
    return driftList.map((drift) {
      final entity = DiagnosticoMapper.fromDrift(drift);
      return _enrichEntity(entity, drift);
    }).toList();
  }

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

      final entities = await _mapAndEnrichList(diagnosticosDrift);

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

      await _ensureCachesLoaded();
      final entity = DiagnosticoMapper.fromDrift(diagnosticoDrift);
      final enrichedEntity = _enrichEntity(entity, diagnosticoDrift);

      return Right(enrichedEntity);
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

      // Direct string FK query - no need to resolve int IDs
      final diagnosticosDrift = await _repository.findByDefensivoId(idDefensivo);

      developer.log(
        '✅ queryByDefensivo (Repository) - ${diagnosticosDrift.length} registros Drift encontrados',
        name: 'DiagnosticosRepository',
      );

      final entities = await _mapAndEnrichList(diagnosticosDrift);

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
      // Direct string FK query
      final diagnosticosDrift = await _repository.findByCulturaId(idCultura);
      final entities = await _mapAndEnrichList(diagnosticosDrift);

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
      developer.log(
        '🔍 queryByPraga (Repository) - ID da praga recebido: "$idPraga"',
        name: 'DiagnosticosRepository',
      );

      // Direct string FK query
      final diagnosticosDrift = await _repository.findByPragaId(idPraga);
      
      developer.log(
        '✅ queryByPraga (Repository) - ${diagnosticosDrift.length} diagnósticos encontrados para pragaId: $idPraga',
        name: 'DiagnosticosRepository',
      );

      final entities = await _mapAndEnrichList(diagnosticosDrift);

      return Right(entities);
    } catch (e, stack) {
      developer.log(
        '❌ queryByPraga (Repository) - Erro: $e',
        name: 'DiagnosticosRepository',
        error: e,
        stackTrace: stack,
      );
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
      // Direct string FK query
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        fkIdDefensivo: idDefensivo,
        fkIdCultura: idCultura,
        fkIdPraga: idPraga,
      );
      final entities = await _mapAndEnrichList(diagnosticosDrift);

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

      await _ensureCachesLoaded();
      final allDiagnosticos = await _repository.findAll();
      final patternLower = pattern.toLowerCase();

      final matchingDiagnosticos = allDiagnosticos.where((d) {
        // Buscar nos nomes resolvidos (using string FK)
        final defensivo = _fitossanitariosCache?[d.fkIdDefensivo];
        final cultura = _culturasCache?[d.fkIdCultura];
        final praga = _pragasCache?[d.fkIdPraga];

        return (defensivo?.nome.toLowerCase().contains(patternLower) ?? false) ||
            (cultura?.nome.toLowerCase().contains(patternLower) ?? false) ||
            (praga?.nome.toLowerCase().contains(patternLower) ?? false);
      }).toList();

      final entities = await _mapAndEnrichList(matchingDiagnosticos);

      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }

  // ========== Metadata Operations ==========

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllDefensivos() async {
    try {
      await _ensureCachesLoaded();
      final defensivosList = _fitossanitariosCache!.values.map((f) => {
            'id': f.idDefensivo,
            'nome': f.nome,
          }).toList();

      return Right(defensivosList);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCulturas() async {
    try {
      await _ensureCachesLoaded();
      final culturasList = _culturasCache!.values.map((c) => {
            'id': c.idCultura,
            'nome': c.nome,
          }).toList();

      return Right(culturasList);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllPragas() async {
    try {
      await _ensureCachesLoaded();
      final pragasList = _pragasCache!.values.map((p) => {
            'id': p.idPraga,
            'nome': p.nome,
          }).toList();

      return Right(pragasList);
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
      // Direct string FK query
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        fkIdCultura: culturaId,
        fkIdPraga: pragaId,
      );

      final entities = await _mapAndEnrichList(diagnosticosDrift);

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
      // Direct string FK query
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        fkIdDefensivo: defensivo,
        fkIdCultura: cultura,
        fkIdPraga: praga,
      );

      var entities = await _mapAndEnrichList(diagnosticosDrift);

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
            (d) =>
                d.idReg != diagnostico.id &&
                (d.fkIdCultura == diagnostico.idCultura ||
                    d.fkIdPraga == diagnostico.idPraga),
          )
          .take(10)
          .toList();

      final entities = await _mapAndEnrichList(similar);

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
        'totalDefensivos':
            diagnosticos.map((e) => e.fkIdDefensivo).toSet().length,
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
      final diagnosticos = (await _repository.findAll()).take(limit).toList();
      final entities = await _mapAndEnrichList(diagnosticos);

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
      // Direct string FK query
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        fkIdDefensivo: defensivo,
        fkIdCultura: cultura,
        fkIdPraga: praga,
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
      // Direct string FK query
      final diagnosticosDrift = await _repository.findByTriplaCombinacao(
        fkIdDefensivo: idDefensivo,
        fkIdCultura: idCultura,
        fkIdPraga: idPraga,
      );

      return Right(diagnosticosDrift.isNotEmpty);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao validar compatibilidade: ${e.toString()}'),
      );
    }
  }
}
