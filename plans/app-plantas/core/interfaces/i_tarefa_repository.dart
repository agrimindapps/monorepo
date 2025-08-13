// Project imports:
import '../../database/tarefa_model.dart';

/// Interface para TarefaRepository
///
/// Define contrato para operações de dados de tarefas,
/// permitindo dependency injection e testabilidade
abstract class ITarefaRepository {
  /// Inicializar o repository
  Future<void> initialize();

  /// Buscar todas as tarefas
  Future<List<TarefaModel>> findAll();

  /// Buscar tarefa por ID
  Future<TarefaModel?> findById(String id);

  /// Buscar múltiplas tarefas por IDs
  Future<List<TarefaModel>> findByIds(List<String> ids);

  /// Buscar tarefas por planta
  Future<List<TarefaModel>> findByPlanta(String plantaId);

  /// Buscar tarefas por tipo de cuidado
  Future<List<TarefaModel>> findByTipoCuidado(String tipoCuidado);

  /// Buscar tarefas para hoje
  Future<List<TarefaModel>> findParaHoje();

  /// Buscar tarefas futuras
  Future<List<TarefaModel>> findFuturas();

  /// Buscar tarefas atrasadas
  Future<List<TarefaModel>> findAtrasadas();

  /// Buscar tarefas pendentes
  Future<List<TarefaModel>> findPendentes();

  /// Buscar tarefas concluídas
  Future<List<TarefaModel>> findConcluidas();

  /// Criar nova tarefa
  Future<String> criar(TarefaModel tarefa);

  /// Criar múltiplas tarefas em batch
  Future<List<String>> createBatch(List<TarefaModel> tarefas);

  /// Atualizar tarefa existente
  Future<void> atualizar(TarefaModel tarefa);

  /// Remover tarefa
  Future<void> remover(String id);

  /// Remover múltiplas tarefas por planta
  Future<void> removerPorPlanta(String plantaId);

  /// Marcar tarefa como concluída
  Future<void> marcarConcluida(String id,
      {DateTime? dataConclusao, String? observacoes});

  /// Marcar tarefa como pendente
  Future<void> marcarPendente(String id);

  /// Definir status de conclusão
  Future<void> setConcluida(String id, bool concluida,
      {DateTime? dataConclusao, String? observacoes});

  /// Stream de todas as tarefas
  Stream<List<TarefaModel>> get dataStream;

  /// Stream de tarefas para hoje
  Stream<List<TarefaModel>> watchParaHoje();

  /// Stream de tarefas futuras
  Stream<List<TarefaModel>> watchFuturas();

  /// Stream de tarefas atrasadas
  Stream<List<TarefaModel>> watchAtrasadas();

  /// Stream de tarefas pendentes
  Stream<List<TarefaModel>> watchPendentes();

  /// Stream de tarefas concluídas
  Stream<List<TarefaModel>> watchConcluidas();

  /// Stream de tarefas por planta
  Stream<List<TarefaModel>> watchByPlanta(String plantaId);

  /// Stream de tarefas por tipo de cuidado
  Stream<List<TarefaModel>> watchByTipoCuidado(String tipoCuidado);

  /// Dispose resources
  void dispose();
}
