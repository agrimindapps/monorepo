import 'package:equatable/equatable.dart';

import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTask extends UseCaseWithParams<void, UpdateTaskParams> {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(UpdateTaskParams params) async {
    return _repository.updateTask(params.task);
  }
}

class UpdateTaskParams extends Equatable {
  const UpdateTaskParams({required this.task});

  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}