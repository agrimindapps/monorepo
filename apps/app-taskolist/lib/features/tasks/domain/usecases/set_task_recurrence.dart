import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../recurrence_entity.dart';
import '../task_entity.dart';
import '../task_repository.dart';

/// Use case para definir regra de recorrência em uma tarefa
class SetTaskRecurrence {
  final TaskRepository repository;

  SetTaskRecurrence(this.repository);

  Future<Either<Failure, TaskEntity>> call({
    required String taskId,
    required RecurrencePattern recurrence,
  }) async {
    try {
      // Buscar tarefa atual
      final taskResult = await repository.getTask(taskId);

      if (taskResult.isLeft()) {
        return taskResult.fold(
          (failure) => Left<Failure, TaskEntity>(failure),
          (_) => throw Exception('Unreachable'),
        );
      }

      final task = taskResult.fold(
        (_) => throw Exception('Unreachable'),
        (task) => task,
      );

      // Atualizar tarefa com nova recorrência
      final updatedTask = task.copyWith(recurrence: recurrence);

      final result = await repository.updateTask(updatedTask);
      return result.fold(
        (failure) => Left<Failure, TaskEntity>(failure),
        (_) => Right<Failure, TaskEntity>(updatedTask),
      );
    } catch (e) {
      return Left<Failure, TaskEntity>(CacheFailure(e.toString()));
    }
  }
}
