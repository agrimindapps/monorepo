import 'package:equatable/equatable.dart';

import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../repositories/task_repository.dart';

class ReorderTasks extends UseCaseWithParams<void, ReorderTasksParams> {
  const ReorderTasks(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(ReorderTasksParams params) async {
    return _repository.reorderTasks(params.taskIds);
  }
}

class ReorderTasksParams extends Equatable {
  const ReorderTasksParams({required this.taskIds});

  final List<String> taskIds;

  @override
  List<Object?> get props => [taskIds];
}