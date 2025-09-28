import 'package:core/core.dart' hide Failure, NoParamsUseCase;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInAnonymously implements NoParamsUseCase<UserEntity> {

  SignInAnonymously(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call() async {
    return repository.signInAnonymously();
  }
}