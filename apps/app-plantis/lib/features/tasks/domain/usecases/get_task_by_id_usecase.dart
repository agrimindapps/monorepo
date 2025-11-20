import 'package:core/core.dart';
import '../entities/task.dart' as task_entity;
import '../repositories/tasks_crud_repository.dart';

class GetTaskByIdUseCase implements UseCase<task_entity.Task, String> {
  final ITasksCrudRepository repository;

  GetTaskByIdUseCase(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(String taskId) async {
    return await repository.getTaskById(taskId);
  }
}
