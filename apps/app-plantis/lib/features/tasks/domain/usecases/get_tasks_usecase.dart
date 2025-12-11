import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

class GetTasksUseCase implements UseCase<List<task_entity.Task>, NoParams> {
  final TasksRepository repository;

  GetTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}

class GetTasksByPlantIdUseCase
    implements UseCase<List<task_entity.Task>, GetTasksByPlantIdParams> {
  final TasksRepository repository;

  GetTasksByPlantIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(
    GetTasksByPlantIdParams params,
  ) async {
    return await repository.getTasksByPlantId(params.plantId);
  }
}

class GetTasksByStatusUseCase
    implements UseCase<List<task_entity.Task>, GetTasksByStatusParams> {
  final TasksRepository repository;

  GetTasksByStatusUseCase(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(
    GetTasksByStatusParams params,
  ) async {
    return await repository.getTasksByStatus(params.status);
  }
}

class GetOverdueTasksUseCase
    implements UseCase<List<task_entity.Task>, NoParams> {
  final TasksRepository repository;

  GetOverdueTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(NoParams params) async {
    return await repository.getOverdueTasks();
  }
}

class GetTodayTasksUseCase
    implements UseCase<List<task_entity.Task>, NoParams> {
  final TasksRepository repository;

  GetTodayTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(NoParams params) async {
    return await repository.getTodayTasks();
  }
}

class GetUpcomingTasksUseCase
    implements UseCase<List<task_entity.Task>, NoParams> {
  final TasksRepository repository;

  GetUpcomingTasksUseCase(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(NoParams params) async {
    return await repository.getUpcomingTasks();
  }
}

class GetTasksByPlantIdParams {
  final String plantId;

  GetTasksByPlantIdParams({required this.plantId});
}

class GetTasksByStatusParams {
  final task_entity.TaskStatus status;

  GetTasksByStatusParams({required this.status});
}
