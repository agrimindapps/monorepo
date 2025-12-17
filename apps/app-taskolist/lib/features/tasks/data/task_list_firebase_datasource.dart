import '../domain/task_list_entity.dart';

abstract class TaskListFirebaseDatasource {
  /// Cria uma nova lista no Firestore
  Future<String> createTaskList(TaskListEntity taskList);

  /// Busca uma lista por ID
  Future<TaskListEntity> getTaskList(String id);

  /// Busca todas as listas do usuário
  Future<List<TaskListEntity>> getTaskLists({
    String? userId,
    bool? isArchived,
  });

  /// Atualiza uma lista existente
  Future<void> updateTaskList(TaskListEntity taskList);

  /// Deleta uma lista
  Future<void> deleteTaskList(String id);

  /// Compartilha lista com outros usuários
  Future<void> shareTaskList(String id, List<String> memberIds);

  /// Arquiva uma lista
  Future<void> archiveTaskList(String id);

  /// Stream de listas do usuário
  Stream<List<TaskListEntity>> watchTaskLists({
    String? userId,
    bool? isArchived,
  });
}
