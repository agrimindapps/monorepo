import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'my_day_repository.dart';

class ClearMyDay extends UseCaseWithParams<void, ClearMyDayParams> {
  const ClearMyDay(this._repository);

  final MyDayRepository _repository;

  @override
  ResultFuture<void> call(ClearMyDayParams params) async {
    return _repository.clearMyDay(userId: params.userId);
  }
}

class ClearMyDayParams {
  const ClearMyDayParams({required this.userId});

  final String userId;
}
