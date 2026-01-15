import 'package:core/core.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case para login anônimo (guest)
///
/// Permite acesso ao app sem registro, com possibilidade de
/// vincular conta posteriormente
class SignInAnonymouslyUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  const SignInAnonymouslyUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return _repository.signInAnonymously();
  }
}

/// Classe para indicar que não há parâmetros necessários
class NoParams {
  const NoParams();
}
