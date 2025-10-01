import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'task_entity.dart';
import 'task_repository.dart';

@lazySingleton
class UpdateTask extends UseCaseWithParams<void, UpdateTaskParams> {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(UpdateTaskParams params) async {
    return _repository.updateTask(params.task);
  }
}

@lazySingleton
class UpdateTaskParams extends Equatable {
  const UpdateTaskParams({required this.task});

  final TaskEntity task;

  @override
  List<Object?> get props => [task];
}