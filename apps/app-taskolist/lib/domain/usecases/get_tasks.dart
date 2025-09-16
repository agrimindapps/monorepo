import 'package:equatable/equatable.dart';

import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasks extends UseCaseWithParams<List<TaskEntity>, GetTasksParams> {
  const GetTasks(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<List<TaskEntity>> call(GetTasksParams params) async {
    return _repository.getTasks(
      listId: params.listId,
      userId: params.userId,
      status: params.status,
      priority: params.priority,
      isStarred: params.isStarred,
      dueBefore: params.dueBefore,
      dueAfter: params.dueAfter,
    );
  }
}

class GetTasksParams extends Equatable {
  const GetTasksParams({
    this.listId,
    this.userId,
    this.status,
    this.priority,
    this.isStarred,
    this.dueBefore,
    this.dueAfter,
  });

  final String? listId;
  final String? userId;
  final TaskStatus? status;
  final TaskPriority? priority;
  final bool? isStarred;
  final DateTime? dueBefore;
  final DateTime? dueAfter;

  @override
  List<Object?> get props => [
        listId,
        userId,
        status,
        priority,
        isStarred,
        dueBefore,
        dueAfter,
      ];
}