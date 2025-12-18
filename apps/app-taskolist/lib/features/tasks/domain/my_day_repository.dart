import '../../../core/utils/typedef.dart';
import 'my_day_task_entity.dart';
import 'task_entity.dart';

/// Repository para gerenciar tarefas do "Meu Dia"
abstract class MyDayRepository {
  /// Adiciona tarefa ao Meu Dia
  ResultFuture<void> addTaskToMyDay({
    required String taskId,
    required String userId,
  });

  /// Remove tarefa do Meu Dia
  ResultFuture<void> removeTaskFromMyDay({required String taskId});

  /// Busca tarefas do Meu Dia
  ResultFuture<List<MyDayTaskEntity>> getMyDayTasks({
    required String userId,
  });

  /// Observa mudanças nas tarefas do Meu Dia
  Stream<List<MyDayTaskEntity>> watchMyDayTasks({required String userId});

  /// Limpa todas as tarefas do Meu Dia
  ResultFuture<void> clearMyDay({required String userId});

  /// Busca sugestões para o Meu Dia
  ResultFuture<List<TaskEntity>> getMyDaySuggestions({
    required String userId,
  });
}
