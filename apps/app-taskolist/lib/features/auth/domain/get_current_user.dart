import '../../../core/usecases/usecase.dart';
import '../../../core/utils/typedef.dart';
import 'auth_repository.dart';
import 'user_entity.dart';

class GetCurrentUser extends UseCaseWithoutParams<UserEntity?> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<UserEntity?> call() async {
    return _repository.getCurrentUser();
  }
}
