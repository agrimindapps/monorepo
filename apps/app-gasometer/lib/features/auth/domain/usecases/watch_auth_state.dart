import 'package:core/core.dart' hide Failure;

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class WatchAuthState {

  WatchAuthState(this.repository);
  final AuthRepository repository;

  Stream<Either<Failure, UserEntity?>> call() {
    return repository.watchAuthState();
  }
}