import 'package:core/core.dart';

import '../repositories/auth_repository.dart';

@injectable
class SignInAnonymously implements NoParamsUseCase<UserEntity> {

  SignInAnonymously(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call() async {
    return repository.signInAnonymously();
  }
}