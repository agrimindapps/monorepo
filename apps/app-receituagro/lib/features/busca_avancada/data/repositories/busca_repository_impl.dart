import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/repositories/cultura_core_repository.dart';
import '../../../../core/repositories/diagnostico_core_repository.dart';
import '../../../../core/repositories/fitossanitario_core_repository.dart';
import '../../../../core/repositories/pragas_core_repository.dart';
import '../../../../core/services/diagnostico_integration_service.dart';
import '../../domain/entities/busca_entity.dart';
import '../../domain/repositories/i_busca_repository.dart';
import '../mappers/busca_mapper.dart';

/// Implementação do repositório de busca avançada
/// Segue padrões Clean Architecture + Either pattern para error handling
class BuscaRepositoryImpl implements IBuscaRepository {
  final DiagnosticoCoreRepository _diagnosticoRepo;
  final PragasCoreRepository _pragasRepo;
  final FitossanitarioCoreRepository _defensivosRepo;
  final CulturaCoreRepository _culturasRepo;
  final DiagnosticoIntegrationService _integrationService;

  // Cache simples para metadados
  BuscaMetadataEntity? _cachedMetadata;
  DateTime? _metadataLastUpdate;
  static const _cacheValidityDuration = Duration(hours: 1);

  BuscaRepositoryImpl(
    this._diagnosticoRepo,
    this._pragasRepo,
    this._defensivosRepo,
    this._culturasRepo,
    this._integrationService,
  );

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarComFiltros(
    BuscaFiltersEntity filters,
  ) async {
    try {
      final resultados = <BuscaResultEntity>[];

      // Buscar diagnósticos se houver filtros relevantes
      if (filters.culturaId != null || filters.pragaId != null || filters.defensivoId != null) {
        final diagnosticosResult = await buscarDiagnosticos(
          culturaId: filters.culturaId,
          pragaId: filters.pragaId,
          defensivoId: filters.defensivoId,
        );
        
        diagnosticosResult.fold(
          (failure) => throw failure,
          (diagnosticos) => resultados.addAll(diagnosticos),
        );
      }

      // Buscar por texto se informado
      if (filters.query?.isNotEmpty == true) {
        final textoResult = await buscarPorTexto(
          filters.query!,
          tipos: filters.tipos.isNotEmpty ? filters.tipos : null,
        );
        
        textoResult.fold(
          (failure) => throw failure,
          (textoResults) {
            // Evitar duplicatas
            for (final result in textoResults) {
              if (!resultados.any((r) => r.id == result.id && r.tipo == result.tipo)) {
                resultados.add(result);
              }
            }
          },
        );
      }

      // Ordenar por relevância
      resultados.sort((a, b) => b.relevancia.compareTo(a.relevancia));

      return Right(resultados);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar com filtros: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPorTexto(
    String query, {
    List<String>? tipos,
    int? limit,
  }) async {
    try {
      final resultados = <BuscaResultEntity>[];
      final queryLower = query.toLowerCase();
      final limitValue = limit ?? 50;

      // Buscar em diagnósticos se não há filtro de tipos ou 'diagnostico' está incluído
      if (tipos == null || tipos.contains('diagnostico')) {
        final diagnosticos = await _diagnosticoRepo.getAllAsync();
        final diagnosticosFiltrados = diagnosticos.where((d) =>
          d.nome.toLowerCase().contains(queryLower) ||
          d.cultura.toLowerCase().contains(queryLower) ||
          d.praga.toLowerCase().contains(queryLower) ||
          d.sintomas.toLowerCase().contains(queryLower)
        ).take(limitValue ~/ 4).toList();
        
        resultados.addAll(BuscaMapper.diagnosticosToEntityList(diagnosticosFiltrados));
      }

      // Buscar em pragas
      if (tipos == null || tipos.contains('praga')) {
        final pragas = await _pragasRepo.getAllAsync();
        final pragasFiltradas = pragas.where((p) =>
          p.nomeComum.toLowerCase().contains(queryLower) ||
          p.nomeCientifico.toLowerCase().contains(queryLower) ||
          (p.descricao?.toLowerCase().contains(queryLower) ?? false)
        ).take(limitValue ~/ 4).toList();
        
        resultados.addAll(BuscaMapper.pragasToEntityList(pragasFiltradas));
      }

      // Buscar em defensivos
      if (tipos == null || tipos.contains('defensivo')) {
        final defensivos = await _defensivosRepo.getAllAsync();
        final defensivosFiltrados = defensivos.where((d) =>
          d.nomeComum.toLowerCase().contains(queryLower) ||
          d.nomeTecnico.toLowerCase().contains(queryLower) ||
          (d.ingredienteAtivo?.toLowerCase().contains(queryLower) ?? false) ||
          (d.fabricante?.toLowerCase().contains(queryLower) ?? false)
        ).take(limitValue ~/ 4).toList();
        
        resultados.addAll(BuscaMapper.defensivosToEntityList(defensivosFiltrados));
      }

      // Buscar em culturas
      if (tipos == null || tipos.contains('cultura')) {
        final culturas = await _culturasRepo.getAllAsync();
        final culturasFiltradas = culturas.where((c) =>
          c.cultura.toLowerCase().contains(queryLower)
        ).take(limitValue ~/ 4).toList();
        
        resultados.addAll(BuscaMapper.culturasToEntityList(culturasFiltradas));
      }

      // Limitar resultados finais
      if (resultados.length > limitValue) {
        resultados.removeRange(limitValue, resultados.length);
      }

      return Right(resultados);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar por texto: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDiagnosticos({
    String? culturaId,
    String? pragaId,
    String? defensivoId,
  }) async {
    try {
      final diagnosticosDetalhados = await _integrationService.buscarComFiltros(
        culturaId: culturaId,
        pragaId: pragaId,
        defensivoId: defensivoId,
      );

      final resultados = diagnosticosDetalhados.map((d) => BuscaResultEntity(
        id: d.diagnostico.id.toString(),
        tipo: 'diagnostico',
        titulo: d.diagnostico.nome,
        subtitulo: d.cultura?.nome ?? d.diagnostico.cultura,
        descricao: d.diagnostico.sintomas,
        metadata: {
          'cultura': d.cultura?.nome ?? d.diagnostico.cultura,
          'praga': d.praga?.nomeComum ?? d.diagnostico.praga,
          'defensivos': d.defensivos.map((def) => def.nomeComum).toList(),
          'situacao': d.diagnostico.situacao,
          'tipo': d.diagnostico.tipo,
        },
        relevancia: 1.0,
      )).toList();

      return Right(resultados);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar diagnósticos: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarPragasPorCultura(
    String culturaId,
  ) async {
    try {
      // Implementação simplificada - busca diagnósticos que relacionam cultura e pragas
      final diagnosticos = await _diagnosticoRepo.getAllAsync();
      final cultura = await _culturasRepo.getByKey(culturaId);
      
      if (cultura == null) {
        return const Left(CacheFailure('Cultura não encontrada'));
      }

      final pragasIds = diagnosticos
          .where((d) => d.cultura.toLowerCase() == cultura.cultura.toLowerCase())
          .map((d) => d.praga)
          .toSet();

      final todasPragas = await _pragasRepo.getAllAsync();
      final pragasEncontradas = todasPragas.where((p) =>
        pragasIds.any((id) => 
          p.nomeComum.toLowerCase().contains(id.toLowerCase()) ||
          p.nomeCientifico.toLowerCase().contains(id.toLowerCase())
        )
      ).toList();

      return Right(BuscaMapper.pragasToEntityList(pragasEncontradas));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar pragas por cultura: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> buscarDefensivosPorPraga(
    String pragaId,
  ) async {
    try {
      final diagnosticos = await _diagnosticoRepo.getAllAsync();
      final praga = await _pragasRepo.getByKey(pragaId);
      
      if (praga == null) {
        return const Left(CacheFailure('Praga não encontrada'));
      }

      // Buscar diagnósticos relacionados à praga
      final diagnosticosRelacionados = diagnosticos.where((d) =>
        d.praga.toLowerCase().contains(praga.nomeComum.toLowerCase()) ||
        d.praga.toLowerCase().contains(praga.nomeCientifico.toLowerCase())
      ).toList();

      final resultados = <BuscaResultEntity>[];
      
      for (final diagnostico in diagnosticosRelacionados) {
        try {
          final detalhado = await _integrationService.buscarComFiltros(
            pragaId: pragaId,
          );
          
          for (final detalhe in detalhado) {
            for (final defensivo in detalhe.defensivos) {
              final result = BuscaMapper.defensivoToEntity(defensivo);
              if (!resultados.any((r) => r.id == result.id)) {
                resultados.add(result);
              }
            }
          }
        } catch (e) {
          // Log error but continue
          continue;
        }
      }

      return Right(resultados);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar defensivos por praga: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BuscaMetadataEntity>> getMetadados() async {
    try {
      // Verificar cache
      if (_cachedMetadata != null && 
          _metadataLastUpdate != null &&
          DateTime.now().difference(_metadataLastUpdate!) < _cacheValidityDuration) {
        return Right(_cachedMetadata!);
      }

      // Carregar dados
      final culturas = await _culturasRepo.getAllAsync();
      final pragas = await _pragasRepo.getAllAsync();
      final defensivos = await _defensivosRepo.getAllAsync();

      final metadata = BuscaMetadataEntity(
        culturas: culturas
            .map((c) => BuscaMapper.culturaToDropdownItem(c))
            .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome)),
        pragas: pragas
            .map((p) => BuscaMapper.pragaToDropdownItem(p))
            .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome)),
        defensivos: defensivos
            .map((d) => BuscaMapper.defensivoToDropdownItem(d))
            .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome)),
        tipos: const ['diagnostico', 'praga', 'defensivo', 'cultura'],
      );

      // Atualizar cache
      _cachedMetadata = metadata;
      _metadataLastUpdate = DateTime.now();

      return Right(metadata);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar metadados: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaResultEntity>>> getSugestoes({int limit = 10}) async {
    try {
      // Implementação simplificada - retorna diagnósticos recentes
      final diagnosticos = await _diagnosticoRepo.getAllAsync();
      final sugestoes = diagnosticos.take(limit).toList();
      
      return Right(BuscaMapper.diagnosticosToEntityList(sugestoes));
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar sugestões: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> salvarHistoricoBusca(
    BuscaFiltersEntity filters,
    List<BuscaResultEntity> resultados,
  ) async {
    try {
      // Implementação simplificada - apenas log por enquanto
      // Em uma implementação real, salvaria em Hive ou SharedPreferences
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BuscaFiltersEntity>>> getHistoricoBusca({int limit = 20}) async {
    try {
      // Implementação simplificada - retorna lista vazia por enquanto
      return const Right([]);
    } catch (e) {
      return Left(CacheFailure('Erro ao carregar histórico: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> limparCache() async {
    try {
      _cachedMetadata = null;
      _metadataLastUpdate = null;
      _integrationService.clearCache();
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: ${e.toString()}'));
    }
  }
}