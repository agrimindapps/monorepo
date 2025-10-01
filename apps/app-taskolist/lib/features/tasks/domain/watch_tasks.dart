import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import 'task_entity.dart';
import 'task_repository.dart';

@lazySingleton
class WatchTasks extends StreamUseCase<List<TaskEntity>, WatchTasksParams> {
  const WatchTasks(this._repository);

  final TaskRepository _repository;

  @override
  Stream<List<TaskEntity>> call(WatchTasksParams params) {
    return _repository.watchTasks(
      listId: params.listId,
      userId: params.userId,
      status: params.status,
      priority: params.priority,
      isStarred: params.isStarred,
    );
  }
}

@lazySingleton
class WatchTasksParams extends Equatable {
  const WatchTasksParams({
    this.listId,
    this.userId,
    this.status,
    this.priority,
    this.isStarred,
  });

  final String? listId;
  final String? userId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final bool? isStarred;

  @override
  List<Object?> get props => [
        listId,
        userId,
        status,
        priority,
        isStarred,
      ];
}