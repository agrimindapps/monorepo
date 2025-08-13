// Project imports:
import '../../../constants/care_type_const.dart';
import '../../../database/tarefa_model.dart';
import '../../../pages/nova_tarefas_page/services/care_type_service.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/tarefa_repository.dart';
import '../../shared/interfaces/i_task_service.dart';

/// Service simplificado para gerenciamento de tarefas
///
/// Implementa ITaskService para permitir dependency injection e testes isolados
class SimpleTaskService implements ITaskService {
  static SimpleTaskService? _instance;
  static SimpleTaskService get instance => _instance ??= SimpleTaskService._();
  SimpleTaskService._();

  late final TarefaRepository _tarefaRepository;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _tarefaRepository = TarefaRepository.instance;
    await _tarefaRepository.initialize();
    _isInitialized = true;
  }

  /// Buscar todas as tarefas (delegado para o repository otimizado)
  @override
  Future<List<TarefaModel>> findAll() => _tarefaRepository.findAll();

  /// Cria tarefas iniciais para uma nova planta
  @override
  Future<void> createInitialTasksForPlant({
    required String plantaId,
    required bool aguaAtiva,
    required int intervaloRegaDias,
    required DateTime? primeiraRega,
    required bool aduboAtivo,
    required int intervaloAdubacaoDias,
    required DateTime? primeiraAdubacao,
    required bool banhoSolAtivo,
    required int intervaloBanhoSolDias,
    required DateTime? primeiroBanhoSol,
    required bool inspecaoPragasAtiva,
    required int intervaloInspecaoPragasDias,
    required DateTime? primeiraInspecaoPragas,
    required bool podaAtiva,
    required int intervaloPodaDias,
    required DateTime? primeiraPoda,
    required bool replantarAtivo,
    required int intervaloReplantarDias,
    required DateTime? primeiroReplantar,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tarefas = <TarefaModel>[];

    // Criar tarefa de rega se ativa
    if (aguaAtiva && primeiraRega != null) {
      tarefas.add(TarefaModel(
        id: '',
        createdAt: now,
        updatedAt: now,
        plantaId: plantaId,
        tipoCuidado: CareType.agua.value,
        dataExecucao: primeiraRega,
        concluida: false,
      ));
    }

    // Criar tarefa de adubação se ativa
    if (aduboAtivo && primeiraAdubacao != null) {
      tarefas.add(TarefaModel(
        id: '',
        createdAt: now,
        updatedAt: now,
        plantaId: plantaId,
        tipoCuidado: CareType.adubo.value,
        dataExecucao: primeiraAdubacao,
        concluida: false,
      ));
    }

    // Criar tarefa de banho de sol se ativa
    if (banhoSolAtivo && primeiroBanhoSol != null) {
      tarefas.add(TarefaModel(
        id: '',
        createdAt: now,
        updatedAt: now,
        plantaId: plantaId,
        tipoCuidado: CareType.banhoSol.value,
        dataExecucao: primeiroBanhoSol,
        concluida: false,
      ));
    }

    // Criar tarefa de inspeção de pragas se ativa
    if (inspecaoPragasAtiva && primeiraInspecaoPragas != null) {
      tarefas.add(TarefaModel(
        id: '',
        createdAt: now,
        updatedAt: now,
        plantaId: plantaId,
        tipoCuidado: CareType.inspecaoPragas.value,
        dataExecucao: primeiraInspecaoPragas,
        concluida: false,
      ));
    }

    // Criar tarefa de poda se ativa
    if (podaAtiva && primeiraPoda != null) {
      tarefas.add(TarefaModel(
        id: '',
        createdAt: now,
        updatedAt: now,
        plantaId: plantaId,
        tipoCuidado: CareType.poda.value,
        dataExecucao: primeiraPoda,
        concluida: false,
      ));
    }

    // Criar tarefa de replantio se ativa
    if (replantarAtivo && primeiroReplantar != null) {
      tarefas.add(TarefaModel(
        id: '',
        createdAt: now,
        updatedAt: now,
        plantaId: plantaId,
        tipoCuidado: CareType.replantio.value,
        dataExecucao: primeiroReplantar,
        concluida: false,
      ));
    }

    // Salvar todas as tarefas em lote
    if (tarefas.isNotEmpty) {
      await _tarefaRepository.createBatch(tarefas);
    }
  }

  /// Completa uma tarefa e agenda a próxima
  @override
  Future<void> completeTask(String tarefaId, int intervaloDias,
      {String? observacoes}) async {
    final tarefa = await _tarefaRepository.findById(tarefaId);
    if (tarefa == null) {
      throw Exception('Tarefa não encontrada');
    }

    // Marcar tarefa atual como concluída
    await _tarefaRepository.marcarConcluida(tarefaId, observacoes: observacoes);

    // Criar próxima tarefa
    await _createNextTask(tarefa, intervaloDias);
  }

  /// Completa uma tarefa com data específica e agenda a próxima
  @override
  Future<void> completeTaskWithDate(
      String tarefaId, int intervaloDias, DateTime dataConclusao,
      {String? observacoes}) async {
    final tarefa = await _tarefaRepository.findById(tarefaId);
    if (tarefa == null) {
      throw Exception('Tarefa não encontrada');
    }

    // Marcar tarefa atual como concluída
    await _tarefaRepository.marcarConcluida(tarefaId, observacoes: observacoes);

    // Criar próxima tarefa baseada na data de conclusão selecionada
    await _createNextTaskFromDate(tarefa, intervaloDias, dataConclusao);
  }

  /// Cria a próxima tarefa baseada na tarefa atual e intervalo
  Future<void> _createNextTask(
      TarefaModel tarefaAtual, int intervaloDias) async {
    final proximaDataExecucao =
        DateTime.now().add(Duration(days: intervaloDias));
    final now = DateTime.now().millisecondsSinceEpoch;

    final proximaTarefa = TarefaModel(
      id: '',
      createdAt: now,
      updatedAt: now,
      plantaId: tarefaAtual.plantaId,
      tipoCuidado: tarefaAtual.tipoCuidado,
      dataExecucao: proximaDataExecucao,
      concluida: false,
    );

    await _tarefaRepository.create(proximaTarefa);
  }

  /// Cria a próxima tarefa baseada na data de conclusão específica
  Future<void> _createNextTaskFromDate(TarefaModel tarefaAtual,
      int intervaloDias, DateTime dataConclusao) async {
    final proximaDataExecucao =
        dataConclusao.add(Duration(days: intervaloDias));
    final now = DateTime.now().millisecondsSinceEpoch;

    final proximaTarefa = TarefaModel(
      id: '',
      createdAt: now,
      updatedAt: now,
      plantaId: tarefaAtual.plantaId,
      tipoCuidado: tarefaAtual.tipoCuidado,
      dataExecucao: proximaDataExecucao,
      concluida: false,
    );

    await _tarefaRepository.create(proximaTarefa);
  }

  /// Obtém todas as tarefas para hoje
  @override
  Future<List<TarefaModel>> getTodayTasks() async {
    return await _tarefaRepository.findParaHoje();
  }

  /// Obtém todas as tarefas futuras
  @override
  Future<List<TarefaModel>> getUpcomingTasks() async {
    return await _tarefaRepository.findFuturas();
  }

  /// Obtém tarefas atrasadas
  @override
  Future<List<TarefaModel>> getOverdueTasks() async {
    return await _tarefaRepository.findAtrasadas();
  }

  /// Obtém tarefas de uma planta específica
  @override
  Future<List<TarefaModel>> getPlantTasks(String plantaId) async {
    return await _tarefaRepository.findByPlanta(plantaId);
  }

  /// Obtém tarefas pendentes de uma planta específica
  @override
  Future<List<TarefaModel>> getPendingPlantTasks(String plantaId) async {
    return await _tarefaRepository.findPendentesByPlanta(plantaId);
  }

  /// Obtém todas as tarefas pendentes
  @override
  Future<List<TarefaModel>> getAllPendingTasks() async {
    return await _tarefaRepository.findPendentes();
  }

  /// Obtém todas as tarefas concluídas
  @override
  Future<List<TarefaModel>> getCompletedTasks() async {
    return await _tarefaRepository.findConcluidas();
  }

  /// Obtém tarefas concluídas do dia
  @override
  Future<List<TarefaModel>> getTodayCompletedTasks() async {
    return await _tarefaRepository.findConcluidasHoje();
  }

  /// Obtém tarefas por período
  @override
  Future<List<TarefaModel>> getTasksByPeriod(
      DateTime inicio, DateTime fim) async {
    return await _tarefaRepository.findByPeriodo(inicio, fim);
  }

  /// Obtém tarefas por tipo de cuidado
  @override
  Future<List<TarefaModel>> getTasksByType(String tipoCuidado) async {
    return await _tarefaRepository.findByTipoCuidado(tipoCuidado);
  }

  /// Remove todas as tarefas de uma planta
  @override
  Future<void> removeAllPlantTasks(String plantaId) async {
    await _tarefaRepository.removerPorPlanta(plantaId);
  }

  /// Remove todas as tarefas do sistema
  @override
  Future<void> clearAllTasks() async {
    await _tarefaRepository.clear();
  }

  /// Reagenda uma tarefa para outra data
  @override
  Future<void> rescheduleTask(String tarefaId, DateTime novaData) async {
    final tarefa = await _tarefaRepository.findById(tarefaId);
    if (tarefa == null) {
      throw Exception('Tarefa não encontrada');
    }

    final tarefaAtualizada = tarefa.copyWith(dataExecucao: novaData);
    tarefaAtualizada.markAsModified();
    await _tarefaRepository.update(tarefaId, tarefaAtualizada);
  }

  /// Cancela uma tarefa (marca como concluída sem criar próxima)
  @override
  Future<void> cancelTask(String tarefaId, {String? observacoes}) async {
    await _tarefaRepository.marcarConcluida(tarefaId, observacoes: observacoes);
  }

  /// Reativa uma tarefa (marca como pendente)
  @override
  Future<void> reactivateTask(String tarefaId) async {
    await _tarefaRepository.marcarPendente(tarefaId);
  }

  /// Obtém estatísticas das tarefas
  @override
  Future<Map<String, int>> getTaskStatistics() async {
    return await _tarefaRepository.getEstatisticas();
  }

  /// Streams para atualizações em tempo real
  @override
  Stream<List<TarefaModel>> get todayTasksStream =>
      _tarefaRepository.watchParaHoje();
  @override
  Stream<List<TarefaModel>> get upcomingTasksStream =>
      _tarefaRepository.watchFuturas();
  @override
  Stream<List<TarefaModel>> get overdueTasksStream =>
      _tarefaRepository.watchAtrasadas();
  @override
  Stream<List<TarefaModel>> get pendingTasksStream =>
      _tarefaRepository.watchPendentes();
  @override
  Stream<List<TarefaModel>> get completedTasksStream =>
      _tarefaRepository.watchConcluidas();

  /// Stream de tarefas por planta
  @override
  Stream<List<TarefaModel>> watchPlantTasks(String plantaId) {
    return _tarefaRepository.watchByPlanta(plantaId);
  }

  /// Obtém a configuração de intervalo de uma planta usando PlantaConfigRepository
  @override
  Future<Map<String, int>> getPlantIntervals(String plantaId) async {
    final configRepo = PlantaConfigRepository.instance;
    await configRepo.initialize();

    final config = await configRepo.findByPlantaId(plantaId);
    if (config != null) {
      return {
        CareType.agua.value: config.intervaloRegaDias,
        CareType.adubo.value: config.intervaloAdubacaoDias,
        CareType.banhoSol.value: config.intervaloBanhoSolDias,
        CareType.inspecaoPragas.value: config.intervaloInspecaoPragasDias,
        CareType.poda.value: config.intervaloPodaDias,
        CareType.replantio.value: config.intervaloReplantarDias,
      };
    }

    // Fallback to CareTypeService defaults only if no config exists
    return {
      CareType.agua.value:
          CareTypeService.getDefaultInterval(CareType.agua.value),
      CareType.adubo.value:
          CareTypeService.getDefaultInterval(CareType.adubo.value),
      CareType.banhoSol.value:
          CareTypeService.getDefaultInterval(CareType.banhoSol.value),
      CareType.inspecaoPragas.value:
          CareTypeService.getDefaultInterval(CareType.inspecaoPragas.value),
      CareType.poda.value:
          CareTypeService.getDefaultInterval(CareType.poda.value),
      CareType.replantio.value:
          CareTypeService.getDefaultInterval(CareType.replantio.value),
    };
  }

  /// Força sincronização
  @override
  Future<void> forceSync() => _tarefaRepository.forceSync();

  /// Obtém informações de debug
  @override
  Map<String, dynamic> getDebugInfo() => _tarefaRepository.getDebugInfo();

  /// Limpar recursos
  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      await _tarefaRepository.dispose();
      _isInitialized = false;
    }
  }

  // ============================================================================
  // MÉTODOS PARA EVENT-DRIVEN ARCHITECTURE (Issue #16)
  // ============================================================================

  /// Cria tarefa específica para uma planta e tipo de cuidado
  @override
  Future<void> createTaskForPlantAndCareType({
    required String plantaId,
    required String tipoCuidado,
    required DateTime dataExecucao,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final tarefa = TarefaModel(
      id: '',
      createdAt: now,
      updatedAt: now,
      plantaId: plantaId,
      tipoCuidado: tipoCuidado,
      dataExecucao: dataExecucao,
      concluida: false,
    );

    await _tarefaRepository.create(tarefa);
  }

  /// Remove tarefas futuras para uma planta e tipo de cuidado
  @override
  Future<void> removeFutureTasksForPlantAndCareType({
    required String plantaId,
    required String tipoCuidado,
  }) async {
    // Buscar todas tarefas da planta por tipo de cuidado
    final tarefas = await _tarefaRepository.findByPlanta(plantaId);
    final now = DateTime.now();

    // Filtrar tarefas futuras e pendentes do tipo específico
    final tarefasFuturas = tarefas.where((tarefa) {
      return tarefa.tipoCuidado == tipoCuidado &&
          !tarefa.concluida &&
          tarefa.dataExecucao.isAfter(now);
    }).toList();

    // Remover tarefas futuras
    for (final tarefa in tarefasFuturas) {
      await _tarefaRepository.delete(tarefa.id);
    }
  }

  /// Calcula próxima data de tarefa baseada na configuração
  @override
  Future<DateTime?> calculateNextTaskDate({
    required String plantaId,
    required String tipoCuidado,
    required dynamic config, // PlantaConfigModel
  }) async {
    if (config == null) return null;

    // Verificar se o tipo de cuidado está ativo na configuração
    final isActive = _isCareTypeActive(tipoCuidado, config);
    if (!isActive) return null;

    // Obter intervalo do tipo de cuidado
    final interval = _getCareTypeInterval(tipoCuidado, config);
    if (interval <= 0) return null;

    // Calcular próxima data baseada no intervalo
    return DateTime.now().add(Duration(days: interval));
  }

  /// Verifica se um tipo de cuidado está ativo na configuração
  bool _isCareTypeActive(String tipoCuidado, dynamic config) {
    switch (tipoCuidado) {
      case 'agua': // CareType.agua.value
        return config.aguaAtiva ?? false;
      case 'adubo': // CareType.adubo.value
        return config.aduboAtivo ?? false;
      case 'banho_sol': // CareType.banhoSol.value
        return config.banhoSolAtivo ?? false;
      case 'inspecao_pragas': // CareType.inspecaoPragas.value
        return config.inspecaoPragasAtiva ?? false;
      case 'poda': // CareType.poda.value
        return config.podaAtiva ?? false;
      case 'replantio': // CareType.replantio.value
        return config.replantarAtivo ?? false;
      default:
        return false;
    }
  }

  /// Obtém intervalo de um tipo de cuidado da configuração
  int _getCareTypeInterval(String tipoCuidado, dynamic config) {
    switch (tipoCuidado) {
      case 'agua': // CareType.agua.value
        return config.intervaloRegaDias ?? 7;
      case 'adubo': // CareType.adubo.value
        return config.intervaloAdubacaoDias ?? 30;
      case 'banho_sol': // CareType.banhoSol.value
        return config.intervaloBanhoSolDias ?? 1;
      case 'inspecao_pragas': // CareType.inspecaoPragas.value
        return config.intervaloInspecaoPragasDias ?? 15;
      case 'poda': // CareType.poda.value
        return config.intervaloPodaDias ?? 90;
      case 'replantio': // CareType.replantio.value
        return config.intervaloReplantarDias ?? 365;
      default:
        return 7; // Fallback padrão
    }
  }
}
