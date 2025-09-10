import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/models/diagnostico_hive.dart';
import '../../../../core/repositories/diagnostico_hive_repository.dart';
import '../../../../core/services/enhanced_diagnostic_integration_service.dart';
import '../../domain/entities/diagnostico_entity.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../mappers/diagnostico_mapper.dart';

/// Adapter temporário para usar DiagnosticoHiveRepository em vez de DiagnosticoCoreRepository
/// ENHANCED: Esta implementação resolve conflitos de Hive usando o enhanced service para nomes
class DiagnosticosRepositoryLegacyAdapter implements IDiagnosticosRepository {
  final DiagnosticoHiveRepository _hiveRepository;
  late final EnhancedDiagnosticIntegrationService _enhancedService;

  DiagnosticosRepositoryLegacyAdapter(this._hiveRepository) {
    // Lazy load the enhanced service to avoid circular dependencies
    try {
      _enhancedService = sl<EnhancedDiagnosticIntegrationService>();
    } catch (e) {
      debugPrint('⚠️ Enhanced service not available, falling back to legacy mapper');
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getAll({
    int? limit,
    int? offset,
  }) async {
    try {
      final diagnosticosHive = _hiveRepository.getAll();
      
      List<DiagnosticoHive> diagnosticosPaginated = diagnosticosHive;
      if (offset != null && offset > 0) {
        diagnosticosPaginated = diagnosticosHive.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        diagnosticosPaginated = diagnosticosPaginated.take(limit).toList();
      }
      
      final entities = await _convertToEntitiesEnhanced(diagnosticosPaginated);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DiagnosticoEntity?>> getById(String id) async {
    try {
      final diagnosticoHive = _hiveRepository.getById(id);
      if (diagnosticoHive == null) {
        return const Right(null);
      }
      
      final entity = await _convertToEntityEnhanced(diagnosticoHive);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnóstico por ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByDefensivo(String idDefensivo) async {
    try {
      final diagnosticosHive = _hiveRepository.findByDefensivo(idDefensivo);
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por defensivo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCultura(String idCultura) async {
    try {
      final diagnosticosHive = _hiveRepository.findByCultura(idCultura);
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByPraga(String idPraga) async {
    try {
      final diagnosticosHive = _hiveRepository.findByPraga(idPraga);
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByTriplaCombinacao({
    String? idDefensivo,
    String? idCultura,
    String? idPraga,
  }) async {
    try {
      final diagnosticosHive = _hiveRepository.findByMultipleCriteria(
        defensivoId: idDefensivo,
        culturaId: idCultura,
        pragaId: idPraga,
      );
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por combinação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByNomeDefensivo(String nome) async {
    try {
      final allDiagnosticos = _hiveRepository.getAll();
      final diagnosticosHive = allDiagnosticos.where((d) => 
          d.fkIdDefensivo.contains(nome) || 
          (d.nomeDefensivo?.toLowerCase().contains(nome.toLowerCase()) ?? false)
      ).toList();
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por nome defensivo: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByNomeCultura(String nome) async {
    try {
      final allDiagnosticos = _hiveRepository.getAll();
      final diagnosticosHive = allDiagnosticos.where((d) => 
          d.fkIdCultura.contains(nome) || 
          (d.nomeCultura?.toLowerCase().contains(nome.toLowerCase()) ?? false)
      ).toList();
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por nome cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByNomePraga(String nome) async {
    try {
      final allDiagnosticos = _hiveRepository.getAll();
      final diagnosticosHive = allDiagnosticos.where((d) => 
          d.fkIdPraga.contains(nome) || 
          (d.nomePraga?.toLowerCase().contains(nome.toLowerCase()) ?? false)
      ).toList();
      final entities = await _convertToEntitiesEnhanced(diagnosticosHive);
      
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por nome praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByTipoAplicacao(TipoAplicacao tipo) async {
    try {
      final allResult = await getAll();
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final filtered = diagnosticos
              .where((d) => d.aplicacao.tiposDisponiveis.contains(tipo))
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por tipo aplicação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByCompletude(DiagnosticoCompletude completude) async {
    try {
      final allResult = await getAll();
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final filtered = diagnosticos
              .where((d) => d.completude == completude)
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por completude: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getByFaixaDosagem({
    required double dosagemMinima,
    required double dosagemMaxima,
  }) async {
    try {
      final allResult = await getAll();
      return allResult.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final filtered = diagnosticos.where((d) {
            final dosageAvg = d.dosagem.dosageAverage;
            return dosageAvg >= dosagemMinima && dosageAvg <= dosagemMaxima;
          }).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por faixa dosagem: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchWithFilters(
    DiagnosticoSearchFilters filters,
  ) async {
    try {
      var diagnosticos = <DiagnosticoEntity>[];

      if (filters.idDefensivo != null || filters.idCultura != null || filters.idPraga != null) {
        final combinationResult = await getByTriplaCombinacao(
          idDefensivo: filters.idDefensivo,
          idCultura: filters.idCultura,
          idPraga: filters.idPraga,
        );
        if (combinationResult.isLeft()) return combinationResult;
        diagnosticos = combinationResult.fold((l) => [], (r) => r);
      } else {
        final allResult = await getAll();
        if (allResult.isLeft()) return allResult;
        diagnosticos = allResult.fold((l) => [], (r) => r);
      }

      if (filters.nomeDefensivo?.isNotEmpty == true) {
        final searchResult = await searchByNomeDefensivo(filters.nomeDefensivo!);
        if (searchResult.isLeft()) return searchResult;
        final searchDiagnosticos = searchResult.fold((l) => <DiagnosticoEntity>[], (r) => r);
        diagnosticos = diagnosticos.where((d) => 
          searchDiagnosticos.any((sd) => sd.id == d.id)).toList();
      }

      if (filters.nomeCultura?.isNotEmpty == true) {
        final searchResult = await searchByNomeCultura(filters.nomeCultura!);
        if (searchResult.isLeft()) return searchResult;
        final searchDiagnosticos = searchResult.fold((l) => <DiagnosticoEntity>[], (r) => r);
        diagnosticos = diagnosticos.where((d) => 
          searchDiagnosticos.any((sd) => sd.id == d.id)).toList();
      }

      if (filters.nomePraga?.isNotEmpty == true) {
        final searchResult = await searchByNomePraga(filters.nomePraga!);
        if (searchResult.isLeft()) return searchResult;
        final searchDiagnosticos = searchResult.fold((l) => <DiagnosticoEntity>[], (r) => r);
        diagnosticos = diagnosticos.where((d) => 
          searchDiagnosticos.any((sd) => sd.id == d.id)).toList();
      }

      if (filters.tipoAplicacao != null) {
        diagnosticos = diagnosticos.where((d) => 
          d.aplicacao.tiposDisponiveis.contains(filters.tipoAplicacao)).toList();
      }

      if (filters.completude != null) {
        diagnosticos = diagnosticos.where((d) => d.completude == filters.completude).toList();
      }

      if (filters.dosagemMinima != null && filters.dosagemMaxima != null) {
        diagnosticos = diagnosticos.where((d) {
          final dosageAvg = d.dosagem.dosageAverage;
          return dosageAvg >= filters.dosagemMinima! && dosageAvg <= filters.dosagemMaxima!;
        }).toList();
      }

      if (filters.limit != null) {
        diagnosticos = diagnosticos.take(filters.limit!).toList();
      }

      return Right(diagnosticos);
    } catch (e) {
      return Left(CacheFailure('Erro na busca com filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getSimilarDiagnosticos(
    String diagnosticoId, {
    int limit = 5,
  }) async {
    try {
      final originalResult = await getById(diagnosticoId);
      if (originalResult.isLeft()) {
        return const Left(CacheFailure('Diagnóstico original não encontrado'));
      }

      final original = originalResult.fold((l) => null, (r) => r);
      if (original == null) {
        return const Right(<DiagnosticoEntity>[]);
      }

      final similarByDefensivoResult = await getByDefensivo(original.idDefensivo);
      if (similarByDefensivoResult.isLeft()) return similarByDefensivoResult;

      final similarByPragaResult = await getByPraga(original.idPraga);
      if (similarByPragaResult.isLeft()) return similarByPragaResult;

      final similarDefensivo = similarByDefensivoResult.fold((l) => <DiagnosticoEntity>[], (r) => r);
      final similarPraga = similarByPragaResult.fold((l) => <DiagnosticoEntity>[], (r) => r);

      final similar = <DiagnosticoEntity>[];
      similar.addAll(similarDefensivo.where((d) => d.id != diagnosticoId));
      similar.addAll(similarPraga.where((d) => 
        d.id != diagnosticoId && !similar.any((s) => s.id == d.id)));

      return Right(similar.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos similares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> getRecomendacoesPara({
    required String idCultura,
    required String idPraga,
    int limit = 10,
  }) async {
    try {
      final result = await getByTriplaCombinacao(
        idCultura: idCultura,
        idPraga: idPraga,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          diagnosticos.sort((a, b) => b.completude.index.compareTo(a.completude.index));
          return Right(diagnosticos.take(limit).toList());
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar recomendações: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DiagnosticosStats>> getStatistics() async {
    try {
      // Implementação básica de stats usando dados do repositório legacy
      final allDiagnosticos = _hiveRepository.getAll();
      
      const stats = DiagnosticosStats(
        total: 0,
        completos: 0,
        parciais: 0,
        incompletos: 0,
        porDefensivo: <String, int>{},
        porCultura: <String, int>{},
        porPraga: <String, int>{},
        topDiagnosticos: <DiagnosticoPopular>[],
      );
      
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoPopular>>> getPopularDiagnosticos({
    int limit = 10,
  }) async {
    try {
      final statsResult = await getStatistics();
      return statsResult.fold(
        (failure) => Left(failure),
        (stats) => Right(stats.topDiagnosticos.take(limit).toList()),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos populares: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(String id) async {
    try {
      final result = await getById(id);
      return result.fold(
        (failure) => Left(failure),
        (diagnostico) => Right(diagnostico != null),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> countByFilters(DiagnosticoSearchFilters filters) async {
    try {
      final result = await searchWithFilters(filters);
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) => Right(diagnosticos.length),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao contar por filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllDefensivos() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final defensivos = diagnosticos
              .map((d) => d.nomeDefensivo)
              .where((nome) => nome?.isNotEmpty == true)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();
          return Right(defensivos);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter defensivos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllCulturas() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final culturas = diagnosticos
              .map((d) => d.nomeCultura)
              .where((nome) => nome?.isNotEmpty == true)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();
          return Right(culturas);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter culturas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllPragas() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final pragas = diagnosticos
              .map((d) => d.nomePraga)
              .where((nome) => nome?.isNotEmpty == true)
              .cast<String>()
              .toSet()
              .toList()
            ..sort();
          return Right(pragas);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter pragas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validarCompatibilidade({
    required String idDefensivo,
    required String idCultura,
    required String idPraga,
  }) async {
    try {
      final result = await getByTriplaCombinacao(
        idDefensivo: idDefensivo,
        idCultura: idCultura,
        idPraga: idPraga,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) => Right(diagnosticos.isNotEmpty),
      );
    } catch (e) {
      return Left(ValidationFailure('Erro na validação de compatibilidade: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUnidadesMedida() async {
    try {
      final result = await getAll();
      return result.fold(
        (failure) => Left(failure),
        (diagnosticos) {
          final unidades = diagnosticos
              .map((d) => d.dosagem.unidade)
              .where((unidade) => unidade.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          return Right(unidades);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter unidades de medida: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(String pattern) async {
    try {
      if (pattern.trim().isEmpty) {
        return const Right(<DiagnosticoEntity>[]);
      }

      final futures = await Future.wait([
        searchByNomeDefensivo(pattern),
        searchByNomeCultura(pattern),
        searchByNomePraga(pattern),
      ]);

      final byDefensivoResult = futures[0];
      final byCulturaResult = futures[1];
      final byPragaResult = futures[2];

      if (byDefensivoResult.isLeft()) return byDefensivoResult;
      if (byCulturaResult.isLeft()) return byCulturaResult;
      if (byPragaResult.isLeft()) return byPragaResult;

      final byDefensivo = byDefensivoResult.fold((l) => <DiagnosticoEntity>[], (r) => r);
      final byCultura = byCulturaResult.fold((l) => <DiagnosticoEntity>[], (r) => r);
      final byPraga = byPragaResult.fold((l) => <DiagnosticoEntity>[], (r) => r);

      final combined = <DiagnosticoEntity>[];
      combined.addAll(byDefensivo);
      combined.addAll(byCultura.where((d) => !combined.any((c) => c.id == d.id)));
      combined.addAll(byPraga.where((d) => !combined.any((c) => c.id == d.id)));

      combined.sort((a, b) {
        final aDefensivoMatch = a.nomeDefensivo?.toLowerCase().contains(pattern.toLowerCase()) ?? false;
        final bDefensivoMatch = b.nomeDefensivo?.toLowerCase().contains(pattern.toLowerCase()) ?? false;
        
        if (aDefensivoMatch && !bDefensivoMatch) return -1;
        if (!aDefensivoMatch && bDefensivoMatch) return 1;
        
        return (a.nomeDefensivo ?? '').compareTo(b.nomeDefensivo ?? '');
      });

      return Right(combined);
    } catch (e) {
      return Left(CacheFailure('Erro na busca por padrão: ${e.toString()}'));
    }
  }

  /// Helper method para converter Hive models para entities com enhancement
  Future<List<DiagnosticoEntity>> _convertToEntitiesEnhanced(List<DiagnosticoHive> hiveModels) async {
    if (hiveModels.isEmpty) return [];

    try {
      // Tenta usar o enhanced service se disponível
      return await _enhancedService.enrichDiagnosticsBatch(hiveModels);
    } catch (e) {
      debugPrint('⚠️ Enhanced conversion failed, falling back to legacy: $e');
      // Fallback para conversão legacy
      return hiveModels.map((hive) => DiagnosticoMapper.fromHive(hive)).toList();
    }
  }

  /// Helper method para converter um único Hive model para entity com enhancement
  Future<DiagnosticoEntity> _convertToEntityEnhanced(DiagnosticoHive hiveModel) async {
    try {
      // Tenta usar o enhanced service se disponível
      return await _enhancedService.enrichDiagnostic(hiveModel);
    } catch (e) {
      debugPrint('⚠️ Enhanced conversion failed, falling back to legacy: $e');
      // Fallback para conversão legacy
      return DiagnosticoMapper.fromHive(hiveModel);
    }
  }
}