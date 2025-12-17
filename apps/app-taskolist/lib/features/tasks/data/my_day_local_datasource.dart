import 'my_day_task_model.dart';

abstract class MyDayLocalDataSource {
  /// Adiciona uma task ao Meu Dia
  Future<void> addTaskToMyDay({
    required String taskId,
    required String userId,
  });

  /// Remove uma task do Meu Dia
  Future<void> removeTaskFromMyDay({required String taskId});

  /// Obtém todas as tasks do Meu Dia de um usuário
  Future<List<MyDayTaskModel>> getMyDayTasks({required String userId});

  /// Observa as tasks do Meu Dia de um usuário em tempo real
  Stream<List<MyDayTaskModel>> watchMyDayTasks({required String userId});

  /// Limpa todas as tasks do Meu Dia de um usuário
  Future<void> clearMyDay({required String userId});

  /// Verifica se uma task está no Meu Dia
  Future<bool> isInMyDay({required String taskId});
}
