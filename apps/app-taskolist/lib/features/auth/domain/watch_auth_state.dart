import '../../../core/usecases/usecase.dart';
import 'auth_repository.dart';
import 'user_entity.dart';

class WatchAuthState extends StreamUseCaseWithoutParams<UserEntity?> {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<UserEntity?> call() {
    return _repository.watchAuthState();
  }
}