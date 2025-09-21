import 'package:core/core.dart' hide Failure;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class WatchAuthState {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  Stream<Either<Failure, UserEntity?>> call() {
    return repository.watchAuthState();
  }
}