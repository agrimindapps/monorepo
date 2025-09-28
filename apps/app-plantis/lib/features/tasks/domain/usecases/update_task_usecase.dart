import 'package:core/core.dart';

import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

class UpdateTaskUseCase implements UseCase<task_entity.Task, UpdateTaskParams> {
  final TasksRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(
    UpdateTaskParams params,
  ) async {
    return await repository.updateTask(params.task);
  }
}

class UpdateTaskParams {
  final task_entity.Task task;

  UpdateTaskParams({required this.task});
}
