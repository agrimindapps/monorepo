import 'package:core/core.dart';

import '../../../core/errors/failures.dart' as local_failures;
import '../../../core/utils/typedef.dart';
import '../domain/my_day_repository.dart';
import '../domain/my_day_task_entity.dart';
import '../domain/task_entity.dart';
import 'my_day_local_datasource.dart';
import 'my_day_task_extensions.dart';
import 'task_local_datasource.dart';

class MyDayRepositoryImpl implements MyDayRepository {
  const MyDayRepositoryImpl(
    this._myDayLocalDataSource,
    this._taskLocalDataSource,
  );

  final MyDayLocalDataSource _myDayLocalDataSource;
  final TaskLocalDataSource _taskLocalDataSource;

  @override
  ResultFuture<void> addTaskToMyDay({
    required String taskId,
    required String userId,
  }) async {
    try {
      await _myDayLocalDataSource.addTaskToMyDay(
        taskId: taskId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure('Failed to add task to My Day: $e'),
      );
    }
  }

  @override
  ResultFuture<void> removeTaskFromMyDay({required String taskId}) async {
    try {
      await _myDayLocalDataSource.removeTaskFromMyDay(taskId: taskId);
      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure('Failed to remove task from My Day: $e'),
      );
    }
  }

  @override
  ResultFuture<List<MyDayTaskEntity>> getMyDayTasks({
    required String userId,
  }) async {
    try {
      final myDayTasks = await _myDayLocalDataSource.getMyDayTasks(
        userId: userId,
      );
      final entities = myDayTasks.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(
        local_failures.CacheFailure('Failed to get My Day tasks: $e'),
      );
    }
  }

  @override
  Stream<List<MyDayTaskEntity>> watchMyDayTasks({required String userId}) {
    return _myDayLocalDataSource.watchMyDayTasks(userId: userId).map(
          (myDayTasks) => myDayTasks.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  ResultFuture<void> clearMyDay({required String userId}) async {
    try {
      await _myDayLocalDataSource.clearMyDay(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(
        local_failures.CacheFailure('Failed to clear My Day: $e'),
      );
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getMyDaySuggestions({
    required String userId,
  }) async {
    try {
      // Buscar tasks pendentes com due date de hoje ou atrasadas
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final allTasks = await _taskLocalDataSource.getTasks(
        userId: userId,
        status: TaskStatus.pending,
      );

      // Filtrar:
      // 1. Tasks com due date de hoje
      // 2. Tasks atrasadas
      // 3. Tasks starred
      // 4. Excluir tasks já no Meu Dia
      final suggestions = <TaskEntity>[];

      for (final taskModel in allTasks) {
        final isInMyDay = await _myDayLocalDataSource.isInMyDay(
          taskId: taskModel.id,
        );

        if (isInMyDay) continue; // Pular se já está no Meu Dia

        // TaskModel extends TaskEntity, então podemos usar diretamente
        final taskEntity = taskModel as TaskEntity;
        final dueDate = taskEntity.dueDate;

        // Sugerir se:
        // - Tem due date hoje
        // - Está atrasada
        // - É starred
        if (dueDate != null) {
          final dueDateOnly = DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day,
          );
          if (dueDateOnly.isBefore(today) ||
              dueDateOnly.isAtSameMomentAs(today)) {
            suggestions.add(taskEntity);
          }
        } else if (taskEntity.isStarred) {
          suggestions.add(taskEntity);
        }
      }

      // Ordenar por prioridade e due date
      suggestions.sort((a, b) {
        // Primeiro por prioridade
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;

        // Depois por due date (atrasadas primeiro)
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

      // Limitar a 10 sugestões
      return Right(suggestions.take(10).toList());
    } catch (e) {
      return Left(
        local_failures.CacheFailure('Failed to get My Day suggestions: $e'),
      );
    }
  }
}
