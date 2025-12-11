import 'package:core/core.dart' hide Column;

import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

class CompleteTaskUseCase
    implements UseCase<task_entity.Task, CompleteTaskParams> {
  final TasksRepository repository;

  CompleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(
    CompleteTaskParams params,
  ) async {
    return await repository.completeTask(
      params.taskId,
      notes: params.notes,
      nextDueDate: params.nextDueDate,
    );
  }
}

class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  final TasksRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(params.taskId);
  }
}

class CompleteTaskParams {
  final String taskId;
  final String? notes;
  final DateTime? nextDueDate;

  CompleteTaskParams({required this.taskId, this.notes, this.nextDueDate});
}

class DeleteTaskParams {
  final String taskId;

  DeleteTaskParams({required this.taskId});
}
