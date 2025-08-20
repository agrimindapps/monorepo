import '../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState extends StreamUseCaseWithoutParams<UserEntity?> {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<UserEntity?> call() {
    return _repository.watchAuthState();
  }
}