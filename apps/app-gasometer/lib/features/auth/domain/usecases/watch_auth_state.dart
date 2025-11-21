import 'package:core/core.dart';

import '../repositories/auth_repository.dart';


class WatchAuthState {

  WatchAuthState(this.repository);
  final AuthRepository repository;

  Stream<Either<Failure, UserEntity?>> call() {
    return repository.watchAuthState();
  }
}
