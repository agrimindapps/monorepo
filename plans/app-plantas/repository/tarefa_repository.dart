// Dart imports:
import 'dart:async';

// Project imports:
import '../core/filtering/date_criteria_strategy.dart';
import '../core/filtering/tarefa_filter_service.dart';
import '../core/interfaces/i_tarefa_repository.dart';
import '../core/optimization/lazy_evaluation_service.dart';
import '../core/optimization/query_optimizer.dart';
import '../database/tarefa_model.dart';
import 'base_repository.dart';
import 'planta_repository.dart';

/// Repository para Tarefas usando BaseRepository pattern
///
/// ISSUE #33: Mixed Abstraction Levels - SOLUTION IMPLEMENTED
///
/// ARQUITETURA REFATORADA - Mantém APENAS operações de baixo nível:
/// - CRUD básico para TarefaModel (create, read, update, delete)
/// - Operações simples de busca (findByPeriodo, findByTipoCuidado)
/// - Marcação básica de status (marcarConcluida, reagendar)
/// - Cache básico e stream management
///
/// Para operações de alto nível, use:
/// - RepositoryOperationsFacade: Operações batch e cross-entity
/// - RepositoryQueryFacade: Analytics e queries complexas
/// - BusinessRulesService: Validações de negócio (devecriarTarefaAutomatica, etc.)
/// - ValidationService: Validação de dados antes de operações CRUD
/// - StatisticsService: Estatísticas e métricas (getTarefaStatistics, etc.)
/// - TarefaFilterService: Filtros avançados e queries complexas
/// - TarefaStatisticsService: Estatísticas detalhadas e relatórios
///
/// CONSISTENT ABSTRACTION LEVEL: Foca apenas em persistência de TarefaModel.
class TarefaRepository extends BaseRepository<TarefaModel>
    with
        PlantCareFunctionality<TarefaModel>,
        TaskManagementFunctionality<TarefaModel>
    implements ITarefaRepository {
  static TarefaRepository? _instance;
  static TarefaRepository get instance => _instance ??= TarefaRepository._();

  // Otimização avançada - ISSUE #13 - campos movidos para métodos on-demand

  TarefaRepository._() : super();

  @override
  String get repositoryName => 'TarefaRepository';

  @override
  String get collectionName => 'tarefas';

  @override
  TarefaModel Function(Map<String, dynamic>) get fromJson =>
      TarefaModel.fromJson;

  @override
  Map<String, dynamic> Function(TarefaModel) get toJson =>
      (tarefa) => tarefa.toJson();

  @override
  String getItemId(TarefaModel item) => item.id;

  @override
  String getPlantaId(TarefaModel item) => item.plantaId;

  @override
  bool isTaskCompleted(TarefaModel item) => item.concluida;

  // repositoryConfig removido - usando CommonRepositoryConfigs no BaseRepository

  // Método _initializeSyncService removido - adapter registrado automaticamente

  /// Stream de todas as tarefas (backward compatibility)
  Stream<List<TarefaModel>> get tarefasStream => dataStream;

  // CRUD operations herdadas do BaseRepository
  // Mantém métodos legacy se necessário para backward compatibility

  @override
  void onItemCreated(String id, TarefaModel item) {
    QueryOptimizer.instance
        .invalidateRelatedCaches('tarefa_created', entityId: id);
  }

  @override
  void onItemUpdated(String id, TarefaModel item) {
    QueryOptimizer.instance
        .invalidateRelatedCaches('tarefa_updated', entityId: id);
  }

  @override
  void onItemDeleted(String id, TarefaModel item) {
    QueryOptimizer.instance
        .invalidateRelatedCaches('tarefa_deleted', entityId: id);
  }

  /// Criar nova tarefa (método legacy - mantido para compatibilidade)
  Future<String> createLegacy(TarefaModel tarefa) async {
    return await create(tarefa);
  }

  /// Atualizar tarefa (método legacy - mantido para compatibilidade)
  Future<void> updateLegacy(String id, TarefaModel tarefa) async {
    await update(id, tarefa);
  }

  /// Criar múltiplas tarefas com error handling robusto
  @override
  Future<List<String>> createBatch(List<TarefaModel> tarefas) async {
    if (tarefas.isEmpty) return [];

    return await executeBatchOperation<String, TarefaModel>(
      items: tarefas,
      itemOperation: (tarefa) async {
        // Operação individual com retry automático para network issues
        return await executeWithErrorHandling<String>(
          operation: () => syncService.create(tarefa),
          operationName: 'createSingleTarefa',
          enableRetry: true,
          context: {
            'tarefa_id': tarefa.id,
            'planta_id': tarefa.plantaId,
            'tipo_cuidado': tarefa.tipoCuidado,
          },
        );
      },
      operationType: 'createBatch',
      chunkSize: 30, // Processar em lotes de 30
      delayBetweenChunks: const Duration(milliseconds: 25),
      continueOnError: false, // Parar na primeira falha para operações críticas
      additionalContext: {
        'total_tarefas': tarefas.length,
        'plantas_envolvidas': tarefas.map((t) => t.plantaId).toSet().length,
        'tipos_cuidado': tarefas.map((t) => t.tipoCuidado).toSet().toList(),
      },
    ).then((ids) {
      // Invalidar cache após operação bem sucedida
      invalidateCache();
      QueryOptimizer.instance.invalidateRelatedCaches('tarefa_created');
      return ids;
    });
  }

  // Métodos clear() e forceSync() herdados do BaseRepository

  // Métodos específicos para Tarefas

  // Streams usando mixins - watchByPlanta herdado de PlantCareFunctionality
  // watchPendentes e watchConcluidas herdados de TaskManagementFunctionality

  // Métodos mantidos para usar TarefaFilterService quando necessário para lógica avançada

  /// Stream de tarefas para hoje (OTIMIZADO com FilterService)
  /// Para filtros avançados, use TarefaFilterService.instance diretamente
  @override
  Stream<List<TarefaModel>> watchParaHoje() {
    return TarefaFilterService.instance.watchParaHoje(tarefasStream);
  }

  /// Stream de tarefas futuras (OTIMIZADO com FilterService)
  /// Para filtros avançados, use TarefaFilterService.instance diretamente
  @override
  Stream<List<TarefaModel>> watchFuturas() {
    return TarefaFilterService.instance.watchFuturas(tarefasStream);
  }

  /// Stream de tarefas atrasadas (OTIMIZADO com FilterService)
  /// Para filtros avançados, use TarefaFilterService.instance diretamente
  @override
  Stream<List<TarefaModel>> watchAtrasadas() {
    return TarefaFilterService.instance.watchAtrasadas(tarefasStream);
  }

  // findByPlanta herdado de PlantCareFunctionality
  // Mantém implementação otimizada para queries avançadas
  Future<List<TarefaModel>> findByPlantaOptimized(String plantaId) {
    return QueryOptimizer.instance.findTarefasByPlanta(
      plantaId,
      () => findAll(),
    );
  }

  /// Buscar tarefas pendentes por planta (OTIMIZADO com FilterService)
  /// Para filtros avançados, use TarefaFilterService.instance diretamente
  Future<List<TarefaModel>> findPendentesByPlanta(String plantaId) async {
    final tarefas = await findAll();
    return TarefaFilterService.instance
        .findPendentesByPlanta(tarefas, plantaId);
  }

  /// Buscar tarefas por tipo de cuidado (OTIMIZADO com FilterService + cache)
  /// Para filtros avançados, use TarefaFilterService.instance diretamente
  @override
  Future<List<TarefaModel>> findByTipoCuidado(String tipoCuidado) {
    return cachedQuery(
      {'tipoCuidado': tipoCuidado},
      () async {
        final tarefas = await syncService.findAll();
        return TarefaFilterService.instance
            .findByTipoCuidado(tarefas, tipoCuidado);
      },
      'findByTipoCuidado',
      ttl: const Duration(minutes: 10),
    );
  }

  /// Buscar tarefas por período (OTIMIZADO com FilterService + cache)
  /// Para filtros avançados, use TarefaFilterService.instance diretamente
  Future<List<TarefaModel>> findByPeriodo(DateTime inicio, DateTime fim) {
    return cachedQuery(
      {'inicio': inicio.toIso8601String(), 'fim': fim.toIso8601String()},
      () async {
        final tarefas = await syncService.findAll();
        return TarefaFilterService.instance.findByPeriodo(tarefas, inicio, fim);
      },
      'findByPeriodo',
      ttl: const Duration(minutes: 15),
    );
  }

  /// Método genérico para buscar tarefas por critério de data (ISSUE #22)
  /// Usa Strategy pattern para eliminar duplicação de código
  /// Aceita qualquer DateCriteriaStrategy personalizada
  Future<List<TarefaModel>> findByDateCriteria(
      DateCriteriaStrategy strategy) async {
    return LazyEvaluationService.instance.dateQueries
        .findByDateCriteria(strategy);
  }

  /// Buscar tarefas para hoje (REFATORADO - ISSUE #22)
  /// Factory method que usa Strategy pattern internamente
  @override
  Future<List<TarefaModel>> findParaHoje() async {
    return findByDateCriteria(DateCriteriaFactory.today);
  }

  /// Buscar tarefas futuras (REFATORADO - ISSUE #22)
  /// Factory method que usa Strategy pattern internamente
  @override
  Future<List<TarefaModel>> findFuturas() async {
    return findByDateCriteria(DateCriteriaFactory.future);
  }

  /// Buscar tarefas atrasadas (REFATORADO - ISSUE #22)
  /// Factory method que usa Strategy pattern internamente
  @override
  Future<List<TarefaModel>> findAtrasadas() async {
    return findByDateCriteria(DateCriteriaFactory.overdue);
  }

  // findConcluidas e findPendentes herdados de TaskManagementFunctionality

  /// Buscar tarefas concluídas do dia (OTIMIZADO com cache)
  /// Para filtros avançados, use TarefaFilterService
  Future<List<TarefaModel>> findConcluidasHoje() {
    return cachedQuery(
      {'concluidasHoje': true},
      () async {
        final tarefas = await syncService.findAll();
        return tarefas.where((tarefa) {
          if (!tarefa.concluida) return false;
          final dataConclusao = tarefa.dataConclusao ?? tarefa.dataExecucao;
          return dataConclusao.isToday;
        }).toList();
      },
      'findConcluidasHoje',
      ttl: const Duration(minutes: 30),
    );
  }

  // Método removido - uso implementação herdada de TaskManagementFunctionality

  /// Marcar tarefa como concluída
  @override
  Future<void> marcarConcluida(String tarefaId, {DateTime? dataConclusao, String? observacoes}) async {
    return setConcluida(tarefaId, true, dataConclusao: dataConclusao, observacoes: observacoes);
  }

  /// Marcar tarefa como pendente
  @override
  Future<void> marcarPendente(String tarefaId) async {
    return setConcluida(tarefaId, false);
  }

  /// Definir status de conclusão da tarefa
  @override
  Future<void> setConcluida(String tarefaId, bool concluida,
      {DateTime? dataConclusao, String? observacoes}) async {
    final tarefa = await findById(tarefaId);
    if (tarefa == null) return;

    final tarefaAtualizada = concluida
        ? tarefa.copyWith(
            concluida: true,
            dataConclusao: dataConclusao ?? DateTime.now(),
            observacoes: observacoes,
          )
        : tarefa.marcarPendente();

    await update(tarefaId, tarefaAtualizada);
  }

  /// Reagendar tarefa
  Future<void> reagendar(String tarefaId, DateTime novaDataExecucao) async {
    final tarefa = await findById(tarefaId);
    if (tarefa == null) return;

    final tarefaReagendada = tarefa.copyWith(dataExecucao: novaDataExecucao);
    await update(tarefaId, tarefaReagendada);
  }

  /// Salvar tarefa (create ou update) - Método simplificado (herdado do BaseRepository como 'save')
  Future<String> salvar(TarefaModel tarefa) async {
    return await save(tarefa);
  }

  /// Métodos legacy - mantidos para compatibilidade

  /// Marcar tarefa como concluída (legacy)
  Future<void> marcarConcluidaLegacy(String tarefaId,
      {String? observacoes}) async {
    return setConcluidaLegacy(tarefaId, true, observacoes: observacoes);
  }

  /// Marcar tarefa como pendente (legacy)
  Future<void> marcarPendenteLegacy(String tarefaId) async {
    return setConcluidaLegacy(tarefaId, false);
  }

  /// Definir status de conclusão da tarefa (legacy)
  Future<void> setConcluidaLegacy(String tarefaId, bool concluida,
      {String? observacoes}) async {
    final tarefa = await findById(tarefaId);
    if (tarefa == null) return;

    final tarefaAtualizada = concluida
        ? tarefa.marcarConcluida(observacoes: observacoes)
        : tarefa.marcarPendente();
    tarefaAtualizada.markAsModified();
    await updateLegacy(tarefaId, tarefaAtualizada);
  }

  // Implementações da interface ITarefaRepository

  @override
  Future<String> criar(TarefaModel tarefa) async {
    return await create(tarefa);
  }

  @override
  Future<void> atualizar(TarefaModel tarefa) async {
    return await update(tarefa.id, tarefa);
  }

  @override
  Future<void> remover(String id) async {
    return await delete(id);
  }

  @override
  Stream<List<TarefaModel>> watchByTipoCuidado(String tipoCuidado) {
    return dataStream.map((tarefas) => 
        tarefas.where((tarefa) => tarefa.tipoCuidado == tipoCuidado).toList());
  }

  /// Remover todas as tarefas de uma planta com error handling robusto
  @override
  Future<void> removerPorPlanta(String plantaId) async {
    final tarefasDaPlanta = await executeCrudOperation<List<TarefaModel>>(
      operation: () => findByPlanta(plantaId),
      operationType: 'findByPlantaForDeletion',
      entityId: plantaId,
      entityType: 'Tarefa',
    );

    if (tarefasDaPlanta.isEmpty) return;

    await executeBatchOperation<void, TarefaModel>(
      items: tarefasDaPlanta,
      itemOperation: (tarefa) async {
        // Operação individual com retry automático
        return await executeWithErrorHandling<void>(
          operation: () => syncService.delete(tarefa.id),
          operationName: 'deleteSingleTarefa',
          enableRetry: true,
          context: {
            'tarefa_id': tarefa.id,
            'planta_id': tarefa.plantaId,
            'tipo_cuidado': tarefa.tipoCuidado,
            'parent_operation': 'removerPorPlanta',
          },
        );
      },
      operationType: 'removerPorPlanta',
      chunkSize: 25,
      delayBetweenChunks: const Duration(milliseconds: 30),
      continueOnError: true, // Continuar tentando mesmo se algumas falhacem
      additionalContext: {
        'planta_id': plantaId,
        'total_tarefas_to_delete': tarefasDaPlanta.length,
        'tipos_cuidado':
            tarefasDaPlanta.map((t) => t.tipoCuidado).toSet().toList(),
      },
    ).then((_) {
      // Invalidar cache após operação bem sucedida
      invalidateCache();
      QueryOptimizer.instance
          .invalidateRelatedCaches('tarefa_deleted', entityId: plantaId);
    });
  }

  /// Obter estatísticas das tarefas (OTIMIZADO - resolve N+1)
  /// DEPRECATED: Use StatisticsService.getTarefaStatistics() para lógica de negócio
  /// Para estatísticas avançadas, use TarefaStatisticsService
  @Deprecated(
      'Use StatisticsService.getTarefaStatistics() - será removido na v2.0')
  Future<Map<String, int>> getEstatisticas() async {
    // Implementação otimizada mantida por compatibilidade
    // Recomenda-se usar StatisticsService.getTarefaStatistics()
    final stats = await QueryOptimizer.instance.calcularEstatisticas(
      () => PlantaRepository.instance.findAll(),
      () => findAll(),
    );
    return stats.toTarefaMap();
  }

  // Método getDebugInfo() herdado do BaseRepository

  /// Query builder para consultas complexas (NOVO - FilterService)
  /// Exemplo: repository.query().paraHoje().forPlanta('123').findAll()
  Future<TarefaQueryBuilder> query() async {
    final tarefas = await syncService.findAll();
    return TarefaFilterService.instance.query(tarefas);
  }

  /// Buscar tarefas urgentes (hoje + atrasadas) - NOVO
  Future<List<TarefaModel>> findUrgentes() async {
    final tarefas = await syncService.findAll();
    return TarefaFilterService.instance.findUrgentes(tarefas);
  }

  /// Buscar tarefas urgentes por planta - NOVO
  Future<List<TarefaModel>> findUrgentesForPlanta(String plantaId) async {
    final tarefas = await syncService.findAll();
    return TarefaFilterService.instance
        .findUrgentesForPlanta(tarefas, plantaId);
  }

  /// Processar critérios de data de forma otimizada (uma única passada) - NOVO
  Future<TarefaDateCriteriaResult> processDateCriteria() async {
    final tarefas = await syncService.findAll();
    return TarefaFilterService.instance.processDateCriteria(tarefas);
  }

  /// Invalidar cache específico do FilterService
  @override
  void invalidateFilterCache([String? pattern]) {
    TarefaFilterService.instance.invalidateCache(pattern);
    invalidateCache(); // Também invalida cache local
  }

  /// Obter estatísticas do FilterService
  Map<String, dynamic> getFilterStats() {
    return TarefaFilterService.instance.getCacheStats();
  }

  /// Limpar recursos (incluindo streams e cache)
  @override
  Future<void> dispose() async {
    // Chamar dispose do BaseRepository
    await super.dispose();
  }
}
