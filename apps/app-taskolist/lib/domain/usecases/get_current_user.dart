import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser extends UseCaseWithoutParams<UserEntity?> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<UserEntity?> call() async {
    return _repository.getCurrentUser();
  }
}