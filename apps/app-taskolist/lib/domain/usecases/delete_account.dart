import '../../core/usecases/usecase.dart';
import '../../core/utils/typedef.dart';
import '../repositories/auth_repository.dart';

class DeleteAccount extends UseCaseWithoutParams<void> {
  const DeleteAccount(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<void> call() async {
    return _repository.deleteAccount();
  }
}