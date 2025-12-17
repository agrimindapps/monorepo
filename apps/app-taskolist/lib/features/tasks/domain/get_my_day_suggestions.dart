import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'my_day_repository.dart';
import 'task_entity.dart';

class GetMyDaySuggestions extends UseCaseWithParams<List<TaskEntity>, GetMyDaySuggestionsParams> {
  const GetMyDaySuggestions(this._repository);

  final MyDayRepository _repository;

  @override
  ResultFuture<List<TaskEntity>> call(GetMyDaySuggestionsParams params) async {
    return _repository.getMyDaySuggestions(userId: params.userId);
  }
}

class GetMyDaySuggestionsParams {
  const GetMyDaySuggestionsParams({required this.userId});

  final String userId;
}
