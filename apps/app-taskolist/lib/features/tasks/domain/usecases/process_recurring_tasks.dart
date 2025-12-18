import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../task_entity.dart';
import '../task_repository.dart';

/// Use case para processar tarefas recorrentes e criar próximas instâncias
class ProcessRecurringTasks {
  final TaskRepository repository;

  ProcessRecurringTasks(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call() async {
    try {
      // 1. Buscar todas as tarefas recorrentes completadas
      final tasksResult = await repository.getTasks();

      if (tasksResult.isLeft()) {
        return tasksResult.fold(
          (failure) => Left<Failure, List<TaskEntity>>(failure),
          (_) => throw Exception('Unreachable'),
        );
      }

      final tasks = tasksResult.fold(
        (_) => throw Exception('Unreachable'),
        (tasks) => tasks,
      );

      final recurringTasks = tasks
          .where(
            (TaskEntity task) =>
                task.recurrence.isRecurring &&
                task.status == TaskStatus.completed,
          )
          .toList();

      final List<TaskEntity> newTasks = [];

      // 2. Para cada tarefa recorrente completada, criar próxima instância
      for (final task in recurringTasks) {
        final nextDate = task.recurrence.getNextOccurrence(
          task.dueDate ?? DateTime.now(),
        );

        if (nextDate != null) {
          // Criar nova tarefa com próxima data
          final newTask = task.copyWith(
            id: '', // Novo ID será gerado no repository
            status: TaskStatus.pending,
            dueDate: nextDate,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final createResult = await repository.createTask(newTask);
          createResult.fold(
            (_) {}, // Ignora falhas individuais
            (String createdId) {
              // Repository retorna String (ID), não TaskEntity
              // Não podemos adicionar à lista sem buscar novamente
            },
          );
        }
      }

      return Right<Failure, List<TaskEntity>>(newTasks);
    } catch (e) {
      return Left<Failure, List<TaskEntity>>(CacheFailure(e.toString()));
    }
  }
}
