import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'task_repository.dart';

class DeleteTask extends UseCaseWithParams<void, DeleteTaskParams> {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(DeleteTaskParams params) async {
    return _repository.deleteTask(params.taskId);
  }
}

class DeleteTaskParams {
  const DeleteTaskParams({
    required this.taskId,
  });

  final String taskId;
}
