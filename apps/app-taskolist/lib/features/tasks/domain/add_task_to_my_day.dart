import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'my_day_repository.dart';

class AddTaskToMyDay extends UseCaseWithParams<void, AddTaskToMyDayParams> {
  const AddTaskToMyDay(this._repository);

  final MyDayRepository _repository;

  @override
  ResultFuture<void> call(AddTaskToMyDayParams params) async {
    return _repository.addTaskToMyDay(
      taskId: params.taskId,
      userId: params.userId,
    );
  }
}

class AddTaskToMyDayParams {
  const AddTaskToMyDayParams({
    required this.taskId,
    required this.userId,
  });

  final String taskId;
  final String userId;
}
