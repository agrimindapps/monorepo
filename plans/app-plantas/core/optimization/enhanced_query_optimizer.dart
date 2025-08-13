// Dart imports:
import 'dart:async';

// Project imports:
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import 'memoization_manager.dart';
import 'statistics_cache_service.dart';

/// Enhanced Query Optimizer com índices e otimizações avançadas
/// Resolve problemas N+1, implementa índices em memória e otimização de queries
class EnhancedQueryOptimizer {
  static EnhancedQueryOptimizer? _instance;
  static EnhancedQueryOptimizer get instance =>
      _instance ??= EnhancedQueryOptimizer._();

  EnhancedQueryOptimizer._();

  final MemoizationManager _memo = MemoizationManager.instance;
  final StatisticsCacheService _statsCache = StatisticsCacheService.instance;

  // Índices em memória para otimização
  final Map<String, QueryIndex<PlantaModel>> _plantaIndexes = {};
  final Map<String, QueryIndex<TarefaModel>> _tarefaIndexes = {};

  // Cache de query plans para otimização
  final Map<String, QueryPlan> _queryPlanCache = {};

  // Estatísticas de query performance
  final Map<String, QueryStats> _queryStats = {};

  /// Inicializar otimizador com dados para construção de índices
  Future<void> initialize({
    Future<List<PlantaModel>> Function()? plantaProvider,
    Future<List<TarefaModel>> Function()? tarefaProvider,
  }) async {
    if (plantaProvider != null) {
      await _buildPlantaIndexes(plantaProvider);
    }
    if (tarefaProvider != null) {
      await _buildTarefaIndexes(tarefaProvider);
    }
  }

  /// Query otimizada para plantas que precisam de cuidados hoje
  /// Resolve N+1 com 1 query e usa índices para lookup O(1)
  Future<OptimizedPlantaCuidadosResult> findPlantasNeedingCareOptimized(
    Future<List<PlantaModel>> Function() plantaProvider,
    Future<List<TarefaModel>> Function() tarefaProvider,
  ) async {
    const queryKey = 'plantas_needing_care_optimized';

    return _memo.memoize(
      queryKey,
      () => _executeOptimizedCuidadosQuery(plantaProvider, tarefaProvider),
      category: 'optimized_queries',
      customTtl: const Duration(minutes: 10),
      dependencies: ['plantas', 'tarefas'],
    );
  }

  /// Estatísticas otimizadas com múltiplas estratégias de cache
  Future<Map<String, dynamic>> getOptimizedStatistics(
    Future<List<PlantaModel>> Function() plantaProvider,
    Future<List<TarefaModel>> Function() tarefaProvider, {
    bool useCompositeCache = true,
  }) async {
    if (useCompositeCache) {
      return _statsCache.cacheCompositeStatistics(
        'complete_statistics',
        () => _computeCompleteStatistics(plantaProvider, tarefaProvider),
        statisticsDependencies: ['plantas', 'tarefas', 'espacos'],
      );
    }

    final basicStats = await _statsCache.cacheStatistics(
      'basic_statistics',
      () => _computeBasicStatistics(plantaProvider, tarefaProvider),
      type: StatisticType.aggregated,
      dependencies: ['plantas', 'tarefas'],
    );

    return Map<String, dynamic>.from(basicStats);
  }

  /// Query builder fluente com otimizações automáticas
  OptimizedQueryBuilder<T> query<T>() => OptimizedQueryBuilder<T>(this);

  /// Executar query com plano de otimização automático
  Future<List<T>> executeOptimizedQuery<T>(QueryRequest<T> request) async {
    final plan = _generateQueryPlan(request);
    final queryKey = _buildQueryKey(request);

    return _memo.memoize(
      queryKey,
      () => _executeWithPlan(request, plan),
      category: 'optimized_executions',
      customTtl: plan.suggestedTtl,
    );
  }

  /// Refresh índices quando dados mudarem
  Future<void> refreshIndexes({
    Future<List<PlantaModel>> Function()? plantaProvider,
    Future<List<TarefaModel>> Function()? tarefaProvider,
  }) async {
    if (plantaProvider != null) {
      _plantaIndexes.clear();
      await _buildPlantaIndexes(plantaProvider);
    }
    if (tarefaProvider != null) {
      _tarefaIndexes.clear();
      await _buildTarefaIndexes(tarefaProvider);
    }

    // Invalidar caches relacionados
    _memo.invalidateByDependency('plantas');
    _memo.invalidateByDependency('tarefas');
  }

  /// Obter estatísticas de performance das queries
  Map<String, QueryStats> getQueryStatistics() => Map.unmodifiable(_queryStats);

  /// Análise de performance para otimização
  QueryAnalysis analyzeQuery<T>(QueryRequest<T> request) {
    final plan = _generateQueryPlan(request);
    final estimatedCost = _estimateQueryCost(request, plan);

    return QueryAnalysis(
      request: request,
      plan: plan,
      estimatedCost: estimatedCost,
      recommendations: _generateOptimizationRecommendations(request, plan),
    );
  }

  // Implementações privadas
  Future<void> _buildPlantaIndexes(
      Future<List<PlantaModel>> Function() provider) async {
    final plantas = await provider();

    // Índice por espaço
    _plantaIndexes['espacoId'] = QueryIndex.build(
      plantas,
      keyExtractor: (planta) => planta.espacoId ?? 'sem_espaco',
    );

    // Índice por nome (para buscas)
    _plantaIndexes['nome'] = QueryIndex.build(
      plantas,
      keyExtractor: (planta) => planta.nome?.toLowerCase() ?? 'sem_nome',
    );

    // Índice por status ativo (assumir todas ativas)
    _plantaIndexes['ativo'] = QueryIndex.build(
      plantas,
      keyExtractor: (planta) => 'true', // Assumir todas ativas por ora
    );
  }

  Future<void> _buildTarefaIndexes(
      Future<List<TarefaModel>> Function() provider) async {
    final tarefas = await provider();

    // Índice por planta
    _tarefaIndexes['plantaId'] = QueryIndex.build(
      tarefas,
      keyExtractor: (tarefa) => tarefa.plantaId,
    );

    // Índice por status
    _tarefaIndexes['concluida'] = QueryIndex.build(
      tarefas,
      keyExtractor: (tarefa) => tarefa.concluida.toString(),
    );

    // Índice por data (agrupamento por dia)
    _tarefaIndexes['data'] = QueryIndex.build(
      tarefas,
      keyExtractor: (tarefa) {
        final date = tarefa.dataExecucao;
        return '${date.year}-${date.month}-${date.day}';
      },
    );

    // Índice por tipo de cuidado
    _tarefaIndexes['tipoCuidado'] = QueryIndex.build(
      tarefas,
      keyExtractor: (tarefa) => tarefa.tipoCuidado,
    );
  }

  Future<OptimizedPlantaCuidadosResult> _executeOptimizedCuidadosQuery(
    Future<List<PlantaModel>> Function() plantaProvider,
    Future<List<TarefaModel>> Function() tarefaProvider,
  ) async {
    final startTime = DateTime.now();

    // Buscar dados em paralelo (2 queries ao invés de N+1)
    final results = await Future.wait([
      plantaProvider(),
      tarefaProvider(),
    ]);

    final plantas = results[0] as List<PlantaModel>;
    final tarefas = results[1] as List<TarefaModel>;

    // Usar índices para processamento otimizado
    final hoje = DateTime.now();
    final hojeKey = '${hoje.year}-${hoje.month}-${hoje.day}';

    // Buscar tarefas de hoje usando índice (O(1))
    final tarefasHoje =
        _tarefaIndexes['data']?.getValues(hojeKey) ?? <TarefaModel>[];
    final tarefasPendentesHoje =
        tarefasHoje.where((t) => !t.concluida).toList();

    // Agrupar por planta usando Set para lookup O(1)
    final plantasComTarefasHoje =
        tarefasPendentesHoje.map((t) => t.plantaId).toSet();

    // Filtrar plantas que precisam cuidado
    final plantasNeedingCare =
        plantas.where((p) => plantasComTarefasHoje.contains(p.id)).toList();

    final executionTime = DateTime.now().difference(startTime);

    return OptimizedPlantaCuidadosResult(
      plantasNeedingCare: plantasNeedingCare,
      tarefasPendentesHoje: tarefasPendentesHoje,
      totalPlantas: plantas.length,
      totalTarefas: tarefas.length,
      executionTime: executionTime,
      optimizationUsed: ['index_lookup', 'parallel_fetch', 'set_contains'],
    );
  }

  Future<Map<String, dynamic>> _computeCompleteStatistics(
    Future<List<PlantaModel>> Function() plantaProvider,
    Future<List<TarefaModel>> Function() tarefaProvider,
  ) async {
    // Usar índices para cálculos otimizados
    final plantas = await plantaProvider();
    final tarefas = await tarefaProvider();

    // Estatísticas usando índices
    final plantasByEspaco = _plantaIndexes['espacoId']?.getAllGroups() ?? {};
    final tarefasByStatus = _tarefaIndexes['concluida']?.getAllGroups() ?? {};
    final tarefasByTipo = _tarefaIndexes['tipoCuidado']?.getAllGroups() ?? {};

    return {
      'total_plantas': plantas.length,
      'total_tarefas': tarefas.length,
      'plantas_por_espaco':
          plantasByEspaco.map((k, v) => MapEntry(k, v.length)),
      'tarefas_concluidas': tarefasByStatus['true']?.length ?? 0,
      'tarefas_pendentes': tarefasByStatus['false']?.length ?? 0,
      'tarefas_por_tipo': tarefasByTipo.map((k, v) => MapEntry(k, v.length)),
    };
  }

  Future<Map<String, int>> _computeBasicStatistics(
    Future<List<PlantaModel>> Function() plantaProvider,
    Future<List<TarefaModel>> Function() tarefaProvider,
  ) async {
    final results = await Future.wait([plantaProvider(), tarefaProvider()]);
    final plantas = results[0] as List<PlantaModel>;
    final tarefas = results[1] as List<TarefaModel>;

    return {
      'total_plantas': plantas.length,
      'total_tarefas': tarefas.length,
      'plantas_ativas': plantas.length, // Assumir todas ativas
      'tarefas_concluidas': tarefas.where((t) => t.concluida).length,
    };
  }

  QueryPlan _generateQueryPlan<T>(QueryRequest<T> request) {
    final cacheKey = _buildQueryKey(request);

    if (_queryPlanCache.containsKey(cacheKey)) {
      return _queryPlanCache[cacheKey]!;
    }

    final plan = QueryPlan(
      useIndexes: _shouldUseIndexes(request),
      suggestedTtl: _calculateOptimalTtl(request),
      parallelizable: _isParallelizable(request),
      estimatedCost: _estimateQueryCost(request, null),
    );

    _queryPlanCache[cacheKey] = plan;
    return plan;
  }

  Future<List<T>> _executeWithPlan<T>(
      QueryRequest<T> request, QueryPlan plan) async {
    final startTime = DateTime.now();

    try {
      List<T> result;

      if (plan.useIndexes && _hasRelevantIndexes<T>(request)) {
        result = await _executeWithIndexes(request);
      } else {
        result = await _executeStandard(request);
      }

      _recordQueryStats(_buildQueryKey(request), startTime, result.length);
      return result;
    } catch (error) {
      _recordQueryError(_buildQueryKey(request), startTime, error);
      rethrow;
    }
  }

  Future<List<T>> _executeWithIndexes<T>(QueryRequest<T> request) async {
    // Implementação usando índices baseado no tipo de request
    throw UnimplementedError(
        'Index-based execution not implemented for this query type');
  }

  Future<List<T>> _executeStandard<T>(QueryRequest<T> request) async {
    // Implementação standard sem índices
    throw UnimplementedError('Standard execution not implemented');
  }

  bool _shouldUseIndexes<T>(QueryRequest<T> request) {
    return _hasRelevantIndexes<T>(request) && request.filters.isNotEmpty;
  }

  bool _hasRelevantIndexes<T>(QueryRequest<T> request) {
    if (T == PlantaModel) {
      return request.filters.any((f) => _plantaIndexes.containsKey(f.field));
    } else if (T == TarefaModel) {
      return request.filters.any((f) => _tarefaIndexes.containsKey(f.field));
    }
    return false;
  }

  Duration _calculateOptimalTtl<T>(QueryRequest<T> request) {
    // Calcular TTL baseado no tipo de query e dados
    if (request.filters.any((f) => f.field == 'data')) {
      return const Duration(
          minutes: 5); // Queries com data mudam frequentemente
    }
    return const Duration(minutes: 10); // Default
  }

  bool _isParallelizable<T>(QueryRequest<T> request) {
    return request.filters.length >
        1; // Múltiplos filtros podem ser paralelizados
  }

  int _estimateQueryCost<T>(QueryRequest<T> request, QueryPlan? plan) {
    // Estimativa de custo baseada na complexidade
    int baseCost = 10;
    baseCost += request.filters.length * 5;

    if (plan?.useIndexes == true) {
      baseCost = (baseCost * 0.3).round(); // 70% redução com índices
    }

    return baseCost;
  }

  List<String> _generateOptimizationRecommendations<T>(
    QueryRequest<T> request,
    QueryPlan plan,
  ) {
    final recommendations = <String>[];

    if (!plan.useIndexes && request.filters.isNotEmpty) {
      recommendations
          .add('Consider building indexes for frequently queried fields');
    }

    if (request.filters.length > 3) {
      recommendations
          .add('Consider breaking down complex queries into simpler ones');
    }

    return recommendations;
  }

  String _buildQueryKey<T>(QueryRequest<T> request) {
    final parts = [
      T.toString(),
      ...request.filters.map((f) => '${f.field}:${f.value}'),
      if (request.sortBy != null) 'sort:${request.sortBy}',
      if (request.limit != null) 'limit:${request.limit}',
    ];
    return parts.join('_');
  }

  void _recordQueryStats(String queryKey, DateTime startTime, int resultCount) {
    final executionTime = DateTime.now().difference(startTime);
    final stats = _queryStats.putIfAbsent(queryKey, () => QueryStats());

    stats.recordExecution(executionTime, resultCount);
  }

  void _recordQueryError(String queryKey, DateTime startTime, dynamic error) {
    final executionTime = DateTime.now().difference(startTime);
    final stats = _queryStats.putIfAbsent(queryKey, () => QueryStats());

    stats.recordError(executionTime, error);
  }
}

/// Resultado otimizado para queries de plantas com cuidados
class OptimizedPlantaCuidadosResult {
  final List<PlantaModel> plantasNeedingCare;
  final List<TarefaModel> tarefasPendentesHoje;
  final int totalPlantas;
  final int totalTarefas;
  final Duration executionTime;
  final List<String> optimizationUsed;

  OptimizedPlantaCuidadosResult({
    required this.plantasNeedingCare,
    required this.tarefasPendentesHoje,
    required this.totalPlantas,
    required this.totalTarefas,
    required this.executionTime,
    required this.optimizationUsed,
  });

  Map<String, dynamic> toMap() => {
        'plantas_needing_care_count': plantasNeedingCare.length,
        'tarefas_pendentes_hoje_count': tarefasPendentesHoje.length,
        'total_plantas': totalPlantas,
        'total_tarefas': totalTarefas,
        'execution_time_ms': executionTime.inMilliseconds,
        'optimizations': optimizationUsed,
      };
}

/// Índice de query para lookup otimizado
class QueryIndex<T> {
  final Map<String, List<T>> _index = {};

  QueryIndex.build(List<T> items, {required String Function(T) keyExtractor}) {
    for (final item in items) {
      final key = keyExtractor(item);
      _index.putIfAbsent(key, () => []).add(item);
    }
  }

  List<T>? getValues(String key) => _index[key];

  Map<String, List<T>> getAllGroups() => Map.unmodifiable(_index);

  int get totalGroups => _index.length;

  int get totalItems => _index.values.fold(0, (sum, list) => sum + list.length);
}

/// Builder fluente para queries otimizadas
class OptimizedQueryBuilder<T> {
  final EnhancedQueryOptimizer _optimizer;
  final List<QueryFilter> _filters = [];
  String? _sortBy;
  int? _limit;

  OptimizedQueryBuilder(this._optimizer);

  OptimizedQueryBuilder<T> where(String field, dynamic value) {
    _filters.add(QueryFilter(field: field, value: value));
    return this;
  }

  OptimizedQueryBuilder<T> sortBy(String field) {
    _sortBy = field;
    return this;
  }

  OptimizedQueryBuilder<T> limit(int count) {
    _limit = count;
    return this;
  }

  Future<List<T>> execute() async {
    final request = QueryRequest<T>(
      filters: _filters,
      sortBy: _sortBy,
      limit: _limit,
    );

    return _optimizer.executeOptimizedQuery(request);
  }

  QueryAnalysis analyze() {
    final request = QueryRequest<T>(
      filters: _filters,
      sortBy: _sortBy,
      limit: _limit,
    );

    return _optimizer.analyzeQuery(request);
  }
}

/// Request de query estruturado
class QueryRequest<T> {
  final List<QueryFilter> filters;
  final String? sortBy;
  final int? limit;

  QueryRequest({
    required this.filters,
    this.sortBy,
    this.limit,
  });
}

/// Filtro de query
class QueryFilter {
  final String field;
  final dynamic value;

  QueryFilter({required this.field, required this.value});
}

/// Plano de query para otimização
class QueryPlan {
  final bool useIndexes;
  final Duration suggestedTtl;
  final bool parallelizable;
  final int estimatedCost;

  QueryPlan({
    required this.useIndexes,
    required this.suggestedTtl,
    required this.parallelizable,
    required this.estimatedCost,
  });
}

/// Análise de query para otimização
class QueryAnalysis {
  final QueryRequest request;
  final QueryPlan plan;
  final int estimatedCost;
  final List<String> recommendations;

  QueryAnalysis({
    required this.request,
    required this.plan,
    required this.estimatedCost,
    required this.recommendations,
  });
}

/// Estatísticas de performance de queries
class QueryStats {
  int _executionCount = 0;
  int _errorCount = 0;
  Duration _totalExecutionTime = Duration.zero;
  int _totalResultCount = 0;
  DateTime? _lastExecuted;
  final List<dynamic> _recentErrors = <dynamic>[];

  void recordExecution(Duration executionTime, int resultCount) {
    _executionCount++;
    _totalExecutionTime += executionTime;
    _totalResultCount += resultCount;
    _lastExecuted = DateTime.now();
  }

  void recordError(Duration executionTime, dynamic error) {
    _errorCount++;
    _totalExecutionTime += executionTime;
    _lastExecuted = DateTime.now();

    (_recentErrors).add(error);
    if (_recentErrors.length > 10) {
      (_recentErrors).removeAt(0);
    }
  }

  double get averageExecutionTime {
    return _executionCount > 0
        ? _totalExecutionTime.inMilliseconds / _executionCount
        : 0.0;
  }

  double get averageResultCount {
    return _executionCount > 0 ? _totalResultCount / _executionCount : 0.0;
  }

  double get errorRate {
    final total = _executionCount + _errorCount;
    return total > 0 ? _errorCount / total : 0.0;
  }

  Map<String, dynamic> toMap() => {
        'execution_count': _executionCount,
        'error_count': _errorCount,
        'average_execution_time_ms': averageExecutionTime,
        'average_result_count': averageResultCount,
        'error_rate': errorRate,
        'last_executed': _lastExecuted?.toIso8601String(),
        'recent_errors': _recentErrors.map((e) => e.toString()).toList(),
      };
}
