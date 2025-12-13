import '../domain/task_entity.dart';

/// Interface para operações Firebase de Tasks
abstract class TaskFirebaseDataSource {
  /// Cria uma nova task no Firebase
  Future<void> createTask(String userId, TaskEntity task);

  /// Atualiza uma task existente no Firebase
  Future<void> updateTask(String userId, TaskEntity task);

  /// Deleta uma task do Firebase
  Future<void> deleteTask(String userId, String taskId);

  /// Sincroniza múltiplas tasks em batch
  Future<void> batchSync(String userId, List<TaskEntity> tasks);

  /// Obtém uma task do Firebase
  Future<TaskEntity?> getTask(String userId, String taskId);

  /// Obtém todas as tasks do usuário
  Future<List<TaskEntity>> getTasks(String userId);
}
