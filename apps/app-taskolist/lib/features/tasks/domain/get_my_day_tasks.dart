import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'my_day_repository.dart';
import 'my_day_task_entity.dart';

class GetMyDayTasks extends UseCaseWithParams<List<MyDayTaskEntity>, GetMyDayTasksParams> {
  const GetMyDayTasks(this._repository);

  final MyDayRepository _repository;

  @override
  ResultFuture<List<MyDayTaskEntity>> call(GetMyDayTasksParams params) async {
    return _repository.getMyDayTasks(userId: params.userId);
  }
}

class GetMyDayTasksParams {
  const GetMyDayTasksParams({required this.userId});

  final String userId;
}
