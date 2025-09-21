import 'package:core/core.dart' hide Failure, NoParamsUseCase;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInAnonymously implements NoParamsUseCase<UserEntity> {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call() async {
    return repository.signInAnonymously();
  }
}