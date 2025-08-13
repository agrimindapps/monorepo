// Project imports:
import '../../database/tarefa_model.dart';
import '../../repository/stream/optimized_stream_transformers.dart';
import '../extensions/datetime_extensions.dart';
import '../optimization/filtering_optimizer.dart';
import 'tarefa_filter_criteria.dart';

/// Service centralizado para filtros de tarefas
/// Elimina duplicação de lógica e centraliza critérios de filtro
class TarefaFilterService with OptimizedFiltering {
  static TarefaFilterService? _instance;
  static TarefaFilterService get instance =>
      _instance ??= TarefaFilterService._();

  TarefaFilterService._();

  /// Método genérico para filtrar tarefas usando Strategy pattern
  List<TarefaModel> filterTasks(
    List<TarefaModel> tasks,
    TarefaFilterCriteria criteria, {
    bool useCache = true,
  }) {
    if (tasks.isEmpty) return [];

    if (useCache) {
      return cachedFilter(
        tasks,
        (tarefa) => criteria.apply(tarefa),
        criteria.cacheKey,
      );
    }

    return tasks.where((tarefa) => criteria.apply(tarefa)).toList();
  }

  /// Stream filtrada com critério específico (OTIMIZADA)
  Stream<List<TarefaModel>> filterStream(
    Stream<List<TarefaModel>> stream,
    TarefaFilterCriteria criteria, {
    Duration debounceDuration = const Duration(milliseconds: 300),
  }) {
    return stream.cachedWhere(
      (tarefa) => criteria.apply(tarefa),
      cacheKey: criteria.cacheKey,
      debounceTime: debounceDuration,
    );
  }

  /// Filtro com múltiplos critérios
  List<TarefaModel> filterWithMultipleCriteria(
    List<TarefaModel> tasks,
    List<TarefaFilterCriteria> criteria, {
    bool useAnd = true,
    bool useCache = true,
  }) {
    if (criteria.isEmpty) return tasks;

    final compositeCriteria = CompositeCriteria(criteria, useAnd: useAnd);
    return filterTasks(tasks, compositeCriteria, useCache: useCache);
  }

  /// Builder pattern para consultas complexas
  TarefaQueryBuilder query(List<TarefaModel> tasks) {
    return TarefaQueryBuilder._(tasks, this);
  }

  /// Métodos específicos otimizados (factory methods)

  /// Tarefas para hoje (pendentes)
  List<TarefaModel> findParaHoje(List<TarefaModel> tasks) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.today);
  }

  /// Tarefas futuras (pendentes)
  List<TarefaModel> findFuturas(List<TarefaModel> tasks) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.future);
  }

  /// Tarefas atrasadas (pendentes)
  List<TarefaModel> findAtrasadas(List<TarefaModel> tasks) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.overdue);
  }

  /// Tarefas pendentes (todas não concluídas)
  List<TarefaModel> findPendentes(List<TarefaModel> tasks) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.pending);
  }

  /// Tarefas concluídas
  List<TarefaModel> findConcluidas(List<TarefaModel> tasks) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.completed);
  }

  /// Tarefas por planta
  List<TarefaModel> findByPlanta(List<TarefaModel> tasks, String plantaId) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.forPlant(plantaId));
  }

  /// Tarefas por tipo de cuidado
  List<TarefaModel> findByTipoCuidado(
      List<TarefaModel> tasks, String tipoCuidado) {
    return filterTasks(
        tasks, TarefaFilterCriteriaFactory.forCareType(tipoCuidado));
  }

  /// Tarefas em período específico
  List<TarefaModel> findByPeriodo(
      List<TarefaModel> tasks, DateTime inicio, DateTime fim) {
    return filterTasks(
        tasks, TarefaFilterCriteriaFactory.forPeriod(inicio, fim));
  }

  /// Streams otimizados (factory methods)

  /// Stream de tarefas para hoje
  Stream<List<TarefaModel>> watchParaHoje(Stream<List<TarefaModel>> stream) {
    return filterStream(stream, TarefaFilterCriteriaFactory.today);
  }

  /// Stream de tarefas futuras
  Stream<List<TarefaModel>> watchFuturas(Stream<List<TarefaModel>> stream) {
    return filterStream(stream, TarefaFilterCriteriaFactory.future);
  }

  /// Stream de tarefas atrasadas
  Stream<List<TarefaModel>> watchAtrasadas(Stream<List<TarefaModel>> stream) {
    return filterStream(stream, TarefaFilterCriteriaFactory.overdue);
  }

  /// Stream de tarefas pendentes
  Stream<List<TarefaModel>> watchPendentes(Stream<List<TarefaModel>> stream) {
    return filterStream(stream, TarefaFilterCriteriaFactory.pending);
  }

  /// Stream de tarefas concluídas
  Stream<List<TarefaModel>> watchConcluidas(Stream<List<TarefaModel>> stream) {
    return filterStream(stream, TarefaFilterCriteriaFactory.completed);
  }

  /// Stream de tarefas por planta
  Stream<List<TarefaModel>> watchByPlanta(
      Stream<List<TarefaModel>> stream, String plantaId) {
    return filterStream(stream, TarefaFilterCriteriaFactory.forPlant(plantaId));
  }

  /// Métodos combinados frequentes

  /// Tarefas urgentes (hoje + atrasadas)
  List<TarefaModel> findUrgentes(List<TarefaModel> tasks) {
    return filterTasks(tasks, TarefaFilterCriteriaFactory.urgent());
  }

  /// Tarefas urgentes por planta
  List<TarefaModel> findUrgentesForPlanta(
      List<TarefaModel> tasks, String plantaId) {
    return filterTasks(
        tasks, TarefaFilterCriteriaFactory.urgentForPlant(plantaId));
  }

  /// Tarefas pendentes por planta
  List<TarefaModel> findPendentesByPlanta(
      List<TarefaModel> tasks, String plantaId) {
    return filterTasks(
        tasks,
        TarefaFilterCriteriaFactory.and([
          TarefaFilterCriteriaFactory.pending,
          TarefaFilterCriteriaFactory.forPlant(plantaId)
        ]));
  }

  /// Filtro otimizado por data usando QueryOptimizer pattern
  TarefaDateCriteriaResult processDateCriteria(List<TarefaModel> tasks) {
    return FilteringOptimizer.getOrCompute(
      'date_criteria_batch',
      () {
        final hoje = <TarefaModel>[];
        final futuras = <TarefaModel>[];
        final atrasadas = <TarefaModel>[];
        final pendentes = <TarefaModel>[];
        final concluidas = <TarefaModel>[];

        for (final tarefa in tasks) {
          if (tarefa.concluida) {
            concluidas.add(tarefa);
          } else {
            pendentes.add(tarefa);

            if (tarefa.dataExecucao.isToday) {
              hoje.add(tarefa);
            } else if (tarefa.dataExecucao.isAfterToday) {
              futuras.add(tarefa);
            } else if (tarefa.dataExecucao.isBeforeToday) {
              atrasadas.add(tarefa);
            }
          }
        }

        return TarefaDateCriteriaResult(
          paraHoje: hoje,
          futuras: futuras,
          atrasadas: atrasadas,
          pendentes: pendentes,
          concluidas: concluidas,
        );
      },
    );
  }

  /// Limpar cache específico
  void invalidateCache([String? pattern]) {
    invalidateFilterCache(pattern);
  }

  /// Obter estatísticas de cache
  Map<String, dynamic> getCacheStats() {
    // Note: FilteringOptimizer cache fields are private, so using approximation
    return {
      'service_instance': 'TarefaFilterService.instance',
      'last_stats_check': DateTime.now().toIso8601String(),
      'filtering_enabled': true,
    };
  }
}

/// Builder para consultas complexas
class TarefaQueryBuilder {
  final List<TarefaModel> _tasks;
  final TarefaFilterService _service;
  final List<TarefaFilterCriteria> _criteria = [];

  TarefaQueryBuilder._(this._tasks, this._service);

  /// Adicionar critério de hoje
  TarefaQueryBuilder paraHoje() {
    _criteria.add(TarefaFilterCriteriaFactory.today);
    return this;
  }

  /// Adicionar critério de futuras
  TarefaQueryBuilder futuras() {
    _criteria.add(TarefaFilterCriteriaFactory.future);
    return this;
  }

  /// Adicionar critério de atrasadas
  TarefaQueryBuilder atrasadas() {
    _criteria.add(TarefaFilterCriteriaFactory.overdue);
    return this;
  }

  /// Adicionar critério de pendentes
  TarefaQueryBuilder pendentes() {
    _criteria.add(TarefaFilterCriteriaFactory.pending);
    return this;
  }

  /// Adicionar critério de concluídas
  TarefaQueryBuilder concluidas() {
    _criteria.add(TarefaFilterCriteriaFactory.completed);
    return this;
  }

  /// Adicionar critério por planta
  TarefaQueryBuilder forPlanta(String plantaId) {
    _criteria.add(TarefaFilterCriteriaFactory.forPlant(plantaId));
    return this;
  }

  /// Adicionar critério por tipo de cuidado
  TarefaQueryBuilder forCareType(String tipoCuidado) {
    _criteria.add(TarefaFilterCriteriaFactory.forCareType(tipoCuidado));
    return this;
  }

  /// Adicionar critério por período
  TarefaQueryBuilder forPeriod(DateTime inicio, DateTime fim) {
    _criteria.add(TarefaFilterCriteriaFactory.forPeriod(inicio, fim));
    return this;
  }

  /// Adicionar critério personalizado
  TarefaQueryBuilder where(TarefaFilterCriteria criteria) {
    _criteria.add(criteria);
    return this;
  }

  /// Executar com AND (todos critérios devem ser verdadeiros)
  List<TarefaModel> findAll() {
    return _service.filterWithMultipleCriteria(_tasks, _criteria, useAnd: true);
  }

  /// Executar com OR (pelo menos um critério deve ser verdadeiro)
  List<TarefaModel> findAny() {
    return _service.filterWithMultipleCriteria(_tasks, _criteria,
        useAnd: false);
  }

  /// Executar e retornar o primeiro resultado
  TarefaModel? findFirst() {
    final results = findAll();
    return results.isNotEmpty ? results.first : null;
  }

  /// Contar resultados sem carregar dados
  int count() {
    return findAll().length;
  }

  /// Verificar se existe algum resultado
  bool exists() {
    final results = findAll();
    return results.isNotEmpty;
  }
}

/// Resultado otimizado para processamento de critérios de data
class TarefaDateCriteriaResult {
  const TarefaDateCriteriaResult({
    required this.paraHoje,
    required this.futuras,
    required this.atrasadas,
    required this.pendentes,
    required this.concluidas,
  });

  final List<TarefaModel> paraHoje;
  final List<TarefaModel> futuras;
  final List<TarefaModel> atrasadas;
  final List<TarefaModel> pendentes;
  final List<TarefaModel> concluidas;

  /// Converter para map para compatibilidade
  Map<String, List<TarefaModel>> toMap() {
    return {
      'paraHoje': paraHoje,
      'futuras': futuras,
      'atrasadas': atrasadas,
      'pendentes': pendentes,
      'concluidas': concluidas,
    };
  }

  /// Obter total de tarefas processadas
  int get totalTasks =>
      paraHoje.length + futuras.length + atrasadas.length + concluidas.length;

  /// Obter total de tarefas pendentes
  int get totalPendentes => pendentes.length;

  /// Obter total de tarefas concluídas
  int get totalConcluidas => concluidas.length;

  /// Obter estatísticas detalhadas
  Map<String, int> get statistics => {
        'para_hoje': paraHoje.length,
        'futuras': futuras.length,
        'atrasadas': atrasadas.length,
        'pendentes': pendentes.length,
        'concluidas': concluidas.length,
        'total': totalTasks,
      };
}
