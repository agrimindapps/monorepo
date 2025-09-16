import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../repositories/auth_repository.dart';

class SignOut extends UseCaseWithoutParams<void> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<void> call() async {
    return _repository.signOut();
  }
}