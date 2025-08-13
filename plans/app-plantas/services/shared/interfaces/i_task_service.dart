// Project imports:
import '../../../database/tarefa_model.dart';

/// Interface para Task Service que define contratos para operações de tarefas
///
/// Esta interface permite dependency injection e testes isolados, seguindo
/// o princípio de inversão de dependência (Dependency Inversion Principle)
abstract class ITaskService {
  /// Buscar todas as tarefas (deve ser otimizado com cache)
  Future<List<TarefaModel>> findAll();

  /// Cria tarefas iniciais para uma nova planta
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
  });

  /// Completa uma tarefa e agenda a próxima
  Future<void> completeTask(String tarefaId, int intervaloDias,
      {String? observacoes});

  /// Completa uma tarefa com data específica e agenda a próxima
  Future<void> completeTaskWithDate(
      String tarefaId, int intervaloDias, DateTime dataConclusao,
      {String? observacoes});

  /// Obtém todas as tarefas para hoje
  Future<List<TarefaModel>> getTodayTasks();

  /// Obtém todas as tarefas futuras
  Future<List<TarefaModel>> getUpcomingTasks();

  /// Obtém tarefas atrasadas
  Future<List<TarefaModel>> getOverdueTasks();

  /// Obtém tarefas de uma planta específica
  Future<List<TarefaModel>> getPlantTasks(String plantaId);

  /// Obtém tarefas pendentes de uma planta específica
  Future<List<TarefaModel>> getPendingPlantTasks(String plantaId);

  /// Obtém todas as tarefas pendentes
  Future<List<TarefaModel>> getAllPendingTasks();

  /// Obtém todas as tarefas concluídas
  Future<List<TarefaModel>> getCompletedTasks();

  /// Obtém tarefas concluídas do dia
  Future<List<TarefaModel>> getTodayCompletedTasks();

  /// Obtém tarefas por período
  Future<List<TarefaModel>> getTasksByPeriod(DateTime inicio, DateTime fim);

  /// Obtém tarefas por tipo de cuidado
  Future<List<TarefaModel>> getTasksByType(String tipoCuidado);

  /// Remove todas as tarefas de uma planta
  Future<void> removeAllPlantTasks(String plantaId);

  /// Remove todas as tarefas do sistema
  Future<void> clearAllTasks();

  /// Reagenda uma tarefa para outra data
  Future<void> rescheduleTask(String tarefaId, DateTime novaData);

  /// Cancela uma tarefa (marca como concluída sem criar próxima)
  Future<void> cancelTask(String tarefaId, {String? observacoes});

  /// Reativa uma tarefa (marca como pendente)
  Future<void> reactivateTask(String tarefaId);

  /// Obtém estatísticas das tarefas
  Future<Map<String, int>> getTaskStatistics();

  /// Streams para atualizações em tempo real
  Stream<List<TarefaModel>> get todayTasksStream;
  Stream<List<TarefaModel>> get upcomingTasksStream;
  Stream<List<TarefaModel>> get overdueTasksStream;
  Stream<List<TarefaModel>> get pendingTasksStream;
  Stream<List<TarefaModel>> get completedTasksStream;

  /// Stream de tarefas por planta
  Stream<List<TarefaModel>> watchPlantTasks(String plantaId);

  /// Obtém a configuração de intervalo de uma planta
  Future<Map<String, int>> getPlantIntervals(String plantaId);

  /// Força sincronização
  Future<void> forceSync();

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo();

  /// Limpar recursos
  void dispose();

  /// Inicializar o service
  Future<void> initialize();

  /// Métodos para Event-Driven Architecture (Issue #16)
  /// Estes métodos são usados pelos event handlers para comunicação desacoplada

  /// Cria tarefa específica para uma planta e tipo de cuidado
  Future<void> createTaskForPlantAndCareType({
    required String plantaId,
    required String tipoCuidado,
    required DateTime dataExecucao,
  });

  /// Remove tarefas futuras para uma planta e tipo de cuidado
  Future<void> removeFutureTasksForPlantAndCareType({
    required String plantaId,
    required String tipoCuidado,
  });

  /// Calcula próxima data de tarefa baseada na configuração
  Future<DateTime?> calculateNextTaskDate({
    required String plantaId,
    required String tipoCuidado,
    required dynamic
        config, // PlantaConfigModel - dynamic para evitar dependency
  });
}
