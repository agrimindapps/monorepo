import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'task_repository.dart';

@lazySingleton
class DeleteTask extends UseCaseWithParams<void, DeleteTaskParams> {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(DeleteTaskParams params) async {
    return _repository.deleteTask(params.taskId);
  }
}

@lazySingleton
class DeleteTaskParams {
  const DeleteTaskParams({
    required this.taskId,
  });

  final String taskId;
}