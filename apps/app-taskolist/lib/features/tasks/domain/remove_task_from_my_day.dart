import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'my_day_repository.dart';

class RemoveTaskFromMyDay extends UseCaseWithParams<void, RemoveTaskFromMyDayParams> {
  const RemoveTaskFromMyDay(this._repository);

  final MyDayRepository _repository;

  @override
  ResultFuture<void> call(RemoveTaskFromMyDayParams params) async {
    return _repository.removeTaskFromMyDay(taskId: params.taskId);
  }
}

class RemoveTaskFromMyDayParams {
  const RemoveTaskFromMyDayParams({required this.taskId});

  final String taskId;
}
