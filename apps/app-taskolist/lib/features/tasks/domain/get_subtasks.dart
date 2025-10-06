import 'package:core/core.dart';

import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'task_entity.dart';
import 'task_repository.dart';

@lazySingleton
class GetSubtasks extends UseCaseWithParams<List<TaskEntity>, GetSubtasksParams> {
  const GetSubtasks(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<List<TaskEntity>> call(GetSubtasksParams params) async {
    return _repository.getSubtasks(params.parentTaskId);
  }
}

@lazySingleton
class GetSubtasksParams {
  const GetSubtasksParams({
    required this.parentTaskId,
  });

  final String parentTaskId;
}
