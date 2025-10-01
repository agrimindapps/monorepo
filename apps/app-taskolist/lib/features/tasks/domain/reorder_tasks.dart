import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'task_repository.dart';

@lazySingleton
class ReorderTasks extends UseCaseWithParams<void, ReorderTasksParams> {
  const ReorderTasks(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(ReorderTasksParams params) async {
    return _repository.reorderTasks(params.taskIds);
  }
}

@lazySingleton
class ReorderTasksParams extends Equatable {
  const ReorderTasksParams({required this.taskIds});

  final List<String> taskIds;

  @override
  List<Object?> get props => [taskIds];
}