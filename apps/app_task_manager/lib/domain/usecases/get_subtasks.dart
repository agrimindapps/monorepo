import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';

class GetSubtasks extends UseCaseWithParams<List<TaskEntity>, GetSubtasksParams> {
  const GetSubtasks(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<List<TaskEntity>> call(GetSubtasksParams params) async {
    return _repository.getSubtasks(params.parentTaskId);
  }
}

class GetSubtasksParams {
  const GetSubtasksParams({
    required this.parentTaskId,
  });

  final String parentTaskId;
}