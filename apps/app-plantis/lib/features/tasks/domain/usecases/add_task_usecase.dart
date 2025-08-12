import 'package:dartz/dartz.dart';
import 'package:core/src/shared/utils/failure.dart';
import 'package:core/src/domain/usecases/base_usecase.dart';
import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

class AddTaskUseCase implements UseCase<task_entity.Task, AddTaskParams> {
  final TasksRepository repository;

  AddTaskUseCase(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(AddTaskParams params) async {
    return await repository.addTask(params.task);
  }
}

class AddTaskParams {
  final task_entity.Task task;

  AddTaskParams({required this.task});
}