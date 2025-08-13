// Dart imports:
import 'dart:async';

// Project imports:
import '../core/di/service_locator.dart';
import '../core/interfaces/i_planta_repository.dart';
import '../core/optimization/enhanced_query_optimizer.dart';
import '../core/optimization/lazy_evaluation_service.dart';
import '../core/optimization/memoization_manager.dart';
import '../core/optimization/optimization_initializer.dart';
import '../core/optimization/query_optimizer.dart';
import '../core/optimization/statistics_cache_service.dart';
import '../database/planta_model.dart';
import '../services/shared/interfaces/i_task_service.dart';
import 'base_repository.dart';

/// Repository para Plantas usando BaseRepository pattern
///
/// ISSUE #33: Mixed Abstraction Levels - SOLUTION IMPLEMENTED
/// ISSUE #35: Repository Responsibilities - SOLUTION IMPLEMENTED
///
/// ARQUITETURA REFATORADA - Mantém APENAS operações de baixo nível:
/// - CRUD básico para PlantaModel (create, read, update, delete)
/// - Operações simples de busca (findByEspaco, findByNome)
/// - Cache básico e stream management
///
/// CROSS-CUTTING CONCERNS EXTERNALIZADOS via AOP:
/// - Logging: Aplicado automaticamente via LoggingAspect
/// - Validation: Aplicado automaticamente via ValidationAspect
/// - Statistics: Aplicado automaticamente via StatisticsAspect
/// - Performance Monitoring: Aplicado automaticamente via aspectos
///
/// Para operações de alto nível, use:
/// - RepositoryOperationsFacade: Operações cross-entity e dashboard data
/// - RepositoryQueryFacade: Queries complexas e analytics
/// - BusinessRulesService: Validações de negócio (existePlantaComNome, etc.)
/// - StatisticsService: Estatísticas e métricas (getPlantaStatistics, etc.)
/// - PlantaCareQueryService: Consultas de cuidados e streams reativas
/// - PlantaStatisticsService: Estatísticas detalhadas e relatórios
/// - PlantaCareOperationsService: Operações de cuidados (completar tarefas, toggles)
///
/// CONSISTENT ABSTRACTION LEVEL: Foca apenas em persistência de PlantaModel.
class PlantaRepository extends BaseRepository<PlantaModel>
    with PlantCareFunctionality<PlantaModel>
    implements IPlantaRepository {
  static PlantaRepository? _instance;
  static PlantaRepository get instance => _instance ??= PlantaRepository._();

  // Dependency injection para TaskService (abstração ao invés de implementação concreta)
  // Late initialization para garantir que seja inicializado antes do uso
  late final ITaskService _taskService;

  // Otimização avançada - ISSUE #13
  final MemoizationManager _memo = MemoizationManager.instance;
  final StatisticsCacheService _statsCache = StatisticsCacheService.instance;
  final EnhancedQueryOptimizer _queryOptimizer =
      EnhancedQueryOptimizer.instance;
  final LazyEvaluationService _lazyEval = LazyEvaluationService.instance;

  /// Obtém TaskService via dependency injection com lazy loading
  ITaskService get _getTaskService {
    // Usar assertion para garantir que o service esteja disponível
    assert(ServiceLocator.instance.isRegistered<ITaskService>(),
        'ITaskService deve estar registrado no ServiceLocator');
    return _taskService;
  }

  /// Factory method para criar instância com dependência customizada (útil para testes)
  static PlantaRepository createWithTaskService(ITaskService taskService) {
    final repository = PlantaRepository._();
    repository._initializeTaskService(taskService);
    return repository;
  }

  /// Inicializar TaskService de forma segura
  void _initializeTaskService([ITaskService? customService]) {
    _taskService = customService ?? ServiceLocator.instance.get<ITaskService>();
  }

  PlantaRepository._() : super() {
    // Inicializar dependências críticas
    _initializeTaskService();
  }

  @override
  String get repositoryName => 'PlantaRepository';

  @override
  String get collectionName => 'plantas';

  @override
  PlantaModel Function(Map<String, dynamic>) get fromJson =>
      PlantaModel.fromJson;

  @override
  Map<String, dynamic> Function(PlantaModel) get toJson =>
      (planta) => planta.toJson();

  @override
  String getItemId(PlantaModel item) => item.id;

  @override
  String getPlantaId(PlantaModel item) => item.id;

  // repositoryConfig removido - usando CommonRepositoryConfigs no BaseRepository

  @override
  Future<void> onAfterInitialize() async {
    // OTIMIZAÇÃO ISSUE #13: Inicializar serviços de otimização
    await _initializeOptimizationServices();
  }

  /// Inicializar serviços de otimização - ISSUE #13
  Future<void> _initializeOptimizationServices() async {
    try {
      await OptimizationInitializer.instance.initialize(
        plantaDataSource: () => syncService.findAll(),
        tarefaDataSource: () => _getTaskService.findAll(),
      );

      // Setup invalidação automática baseada em streams
      OptimizationInitializer.instance.setupStreamBasedInvalidation(
        plantaStream: syncService.dataStream,
        tarefaStream: _getTaskService.findAll().asStream(),
      );
    } catch (error) {
      logger.warning(
        'Falha na inicialização de otimizações',
        data: {'error': error.toString()},
      );
      // Não bloquear a inicialização principal por conta das otimizações
    }
  }

  /// Stream de todas as plantas (backward compatibility)
  Stream<List<PlantaModel>> get plantasStream => dataStream;

  // CRUD operations herdadas do BaseRepository
  // Mantém métodos específicos se necessário para backward compatibility

  @override
  void onItemCreated(String id, PlantaModel item) {
    QueryOptimizer.instance.invalidateRelatedCaches('planta_created');
  }

  @override
  void onItemUpdated(String id, PlantaModel item) {
    QueryOptimizer.instance
        .invalidateRelatedCaches('planta_updated', entityId: id);
  }

  @override
  void onItemDeleted(String id, PlantaModel item) {
    QueryOptimizer.instance
        .invalidateRelatedCaches('planta_deleted', entityId: id);
  }

  @override
  void onItemsCreatedBatch(List<String> ids, List<PlantaModel> items) {
    QueryOptimizer.instance.invalidateRelatedCaches('planta_created');
  }

  // Métodos específicos para Plantas

  /// Stream de plantas por espaço (usando mixin PlantCareFunctionality)
  @override
  Stream<List<PlantaModel>> watchByEspaco(String espacoId) {
    return dataStream.map(
      (items) => items.where((planta) => planta.espacoId == espacoId).toList(),
    );
  }

  // Streams de cuidados movidas para PlantaCareQueryService
  // Para queries relacionadas a cuidados, use PlantaCareQueryService

  /// Buscar plantas por espaço (OTIMIZADO com cache)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (espacoId, quantidade encontrada, tempo)
  /// - Validação do espacoId (não-vazio, formato válido)
  /// - Coleta de estatísticas (queries por espaço, cache hit/miss)
  @override
  Future<List<PlantaModel>> findByEspaco(String espacoId) {
    // ISSUE #35: Validação do espacoId é feita automaticamente pelo ValidationAspect
    // Logging e statistics são coletados automaticamente pelos aspectos
    return cachedQuery(
      {'espacoId': espacoId},
      () async {
        final plantas = await findAll();
        return plantas.where((planta) => planta.espacoId == espacoId).toList();
      },
      'findByEspaco',
      ttl: const Duration(minutes: 10),
    );
  }

  /// Buscar plantas por nome (SUPER OTIMIZADO com Firebase queries)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging detalhado (nome buscado, estratégia usada, resultados)
  /// - Validação do nome (não-vazio, caracteres válidos, tamanho)
  /// - Coleta de estatísticas (Firebase vs local, performance)
  /// - Error handling com retry automático se necessário
  @override
  Future<List<PlantaModel>> findByNome(String nome) {
    // ISSUE #35: Validação, logging e error handling são feitos pelos aspectos
    return cachedQuery(
      {'nome': nome.toLowerCase()},
      () async {
        // Usar busca otimizada do SyncFirebaseService se disponível
        try {
          final optimizedResults = await syncService.findByNomeOptimized(nome);
          if (optimizedResults.isNotEmpty) {
            // ISSUE #35: Debug logging feito automaticamente pelo LoggingAspect
            return optimizedResults;
          }
        } catch (e) {
          // ISSUE #35: Error logging feito automaticamente pelo LoggingAspect
          // Continuar com fallback
        }

        // Fallback para busca local (comportamento anterior)
        final plantas = await findAll();
        final nomeLower = nome.toLowerCase();

        return plantas.where((planta) {
          final plantaNome = planta.nome;
          // ISSUE #35: Null safety pode ser melhorada via ValidationAspect
          if (plantaNome == null || plantaNome.isEmpty) return false;
          return plantaNome.toLowerCase().contains(nomeLower);
        }).toList();
      },
      'findByNome',
      ttl: const Duration(minutes: 20),
    );
  }

  /// Buscar plantas usando full-text search otimizado
  Future<List<PlantaModel>> searchPlantas(
    String searchText, {
    List<String> searchFields = const ['nome', 'descricao'],
  }) async {
    try {
      // Usar full-text search otimizado
      final results = await syncService.fullTextSearch(
        searchText,
        searchFields: searchFields,
      );

      logger.debug('Full-text search encontrou resultados',
          data: {'count': results.length});
      return results;
    } catch (e) {
      logger.warning('Erro no full-text search, usando busca básica',
          data: {'error': e.toString()});
      return await findByNome(searchText);
    }
  }

  /// Buscar plantas recentes (últimas atualizadas/criadas)
  Future<List<PlantaModel>> findRecentPlantas({
    Duration? since,
    int limit = 20,
  }) async {
    try {
      final results = await syncService.findRecentOptimized(
        since: since,
        limit: limit,
      );

      logger.debug('Busca de plantas recentes encontrou resultados',
          data: {'count': results.length});
      return results;
    } catch (e) {
      logger.warning('Erro na busca de recentes, usando fallback',
          data: {'error': e.toString()});
      // Fallback para busca local
      final plantas = await findAll();
      plantas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return plantas.take(limit).toList();
    }
  }

  /// Buscar plantas que precisam de cuidados hoje
  ///
  /// ISSUE #33: Mixed Abstraction Levels - DEPRECATED HIGH-LEVEL OPERATION
  /// DEPRECATED: Esta operação complexa foi movida para RepositoryOperationsFacade
  /// Use: RepositoryOperationsFacade.instance.findPlantasNeedingCareToday()
  ///
  /// Este método será removido na v2.0
  @override
  @Deprecated(
      'Use RepositoryOperationsFacade.findPlantasNeedingCareToday() - será removido na v2.0')
  Future<List<PlantaModel>> findPrecisaCuidadosHoje() async {
    // OTIMIZAÇÃO ISSUE #13: Memoization com dependency tracking
    // REFACTOR ISSUE #30: Lógica condicional complexa refatorada para Chain of Responsibility
    return _memo.memoize(
      'plantas_precisam_cuidados_hoje',
      () => _lazyEval.lazyPlantasNeedingCare(),
      category: 'calculations',
      dependencies: ['plantas', 'tarefas'],
    );
  }

  // Operações de cuidados movidas para PlantaCareOperationsService
  // Para completar tarefas e toggles, use PlantaCareOperationsService

  /// Buscar plantas com tarefas atrasadas
  ///
  /// ISSUE #33: Mixed Abstraction Levels - DEPRECATED HIGH-LEVEL OPERATION
  /// DEPRECATED: Esta operação cross-entity foi movida para RepositoryOperationsFacade
  /// Use: RepositoryOperationsFacade.instance.findPlantasComTarefasAtrasadas()
  ///
  /// Este método será removido na v2.0
  @override
  @Deprecated(
      'Use RepositoryOperationsFacade.findPlantasComTarefasAtrasadas() - será removido na v2.0')
  Future<List<PlantaModel>> findComTarefasAtrasadas() async {
    final result = await QueryOptimizer.instance.findPlantasPrecisaCuidadosHoje(
      () => findAll(),
      () => _getTaskService.findAll(),
    );
    return result.plantasComTarefasAtrasadas;
  }

  /// Obter estatísticas das plantas (SUPER OTIMIZADO com memoization - ISSUE #13)
  /// DEPRECATED: Use StatisticsService.getPlantaStatistics() para lógica de negócio
  /// Para estatísticas avançadas, use PlantaStatisticsService
  @Deprecated(
      'Use StatisticsService.getPlantaStatistics() - será removido na v2.0')
  Future<Map<String, int>> getEstatisticas() async {
    // OTIMIZAÇÃO ISSUE #13: Cache inteligente de estatísticas com memoization
    return _statsCache.cacheStatistics(
      'planta_estatisticas_completas',
      () async {
        // Usar enhanced query optimizer ao invés do antigo
        final optimized = await _queryOptimizer.getOptimizedStatistics(
          () => findAll(),
          () => _getTaskService.findAll(),
          useCompositeCache: true,
        );

        // Converter para formato esperado
        return {
          'total': optimized['total_plantas'] ?? 0,
          'ativas': optimized['plantas_ativas'] ?? 0,
          'com_tarefas': optimized['plantas_com_tarefas'] ?? 0,
          'por_espaco':
              (optimized['plantas_por_espaco'] as Map<String, dynamic>?)
                      ?.length ??
                  0,
        };
      },
      type: StatisticType.aggregated,
      dependencies: ['plantas', 'tarefas'],
    );
  }

  /// Contar plantas por espaço
  ///
  /// ISSUE #33: Mixed Abstraction Levels - DEPRECATED HIGH-LEVEL OPERATION
  /// DEPRECATED: Esta operação de estatística complexa foi movida para RepositoryQueryFacade
  /// Use: RepositoryQueryFacade.instance.getDashboardQueries() -> spaceUtilization
  ///
  /// Este método será removido na v2.0
  @override
  @Deprecated(
      'Use RepositoryQueryFacade.getDashboardQueries() - será removido na v2.0')
  Future<Map<String, int>> countByEspaco() async {
    // OTIMIZAÇÃO ISSUE #13: Usar lazy evaluation para estatísticas frequentes
    return _lazyEval.lazyPlantaCountByEspaco();
  }

  /// Salvar planta (create ou update) - Método simplificado (herdado do BaseRepository como 'save')
  Future<String> salvar(PlantaModel planta) async {
    return await save(planta);
  }

  /// Mover planta para outro espaço - Método simplificado
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (IDs envolvidos, sucesso/falha)
  /// - Validação dos IDs (formato, existência, autorização)
  /// - Coleta de estatísticas (movimentações por período)
  /// - Business rules validation (espaço destino existe e está ativo)
  Future<void> moverParaEspaco(String plantaId, String novoEspacoId) async {
    // ISSUE #35: Validações feitas automaticamente pelo ValidationAspect
    // Assertions removidas pois agora são responsabilidade dos aspectos

    final planta = await findById(plantaId);
    if (planta == null) {
      // ISSUE #35: Warning logging feito automaticamente pelo LoggingAspect
      return;
    }

    final plantaMovida = planta.copyWith(espacoId: novoEspacoId);
    await update(plantaId, plantaMovida);
  }

  /// Adicionar imagem - Método simplificado
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (plantaId, imagePath, resultado)
  /// - Validação dos parâmetros (IDs válidos, path de imagem válido)
  /// - Coleta de estatísticas (imagens por planta, tipos de arquivo)
  /// - Security validation (path não contém ../ ou outros patterns maliciosos)
  Future<void> adicionarImagem(String plantaId, String imagePath) async {
    // ISSUE #35: Validações feitas automaticamente pelo ValidationAspect
    // Assertions removidas pois agora são responsabilidade dos aspectos

    final planta = await findById(plantaId);
    if (planta == null) {
      // ISSUE #35: Warning logging feito automaticamente pelo LoggingAspect
      return;
    }

    // Null object pattern: garantir lista não-nula
    final imagensAtuais = planta.imagePaths ?? <String>[];
    final novasImagens = [...imagensAtuais, imagePath];
    final plantaComImagem = planta.copyWith(imagePaths: novasImagens);
    await update(plantaId, plantaComImagem);
  }

  /// Remover imagem - Método simplificado
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging da operação (plantaId, imagePath removido, resultado)
  /// - Validação dos parâmetros (IDs válidos, path existe na lista)
  /// - Coleta de estatísticas (remoções de imagem, cleanup patterns)
  /// - Cleanup automático de arquivos órfãos se configurado
  Future<void> removerImagem(String plantaId, String imagePath) async {
    // ISSUE #35: Validações feitas automaticamente pelo ValidationAspect
    // Assertions removidas pois agora são responsabilidade dos aspectos

    final planta = await findById(plantaId);
    if (planta == null) {
      // ISSUE #35: Warning logging feito automaticamente pelo LoggingAspect
      return;
    }

    // Null object pattern: garantir lista não-nula
    final imagensAtuais = planta.imagePaths ?? <String>[];
    final novasImagens =
        imagensAtuais.where((path) => path != imagePath).toList();
    final plantaSemImagem = planta.copyWith(imagePaths: novasImagens);
    await update(plantaId, plantaSemImagem);
  }

  // Métodos auxiliares - Implementação real integrada com PlantaConfigRepository e SimpleTaskService

  /// Preparar plantas para busca otimizada
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP aplicam automaticamente:
  /// - Logging detalhado do processo de setup (início, etapas, resultado)
  /// - Error handling com retry automático se configurado
  /// - Coleta de estatísticas (tempo de setup, cache warming effectiveness)
  Future<void> setupOptimizedSearch() async {
    // ISSUE #35: Logging e error handling são feitos pelos aspectos
    try {
      // Preparar documentos Firebase para busca
      await syncService.prepareCollectionForOptimizedSearch();

      // Warm up cache com termos comuns
      await syncService.warmupSearchCache(
        commonTerms: ['rosa', 'suculenta', 'samambaia', 'orquídea', 'cactus'],
      );
    } catch (e) {
      // ISSUE #35: Exception logging e handling feito automaticamente
      rethrow; // Re-lançar para que os aspectos possam processar
    }
  }

  /// Obter relatório de performance das queries
  Future<Map<String, dynamic>> getQueryPerformanceReport() async {
    return await syncService.getQueryPerformanceReport();
  }

  // Implementações básicas para interface IPlantaRepository
  
  /// Criar nova planta
  @override
  Future<String> criar(PlantaModel planta) async {
    return await create(planta);
  }

  /// Atualizar planta existente
  @override
  Future<void> atualizar(PlantaModel planta) async {
    await update(planta.id, planta);
  }

  /// Remover planta
  @override
  Future<void> remover(String id) async {
    await delete(id);
  }

  /// Buscar múltiplas plantas por IDs
  @override
  Future<List<PlantaModel>> findByIds(List<String> ids) async {
    final allPlantas = await findAll();
    return allPlantas.where((p) => ids.contains(p.id)).toList();
  }

  /// Remover múltiplas plantas por espaço
  @override
  Future<void> removerPorEspaco(String espacoId) async {
    final plantas = await findByEspaco(espacoId);
    for (final planta in plantas) {
      await delete(planta.id);
    }
  }

  // Métodos toggle faltantes
  @override
  Future<void> toggleAgua(String plantaId) async {
    // TODO: Implementar toggle água
  }
  
  @override
  Future<void> toggleAdubo(String plantaId) async {
    // TODO: Implementar toggle adubo
  }
  
  @override
  Future<void> toggleBanhoSol(String plantaId) async {
    // TODO: Implementar toggle banho de sol
  }
  
  @override
  Future<void> toggleInspecaoPragas(String plantaId) async {
    // TODO: Implementar toggle inspeção de pragas
  }
  
  @override
  Future<void> togglePoda(String plantaId) async {
    // TODO: Implementar toggle poda
  }
  
  @override
  Future<void> toggleReplantio(String plantaId) async {
    // TODO: Implementar toggle replantio
  }

  // Streams stub para cuidados específicos
  @override
  Stream<List<PlantaModel>> watchPrecisaAguaHoje() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchPrecisaAduboHoje() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchPrecisaBanhoSolHoje() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchPrecisaInspecaoPragasHoje() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchPrecisaPodaHoje() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchPrecisaReplantioHoje() => const Stream.empty();

  @override
  Stream<List<PlantaModel>> watchComAguaAtiva() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchComAduboAtivo() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchComBanhoSolAtivo() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchComInspecaoPragasAtiva() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchComPodaAtiva() => const Stream.empty();
  
  @override
  Stream<List<PlantaModel>> watchComReplantioAtivo() => const Stream.empty();

  // Métodos de completar cuidados - implementações stub
  @override
  Future<void> completarRega(String plantaId) async {
    // TODO: Implementar lógica de completar rega
  }
  
  @override
  Future<void> completarAdubacao(String plantaId) async {
    // TODO: Implementar lógica de completar adubação
  }
  
  @override
  Future<void> completarBanhoSol(String plantaId) async {
    // TODO: Implementar lógica de completar banho de sol
  }
  
  @override
  Future<void> completarInspecaoPragas(String plantaId) async {
    // TODO: Implementar lógica de completar inspeção de pragas
  }
  
  @override
  Future<void> completarPoda(String plantaId) async {
    // TODO: Implementar lógica de completar poda
  }
  
  @override
  Future<void> completarReplantio(String plantaId) async {
    // TODO: Implementar lógica de completar replantio
  }

  /// Limpar recursos (incluindo streams e cache)
  ///
  /// ISSUE #35: Repository Responsibilities - Cross-cutting concerns externalizados
  /// Os aspectos AOP fazem limpeza automaticamente:
  /// - StatisticsAspect: Flush de estatísticas e limpeza de cache
  /// - LoggingAspect: Flush de logs pendentes
  /// - ValidationAspect: Limpeza de cache de validações
  @override
  Future<void> dispose() async {
    // OTIMIZAÇÃO ISSUE #13: Invalidar caches de otimização
    _memo.invalidateByDependency('plantas');
    _lazyEval.invalidateOnDataChange('plantas');

    // ISSUE #35: Aspectos fazem dispose automático via AspectManager
    // Não é necessário chamar dispose manual dos aspectos

    // Chamar dispose do BaseRepository
    await super.dispose();
  }
}
