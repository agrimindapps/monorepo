import '../../../core/usecases/usecase.dart';
import 'my_day_repository.dart';
import 'my_day_task_entity.dart';

class WatchMyDayTasks extends StreamUseCase<List<MyDayTaskEntity>, WatchMyDayTasksParams> {
  const WatchMyDayTasks(this._repository);

  final MyDayRepository _repository;

  @override
  Stream<List<MyDayTaskEntity>> call(WatchMyDayTasksParams params) {
    return _repository.watchMyDayTasks(userId: params.userId);
  }
}

class WatchMyDayTasksParams {
  const WatchMyDayTasksParams({required this.userId});

  final String userId;
}
