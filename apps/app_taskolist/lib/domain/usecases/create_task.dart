import 'package:equatable/equatable.dart';

import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTask extends UseCaseWithParams<String, CreateTaskParams> {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<String> call(CreateTaskParams params) async {
    return _repository.createTask(params.task);
  }
}

class CreateTaskParams extends Equatable {
  const CreateTaskParams({required this.task});

  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}